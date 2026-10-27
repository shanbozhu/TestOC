//
//  PBCrossAppUniqueDeviceIdentifierManager.m
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import "PBCrossAppUniqueDeviceIdentifierManager.h"
#import "PBCrossConfiguration.h"
#import "PBCrossDeviceAttributeCollector.h"
#import "PBCrossIdentityGenerator.h"
#import "PBCrossIdentityStore.h"
#import "PBCrossRemoteResolver.h"
#import "PBCrossErrors.h"
#import "PBCrossLogging.h"

NSNotificationName const PBCrossAppUniqueDeviceIdentifierDidUpdateNotification =
    @"PBCrossAppUniqueDeviceIdentifierDidUpdateNotification";
NSString * const PBCrossAppUniqueDeviceIdentifierIdentityUserInfoKey = @"PBCrossIdentity";

static void *PBCrossManagerWorkQueueKey = &PBCrossManagerWorkQueueKey;

@interface PBCrossAppUniqueDeviceIdentifierManager ()

@property (nonatomic, copy) PBCrossConfiguration *configurationStorage;
@property (nonatomic, strong) PBCrossIdentityStore *storeStorage;
@property (nonatomic, strong, nullable) PBCrossRemoteResolver *remoteResolverStorage;
@property (nonatomic, strong) dispatch_queue_t workQueue;
@property (nonatomic, strong, nullable) PBCrossIdentity *cachedIdentityStorage;
@property (nonatomic, strong, nullable) NSDate *cachedIdentityDate;
@property (nonatomic, assign) BOOL remoteResolutionInFlight;
@property (nonatomic, strong) NSMutableArray<PBCrossIdentityCompletion> *pendingRemoteCompletions;
@property (nonatomic, assign) NSUInteger configurationGeneration;

- (instancetype)initPrivate;
- (BOOL)isOnWorkQueue;
- (PBCrossConfiguration *)configurationSnapshot;
- (nullable PBCrossIdentityStore *)storeSnapshot;
- (nullable PBCrossRemoteResolver *)remoteResolverSnapshot;
- (NSUInteger)currentGeneration;
- (nullable PBCrossIdentity *)cachedIdentityIfFresh;
- (nullable NSArray<PBCrossIdentifier *> *)cachedRemoteIdentifiersWithResolvedAt:(NSDate * _Nullable * _Nullable)resolvedAt;
- (BOOL)canUseRemoteResolution;
- (PBCrossIdentity *)ensureIdentityOnCurrentThread;
- (PBCrossIdentity *)buildIdentityWithAttributes:(PBCrossDeviceAttributes *)attributes
                               remoteIdentifiers:(nullable NSArray<PBCrossIdentifier *> *)remoteIdentifiers
                                    resolvedAt:(nullable NSDate *)resolvedAt;
- (PBCrossIdentity *)identityByReplacingRemoteIdentifiers:(NSArray<PBCrossIdentifier *> *)remoteIdentifiers
                                              resolvedAt:(nullable NSDate *)resolvedAt
                                                    base:(PBCrossIdentity *)base;
- (void)cacheIdentity:(PBCrossIdentity *)identity;
- (void)loadIdentityWithForce:(BOOL)force completion:(nullable PBCrossIdentityCompletion)completion;
- (void)deliverIdentity:(nullable PBCrossIdentity *)identity
                  error:(nullable NSError *)error
             completion:(nullable PBCrossIdentityCompletion)completion;
- (void)finishRemoteResolutionWithIdentifiers:(nullable NSArray<PBCrossIdentifier *> *)identifiers
                                   resolvedAt:(nullable NSDate *)resolvedAt
                                        error:(nullable NSError *)error
                                   generation:(NSUInteger)generation;
- (void)postIdentityUpdateNotification:(PBCrossIdentity *)identity;

@end

@implementation PBCrossAppUniqueDeviceIdentifierManager

+ (instancetype)sharedManager
{
    static PBCrossAppUniqueDeviceIdentifierManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] initPrivate];
    });
    return manager;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        _configurationStorage = [[PBCrossConfiguration alloc] init];
        _storeStorage = [[PBCrossIdentityStore alloc] initWithConfiguration:_configurationStorage];
        _remoteResolverStorage = nil;
        _pendingRemoteCompletions = [NSMutableArray array];
        _configurationGeneration = 0;

        dispatch_queue_attr_t attributes =
            dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0);
        _workQueue = dispatch_queue_create("com.pb.crossapp.unique-device-identifier", attributes);
        dispatch_queue_set_specific(_workQueue, PBCrossManagerWorkQueueKey, (__bridge void *)self, NULL);
    }
    return self;
}

