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
#import "PBCrossAdvertisingAuthorization.h"

NSNotificationName const PBCrossAppUniqueDeviceIdentifierDidUpdateNotification =
    @"PBCrossAppUniqueDeviceIdentifierDidUpdateNotification";
NSString * const PBCrossAppUniqueDeviceIdentifierIdentityUserInfoKey = @"PBCrossIdentity";

static void *PBCrossManagerWorkQueueKey = &PBCrossManagerWorkQueueKey;

/// 一次加载所使用的配置、存储和版本必须来自同一个临界区。
@interface PBCrossIdentityLoadContext : NSObject
@property (nonatomic, strong) PBCrossConfiguration *configuration;
@property (nonatomic, strong) PBCrossIdentityStore *store;
@property (nonatomic, strong, nullable) PBCrossRemoteResolver *resolver;
@property (nonatomic, assign) NSUInteger generation;
@end
@implementation PBCrossIdentityLoadContext
@end

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
- (nullable PBCrossIdentityStore *)storeSnapshot;
- (NSUInteger)currentGeneration;
- (nullable PBCrossIdentity *)cachedIdentityIfFresh;
- (PBCrossIdentityLoadContext *)loadContext;
- (nullable PBCrossIdentity *)identityByApplyingAdvertisingAuthorization:(nullable PBCrossIdentity *)identity;
- (nullable NSArray<PBCrossIdentifier *> *)cachedRemoteIdentifiersWithContext:(PBCrossIdentityLoadContext *)context
                                                                 resolvedAt:(NSDate * _Nullable * _Nullable)resolvedAt;
- (PBCrossIdentity *)ensureIdentityOnCurrentThreadWithError:(NSError * _Nullable * _Nullable)error;
- (nullable PBCrossIdentity *)identityWithContext:(PBCrossIdentityLoadContext *)context
                                          force:(BOOL)force
                                          error:(NSError * _Nullable * _Nullable)error;
- (nullable PBCrossIdentity *)buildIdentityWithAttributes:(PBCrossDeviceAttributes *)attributes
                               remoteIdentifiers:(nullable NSArray<PBCrossIdentifier *> *)remoteIdentifiers
                                    resolvedAt:(nullable NSDate *)resolvedAt
                                       context:(PBCrossIdentityLoadContext *)context
                                         error:(NSError * _Nullable * _Nullable)error;
- (PBCrossIdentity *)identityByReplacingRemoteIdentifiers:(NSArray<PBCrossIdentifier *> *)remoteIdentifiers
                                              resolvedAt:(nullable NSDate *)resolvedAt
                                                    base:(PBCrossIdentity *)base;
- (void)loadIdentityWithForce:(BOOL)force completion:(nullable PBCrossIdentityCompletion)completion;
- (void)deliverIdentity:(nullable PBCrossIdentity *)identity
                  error:(nullable NSError *)error
             generation:(NSUInteger)generation
             completion:(nullable PBCrossIdentityCompletion)completion;
- (void)finishRemoteResolutionWithIdentifiers:(nullable NSArray<PBCrossIdentifier *> *)identifiers
                                   resolvedAt:(nullable NSDate *)resolvedAt
                                        error:(nullable NSError *)error
                                   generation:(NSUInteger)generation;
- (void)postIdentityUpdateNotification:(PBCrossIdentity *)identity generation:(NSUInteger)generation;

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

- (nullable PBCrossIdentityStore *)storeSnapshot
{
    @synchronized(self) {
        return self.storeStorage;
    }
}

- (NSUInteger)currentGeneration
{
    @synchronized(self) {
        return self.configurationGeneration;
    }
}

- (PBCrossIdentityLoadContext *)loadContext
{
    @synchronized(self) {
        PBCrossIdentityLoadContext *context = [[PBCrossIdentityLoadContext alloc] init];
        context.configuration = self.configurationStorage;
        context.store = self.storeStorage;
        context.resolver = self.remoteResolverStorage;
        context.generation = self.configurationGeneration;
        return context;
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
        self.cachedIdentityStorage = [self identityByApplyingAdvertisingAuthorization:self.cachedIdentityStorage];
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
        self.cachedIdentityStorage = [self identityByApplyingAdvertisingAuthorization:self.cachedIdentityStorage];
        return age < cacheDuration ? self.cachedIdentityStorage : nil;
    }
}