#pragma mark - Configuration

- (PBCrossConfiguration *)configuration
{
    @synchronized(self) {
        return [self.configurationStorage copy];
    }
}

- (BOOL)configureWithBlock:(void (^)(PBCrossConfiguration *configuration))block
                     error:(NSError **)error
{
    if (!block) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossIdentifierErrorInvalidConfiguration, @"配置 block 不能为空");
        }
        return NO;
    }

    PBCrossConfiguration *configuration = [self configuration];
    block(configuration);

    NSError *validationError = nil;
    if (![configuration validateWithError:&validationError]) {
        if (error) {
            *error = validationError;
        }
        return NO;
    }

    NSArray<PBCrossIdentityCompletion> *pendingCompletions = nil;
    @synchronized(self) {
        self.configurationStorage = [configuration copy];
        self.storeStorage = [[PBCrossIdentityStore alloc] initWithConfiguration:self.configurationStorage];
        self.remoteResolverStorage = self.configurationStorage.remoteConfiguration.enabled
            ? [[PBCrossRemoteResolver alloc] initWithConfiguration:self.configurationStorage store:self.storeStorage]
            : nil;
        self.cachedIdentityStorage = nil;
        self.cachedIdentityDate = nil;
        self.configurationGeneration += 1;
        self.remoteResolutionInFlight = NO;
        pendingCompletions = [self.pendingRemoteCompletions copy];
        [self.pendingRemoteCompletions removeAllObjects];
    }

    if (pendingCompletions.count > 0) {
        NSError *cancelledError = PBCrossErrorMake(PBCrossRemoteErrorNotConfigured,
                                                   @"配置已更新，本次远端解析已取消");
        dispatch_async(dispatch_get_main_queue(), ^{
            for (PBCrossIdentityCompletion completion in pendingCompletions) {
                completion(nil, cancelledError);
            }
        });
    }
    return YES;
}

#pragma mark - Snapshots

- (PBCrossConfiguration *)configurationSnapshot
{
    @synchronized(self) {
        return self.configurationStorage;
    }
}

- (nullable PBCrossIdentityStore *)storeSnapshot
{
    @synchronized(self) {
        return self.storeStorage;
    }
}

- (nullable PBCrossRemoteResolver *)remoteResolverSnapshot
{
    @synchronized(self) {
        return self.remoteResolverStorage;
    }
}

- (NSUInteger)currentGeneration
{
    @synchronized(self) {
        return self.configurationGeneration;
    }
}

- (BOOL)isOnWorkQueue
{
    return dispatch_get_specific(PBCrossManagerWorkQueueKey) == (__bridge void *)self;
}

#pragma mark - Identity

- (nullable PBCrossIdentity *)cachedIdentity
{
    @synchronized(self) {
        return self.cachedIdentityStorage;
    }
}

- (nullable PBCrossIdentity *)cachedIdentityIfFresh
{
    @synchronized(self) {
        if (!self.cachedIdentityStorage || !self.cachedIdentityDate) {
            return nil;
        }
        NSTimeInterval cacheDuration = self.configurationStorage.identityCacheDuration;
        if (cacheDuration <= 0) {
            return nil;
        }
        NSTimeInterval age = [[NSDate date] timeIntervalSinceDate:self.cachedIdentityDate];
        return age < cacheDuration ? self.cachedIdentityStorage : nil;
    }
}

- (void)cacheIdentity:(PBCrossIdentity *)identity
{
    @synchronized(self) {
        self.cachedIdentityStorage = identity;
        self.cachedIdentityDate = identity.generatedAt ?: [NSDate date];
    }
}

- (nullable NSArray<PBCrossIdentifier *> *)cachedRemoteIdentifiersWithResolvedAt:(NSDate **)resolvedAt
{
    PBCrossConfiguration *configuration = [self configurationSnapshot];
    PBCrossRemoteConfiguration *remoteConfiguration = configuration.remoteConfiguration;
    if (!remoteConfiguration.enabled) {
        return nil;
    }
    if (remoteConfiguration.requiresUserConsent && !remoteConfiguration.hasUserConsent) {
        return nil;
    }

    PBCrossRemoteResolver *resolver = [self remoteResolverSnapshot];
    NSDate *date = nil;
    NSArray<PBCrossIdentifier *> *identifiers = [resolver cachedIdentifiersWithResolvedAt:&date];
    if (resolvedAt) {
        *resolvedAt = date;
    }
    return identifiers;
}

- (BOOL)canUseRemoteResolution
{
    PBCrossConfiguration *configuration = [self configurationSnapshot];
    PBCrossRemoteConfiguration *remoteConfiguration = configuration.remoteConfiguration;
    if (!remoteConfiguration.enabled) {
        return NO;
    }
    if (remoteConfiguration.requiresUserConsent && !remoteConfiguration.hasUserConsent) {
        return NO;
    }
    return [self remoteResolverSnapshot] != nil;
}

- (PBCrossIdentity *)buildIdentityWithAttributes:(PBCrossDeviceAttributes *)attributes
                               remoteIdentifiers:(NSArray<PBCrossIdentifier *> *)remoteIdentifiers
                                      resolvedAt:(NSDate *)resolvedAt
{
    PBCrossConfiguration *configuration = [self configurationSnapshot];
    PBCrossIdentityStore *store = [self storeSnapshot];

    BOOL serverIssued = NO;
    NSString *sharedID = [store sharedIDCreatingIfNeeded:YES serverIssued:&serverIssued];
    NSString *previousSystemUpdateTime =
        [store updateSystemUpdateTimeHistoryWithCurrentValue:attributes.sysFileTime];

    NSArray<PBCrossIdentifier *> *fingerprints =
        [PBCrossIdentityGenerator fingerprintIdentifiersWithAttributes:attributes configuration:configuration];

    NSMutableArray<PBCrossIdentifier *> *identifiers =
        [NSMutableArray arrayWithCapacity:fingerprints.count + remoteIdentifiers.count];
    [identifiers addObjectsFromArray:fingerprints];
    if (remoteIdentifiers.count > 0) {
        [identifiers addObjectsFromArray:remoteIdentifiers];
    }

    PBCrossIdentitySource sources = PBCrossIdentitySourceNone;
    if (fingerprints.count > 0) {
        sources |= PBCrossIdentitySourceFingerprint;
    }
    if (sharedID.length > 0) {
        sources |= serverIssued ? PBCrossIdentitySourceServer : PBCrossIdentitySourceSharedStorage;
    }
    if (remoteIdentifiers.count > 0) {
        sources |= PBCrossIdentitySourceRemote;
    }

    PBCrossIdentity *identity =
        [[PBCrossIdentity alloc] initWithSharedID:sharedID
                                      identifiers:identifiers
                                       attributes:attributes
                        previousSystemUpdateTime:previousSystemUpdateTime
                                        algorithm:PBCrossIdentifierAlgorithmName
                                          sources:sources
                                      generatedAt:[NSDate date]
                                 remoteResolvedAt:resolvedAt];
    [self cacheIdentity:identity];

    PBCrossLog(configuration, @"生成身份 current=%@ sources=%@ shared=%@",
               identity.currentIdentifier ?: @"-",
               PBCrossIdentitySourceDescription(sources),
               sharedID.length > 0 ? @"yes" : @"no");
    return identity;
}

- (PBCrossIdentity *)ensureIdentityOnCurrentThread
{
    PBCrossIdentity *cachedIdentity = [self cachedIdentityIfFresh];
    if (cachedIdentity) {
        return cachedIdentity;
    }

    PBCrossConfiguration *configuration = [self configurationSnapshot];
    PBCrossDeviceAttributes *attributes =
        [PBCrossDeviceAttributeCollector collectAttributesWithConfiguration:configuration];
    NSDate *resolvedAt = nil;
    NSArray<PBCrossIdentifier *> *remoteIdentifiers =
        [self cachedRemoteIdentifiersWithResolvedAt:&resolvedAt];
    return [self buildIdentityWithAttributes:attributes
                           remoteIdentifiers:remoteIdentifiers
                                  resolvedAt:resolvedAt];
}

- (void)loadIdentityWithForce:(BOOL)force completion:(PBCrossIdentityCompletion)completion
{
    dispatch_async(self.workQueue, ^{
        PBCrossConfiguration *configuration = [self configurationSnapshot];
        PBCrossIdentity *identity = force ? nil : [self cachedIdentityIfFresh];
        if (!identity) {
            PBCrossDeviceAttributes *attributes =
                [PBCrossDeviceAttributeCollector collectAttributesWithConfiguration:configuration];
            NSDate *resolvedAt = nil;
            NSArray<PBCrossIdentifier *> *remoteIdentifiers =
                [self cachedRemoteIdentifiersWithResolvedAt:&resolvedAt];
            identity = [self buildIdentityWithAttributes:attributes
                                       remoteIdentifiers:remoteIdentifiers
                                              resolvedAt:resolvedAt];
        }

        [self deliverIdentity:identity error:nil completion:completion];

        if (configuration.automaticallyRefreshesRemoteIdentity
            && [self canUseRemoteResolution]
            && ![[self remoteResolverSnapshot] hasFreshCache]) {
            [self resolveRemoteIdentityWithCompletion:nil];
        }
    });
}