- (nullable PBCrossIdentity *)identityByApplyingAdvertisingAuthorization:(nullable PBCrossIdentity *)identity
{
    if (!identity || (PBCrossAdvertisingIdentifierIsAuthorized()
                     && self.configurationStorage.allowsAdvertisingIdentifier)) {
        return identity;
    }
    if (identity.attributes.advertisingIdentifier.length == 0
        && identity.attributes.advertisingIdentifierMD5.length == 0) {
        return identity;
    }
    NSMutableDictionary *values = [identity.attributes.values mutableCopy];
    [values removeObjectForKey:PBCrossAttributeKeyIDFAMD5];
    PBCrossDeviceAttributes *attributes = [PBCrossDeviceAttributes attributesWithValues:values];
    return [[PBCrossIdentity alloc] initWithSharedID:identity.sharedID
                                      identifiers:identity.identifiers
                                       attributes:attributes
                        previousSystemUpdateTime:identity.previousSystemUpdateTime
                                        algorithm:identity.algorithm
                                          sources:identity.sources
                                      generatedAt:identity.generatedAt
                                 remoteResolvedAt:identity.remoteResolvedAt];
}

- (nullable NSArray<PBCrossIdentifier *> *)cachedRemoteIdentifiersWithContext:(PBCrossIdentityLoadContext *)context
                                                                 resolvedAt:(NSDate **)resolvedAt
{
    PBCrossConfiguration *configuration = context.configuration;
    PBCrossRemoteConfiguration *remoteConfiguration = configuration.remoteConfiguration;
    if (!remoteConfiguration.enabled) {
        return nil;
    }
    if (remoteConfiguration.requiresUserConsent && !remoteConfiguration.hasUserConsent) {
        return nil;
    }

    PBCrossRemoteResolver *resolver = context.resolver;
    NSDate *date = nil;
    NSArray<PBCrossIdentifier *> *identifiers = [resolver cachedIdentifiersWithResolvedAt:&date];
    if (resolvedAt) {
        *resolvedAt = date;
    }
    return identifiers;
}

- (nullable PBCrossIdentity *)buildIdentityWithAttributes:(PBCrossDeviceAttributes *)attributes
                               remoteIdentifiers:(NSArray<PBCrossIdentifier *> *)remoteIdentifiers
                                      resolvedAt:(NSDate *)resolvedAt
                                         context:(PBCrossIdentityLoadContext *)context
                                           error:(NSError **)error
{
    PBCrossConfiguration *configuration = context.configuration;
    PBCrossIdentityStore *store = context.store;

    BOOL serverIssued = NO;
    NSError *storageError = nil;
    NSString *sharedID = [store sharedIDCreatingIfNeeded:YES serverIssued:&serverIssued error:&storageError];
    if (error) {
        *error = storageError;
    }
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
    @synchronized(self) {
        if (context.generation != self.configurationGeneration) {
            if (error) {
                *error = PBCrossErrorMake(PBCrossIdentifierErrorOperationCancelled, @"配置或身份已更新，本次加载已取消");
            }
            return nil;
        }
        identity = [self identityByApplyingAdvertisingAuthorization:identity];
        // 存储恢复后下次 load 应立即重试，不把不完整身份作为成功缓存。
        self.cachedIdentityStorage = storageError ? nil : identity;
        self.cachedIdentityDate = storageError ? nil : identity.generatedAt;
    }

    PBCrossLog(configuration, @"生成身份 current=%@ sources=%@ shared=%@",
               identity.currentIdentifier ?: @"-",
               PBCrossIdentitySourceDescription(sources),
               sharedID.length > 0 ? @"yes" : @"no");
    return identity;
}