- (void)loadIdentityWithCompletion:(PBCrossIdentityCompletion)completion
{
    [self loadIdentityWithForce:NO completion:completion];
}

- (void)refreshIdentityWithCompletion:(PBCrossIdentityCompletion)completion
{
    [self loadIdentityWithForce:YES completion:completion];
}

- (PBCrossIdentity *)identitySynchronously
{
    if ([self isOnWorkQueue] || [NSThread isMainThread]) {
        return [self ensureIdentityOnCurrentThread];
    }

    __block PBCrossIdentity *identity = nil;
    dispatch_sync(self.workQueue, ^{
        identity = [self ensureIdentityOnCurrentThread];
    });
    return identity;
}

- (void)deliverIdentity:(PBCrossIdentity *)identity
                  error:(NSError *)error
             completion:(PBCrossIdentityCompletion)completion
{
    if (!completion) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(identity, error);
    });
}

- (void)resetIdentityCache
{
    @synchronized(self) {
        self.cachedIdentityStorage = nil;
        self.cachedIdentityDate = nil;
    }
}

- (void)clearStoredIdentity
{
    NSArray<PBCrossIdentityCompletion> *pendingCompletions = nil;
    @synchronized(self) {
        [self.storeStorage clearStoredIdentity];
        self.cachedIdentityStorage = nil;
        self.cachedIdentityDate = nil;
        self.remoteResolutionInFlight = NO;
        self.configurationGeneration += 1;
        pendingCompletions = [self.pendingRemoteCompletions copy];
        [self.pendingRemoteCompletions removeAllObjects];
    }

    if (pendingCompletions.count > 0) {
        NSError *cancelledError = PBCrossErrorMake(PBCrossRemoteErrorNotConfigured,
                                                   @"身份数据已清除，本次远端解析已取消");
        dispatch_async(dispatch_get_main_queue(), ^{
            for (PBCrossIdentityCompletion completion in pendingCompletions) {
                completion(nil, cancelledError);
            }
        });
    }
}

#pragma mark - Remote

- (void)resolveRemoteIdentityWithCompletion:(PBCrossIdentityCompletion)completion
{
    dispatch_async(self.workQueue, ^{
        PBCrossConfiguration *configuration = [self configurationSnapshot];
        PBCrossRemoteConfiguration *remoteConfiguration = configuration.remoteConfiguration;
        PBCrossRemoteResolver *resolver = [self remoteResolverSnapshot];
        PBCrossIdentity *baseIdentity = [self cachedIdentityIfFresh];
        if (!baseIdentity) {
            baseIdentity = [self ensureIdentityOnCurrentThread];
        }

        if (!remoteConfiguration.enabled || resolver == nil) {
            [self deliverIdentity:baseIdentity
                            error:PBCrossErrorMake(PBCrossRemoteErrorNotConfigured,
                                                   @"%@", PBCrossRemoteErrorDescription(PBCrossRemoteErrorNotConfigured))
                       completion:completion];
            return;
        }

        if (remoteConfiguration.requiresUserConsent && !remoteConfiguration.hasUserConsent) {
            [self deliverIdentity:baseIdentity
                            error:PBCrossErrorMake(PBCrossRemoteErrorConsentRequired,
                                                   @"%@", PBCrossRemoteErrorDescription(PBCrossRemoteErrorConsentRequired))
                       completion:completion];
            return;
        }

        NSUInteger generation = [self currentGeneration];
        @synchronized(self) {
            if (self.remoteResolutionInFlight) {
                if (completion) {
                    [self.pendingRemoteCompletions addObject:[completion copy]];
                }
                return;
            }
            self.remoteResolutionInFlight = YES;
            if (completion) {
                [self.pendingRemoteCompletions addObject:[completion copy]];
            }
        }

        __weak typeof(self) weakSelf = self;
        [resolver resolveIdentifiersWithAttributes:baseIdentity.attributes
                                        completion:^(NSArray<PBCrossIdentifier *> *identifiers,
                                                     NSDate *resolvedAt,
                                                     NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            dispatch_async(strongSelf.workQueue, ^{
                @synchronized(strongSelf) {
                    if (generation != strongSelf.configurationGeneration) {
                        return;
                    }
                }
                [strongSelf finishRemoteResolutionWithIdentifiers:identifiers
                                                       resolvedAt:resolvedAt
                                                            error:error
                                                       generation:generation];
            });
        }];
    });
}