- (nullable PBCrossIdentity *)identityWithContext:(PBCrossIdentityLoadContext *)context
                                          force:(BOOL)force
                                          error:(NSError **)error
{
    if (error) { *error = nil; }
    @synchronized(self) {
        if (context.generation != self.configurationGeneration) {
            if (error) {
                *error = PBCrossErrorMake(PBCrossIdentifierErrorOperationCancelled, @"配置或身份已更新，本次加载已取消");
            }
            return nil;
        }
        PBCrossIdentity *cached = force ? nil : [self cachedIdentityIfFresh];
        if (cached) { return cached; }
    }

    PBCrossDeviceAttributes *attributes =
        [PBCrossDeviceAttributeCollector collectAttributesWithConfiguration:context.configuration];
    NSDate *resolvedAt = nil;
    NSArray<PBCrossIdentifier *> *remoteIdentifiers =
        [self cachedRemoteIdentifiersWithContext:context resolvedAt:&resolvedAt];
    return [self buildIdentityWithAttributes:attributes
                           remoteIdentifiers:remoteIdentifiers
                                  resolvedAt:resolvedAt
                                     context:context
                                       error:error];
}

- (PBCrossIdentity *)ensureIdentityOnCurrentThreadWithError:(NSError **)error
{
    // 同步 API 没有取消回调；配置切换时使用新的完整上下文重试。
    while (YES) {
        PBCrossIdentityLoadContext *context = [self loadContext];
        NSError *loadError = nil;
        PBCrossIdentity *identity = [self identityWithContext:context force:NO error:&loadError];
        @synchronized(self) {
            if (context.generation != self.configurationGeneration) { continue; }
            if (error) { *error = loadError; }
            return [self identityByApplyingAdvertisingAuthorization:identity];
        }
    }
}