- (PBCrossIdentity *)identityByReplacingRemoteIdentifiers:(NSArray<PBCrossIdentifier *> *)remoteIdentifiers
                                              resolvedAt:(NSDate *)resolvedAt
                                                    base:(PBCrossIdentity *)base
{
    NSMutableArray<PBCrossIdentifier *> *identifiers =
        [NSMutableArray arrayWithCapacity:base.identifiers.count + remoteIdentifiers.count];
    for (PBCrossIdentifier *identifier in base.identifiers) {
        if (identifier.kind != PBCrossIdentifierKindRemote) {
            [identifiers addObject:identifier];
        }
    }
    if (remoteIdentifiers.count > 0) {
        [identifiers addObjectsFromArray:remoteIdentifiers];
    }

    PBCrossIdentitySource sources = base.sources & ~PBCrossIdentitySourceRemote;
    if (remoteIdentifiers.count > 0) {
        sources |= PBCrossIdentitySourceRemote;
    }

    return [[PBCrossIdentity alloc] initWithSharedID:base.sharedID
                                          identifiers:identifiers
                                           attributes:base.attributes
                            previousSystemUpdateTime:base.previousSystemUpdateTime
                                            algorithm:base.algorithm
                                              sources:sources
                                          generatedAt:[NSDate date]
                                     remoteResolvedAt:resolvedAt ?: [NSDate date]];
}

- (void)finishRemoteResolutionWithIdentifiers:(NSArray<PBCrossIdentifier *> *)identifiers
                                   resolvedAt:(NSDate *)resolvedAt
                                        error:(NSError *)error
                                   generation:(NSUInteger)generation
{
    NSArray<PBCrossIdentityCompletion> *completions = nil;
    @synchronized(self) {
        if (generation != self.configurationGeneration) {
            return;
        }
        self.remoteResolutionInFlight = NO;
        completions = [self.pendingRemoteCompletions copy];
        [self.pendingRemoteCompletions removeAllObjects];
    }

    PBCrossIdentity *identity = [self cachedIdentity];
    if (!identity) {
        identity = [self ensureIdentityOnCurrentThread];
    }
    if (generation != [self currentGeneration]) {
        return;
    }

    if (identifiers.count > 0) {
        identity = [self identityByReplacingRemoteIdentifiers:identifiers
                                                   resolvedAt:resolvedAt
                                                         base:identity];
        @synchronized(self) {
            if (generation != self.configurationGeneration) {
                return;
            }
            self.cachedIdentityStorage = identity;
            self.cachedIdentityDate = identity.generatedAt ?: [NSDate date];
        }
        [self postIdentityUpdateNotification:identity];
    }

    if (completions.count == 0) {
        return;
    }

    PBCrossIdentity *resolvedIdentity = identity;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (PBCrossIdentityCompletion completion in completions) {
            completion(resolvedIdentity, error);
        }
    });
}

- (void)postIdentityUpdateNotification:(PBCrossIdentity *)identity
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PBCrossAppUniqueDeviceIdentifierDidUpdateNotification
                                                            object:self
                                                          userInfo:@{PBCrossAppUniqueDeviceIdentifierIdentityUserInfoKey: identity}];
    });
}

#pragma mark - Shared ID

- (NSString *)sharedID
{
    PBCrossIdentityStore *store = [self storeSnapshot];
    NSString *sharedID = [store sharedIDCreatingIfNeeded:YES serverIssued:NULL];
    return sharedID ?: @"";
}

- (BOOL)setServerIssuedSharedID:(NSString *)sharedID
{
    PBCrossIdentityStore *store = [self storeSnapshot];
    BOOL success = [store setServerIssuedSharedID:sharedID];
    if (success) {
        @synchronized(self) {
            self.cachedIdentityStorage = nil;
            self.cachedIdentityDate = nil;
        }
    }
    return success;
}

#pragma mark - Adapter

- (PBCrossAdRequestAdapter *)adRequestAdapterWithContext:(PBCrossAdRequestContext *)context
{
    PBCrossIdentity *identity = [self cachedIdentityIfFresh];
    if (!identity) {
        identity = [self identitySynchronously];
    }

    PBCrossConfiguration *configuration = [self configurationSnapshot];
    PBCrossAdRequestAdapter *adapter =
        [[PBCrossAdRequestAdapter alloc] initWithIdentity:identity context:context];
    adapter.emitsRawAdvertisingIdentifier = configuration.emitsRawAdvertisingIdentifier;
    adapter.emitsLegacyCAIDFields = configuration.emitsLegacyCAIDFields;
    return adapter;
}

@end