- (void)loadIdentityWithForce:(BOOL)force completion:(PBCrossIdentityCompletion)completion
{
    dispatch_async(self.workQueue, ^{
        PBCrossIdentityLoadContext *context = [self loadContext];
        NSError *loadError = nil;
        PBCrossIdentity *identity = [self identityWithContext:context force:force error:&loadError];
        [self deliverIdentity:identity error:loadError generation:context.generation completion:completion];

        PBCrossRemoteConfiguration *remote = context.configuration.remoteConfiguration;
        if (!loadError && context.generation == [self currentGeneration]
            && context.configuration.automaticallyRefreshesRemoteIdentity
            && remote.enabled && (!remote.requiresUserConsent || remote.hasUserConsent)
            && context.resolver && ![context.resolver hasFreshCache]) {
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
        return [self ensureIdentityOnCurrentThreadWithError:NULL];
    }

    __block PBCrossIdentity *identity = nil;
    dispatch_sync(self.workQueue, ^{
        identity = [self ensureIdentityOnCurrentThreadWithError:NULL];
    });
    return identity;
}

- (void)deliverIdentity:(PBCrossIdentity *)identity
                  error:(NSError *)error
             generation:(NSUInteger)generation
             completion:(PBCrossIdentityCompletion)completion
{
    if (!completion) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        PBCrossIdentity *deliveredIdentity = nil;
        NSError *deliveredError = error;
        @synchronized(self) {
            if (generation != self.configurationGeneration) {
                deliveredError = PBCrossErrorMake(PBCrossIdentifierErrorOperationCancelled, @"配置或身份已更新，本次加载已取消");
            } else {
                deliveredIdentity = [self identityByApplyingAdvertisingAuthorization:identity];
            }
        }
        completion(deliveredIdentity, deliveredError);
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
        PBCrossIdentityLoadContext *context = [self loadContext];
        PBCrossConfiguration *configuration = context.configuration;
        PBCrossRemoteConfiguration *remoteConfiguration = configuration.remoteConfiguration;
        PBCrossRemoteResolver *resolver = context.resolver;
        NSError *storageError = nil;
        PBCrossIdentity *baseIdentity = [self identityWithContext:context force:NO error:&storageError];
        if (storageError) {
            [self deliverIdentity:baseIdentity error:storageError generation:context.generation completion:completion];
            return;
        }

        if (!remoteConfiguration.enabled || resolver == nil) {
            [self deliverIdentity:baseIdentity
                            error:PBCrossErrorMake(PBCrossRemoteErrorNotConfigured,
                                                   @"%@", PBCrossRemoteErrorDescription(PBCrossRemoteErrorNotConfigured))
                       generation:context.generation completion:completion];
            return;
        }

        if (remoteConfiguration.requiresUserConsent && !remoteConfiguration.hasUserConsent) {
            [self deliverIdentity:baseIdentity
                            error:PBCrossErrorMake(PBCrossRemoteErrorConsentRequired,
                                                   @"%@", PBCrossRemoteErrorDescription(PBCrossRemoteErrorConsentRequired))
                       generation:context.generation completion:completion];
            return;
        }

        NSUInteger generation = context.generation;
        @synchronized(self) {
            if (generation != self.configurationGeneration) {
                [self deliverIdentity:nil error:nil generation:generation completion:completion];
                return;
            }
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
    NSError *storageError = nil;
    if (!identity) {
        identity = [self ensureIdentityOnCurrentThreadWithError:&storageError];
    }
    if (generation != [self currentGeneration]) {
        for (PBCrossIdentityCompletion completion in completions) {
            [self deliverIdentity:nil error:nil generation:generation completion:completion];
        }
        return;
    }

    if (identifiers.count > 0) {
        identity = [self identityByReplacingRemoteIdentifiers:identifiers
                                                   resolvedAt:resolvedAt
                                                         base:identity];
        @synchronized(self) {
            if (generation != self.configurationGeneration) {
                for (PBCrossIdentityCompletion completion in completions) {
                    [self deliverIdentity:nil error:nil generation:generation completion:completion];
                }
                return;
            }
            identity = [self identityByApplyingAdvertisingAuthorization:identity];
            if (!storageError) {
                self.cachedIdentityStorage = identity;
                self.cachedIdentityDate = identity.generatedAt ?: [NSDate date];
            }
        }
        if (!storageError) {
            [self postIdentityUpdateNotification:identity generation:generation];
        }
    }

    if (completions.count == 0) {
        return;
    }

    for (PBCrossIdentityCompletion completion in completions) {
        [self deliverIdentity:identity error:error ?: storageError generation:generation completion:completion];
    }
}

- (void)postIdentityUpdateNotification:(PBCrossIdentity *)identity generation:(NSUInteger)generation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        PBCrossIdentity *deliveredIdentity = nil;
        @synchronized(self) {
            if (generation != self.configurationGeneration) { return; }
            deliveredIdentity = [self identityByApplyingAdvertisingAuthorization:identity];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:PBCrossAppUniqueDeviceIdentifierDidUpdateNotification
                                                            object:self
                                                          userInfo:@{PBCrossAppUniqueDeviceIdentifierIdentityUserInfoKey: deliveredIdentity}];
    });
}

#pragma mark - Shared ID

- (NSString *)sharedID
{
    PBCrossIdentityStore *store = [self storeSnapshot];
    NSString *sharedID = [store sharedIDCreatingIfNeeded:YES serverIssued:NULL error:NULL];
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
    while (YES) {
        PBCrossIdentityLoadContext *loadContext = [self loadContext];
        PBCrossIdentity *identity = [self identitySynchronously];
        @synchronized(self) {
            if (loadContext.generation != self.configurationGeneration) { continue; }
            PBCrossAdRequestAdapter *adapter =
                [[PBCrossAdRequestAdapter alloc] initWithIdentity:identity context:context];
            adapter.emitsRawAdvertisingIdentifier = loadContext.configuration.emitsRawAdvertisingIdentifier;
            adapter.emitsLegacyCAIDFields = loadContext.configuration.emitsLegacyCAIDFields;
            return adapter;
        }
    }
}

@end
