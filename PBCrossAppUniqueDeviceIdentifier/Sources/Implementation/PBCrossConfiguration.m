//
//  PBCrossConfiguration.m
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import "PBCrossConfiguration.h"
#import "PBCrossErrors.h"

NSErrorDomain const PBCrossIdentifierErrorDomain = @"PBCrossIdentifierErrorDomain";
NSString * const PBCrossIdentifierAlgorithmName = @"pb-xid-v1";
NSString * const PBCrossAppUniqueDeviceIdentifierVersion = @"1.0.0";
NSString * const PBCrossDefaultSalt = @"pb-xid-default-salt";
NSString * const PBCrossDefaultKeychainService = @"com.pb.crossapp.unique-device-identifier";

@interface PBCrossIdentifierVersion ()

- (instancetype)initWithName:(NSString *)name
               attributeKeys:(NSArray<PBCrossAttributeKey> *)attributeKeys
                        salt:(nullable NSString *)salt;

@end

@implementation PBCrossIdentifierVersion

+ (instancetype)versionWithName:(NSString *)name
                   attributeKeys:(NSArray<PBCrossAttributeKey> *)attributeKeys
{
    return [[self alloc] initWithName:name attributeKeys:attributeKeys salt:nil];
}

+ (instancetype)versionWithName:(NSString *)name
                   attributeKeys:(NSArray<PBCrossAttributeKey> *)attributeKeys
                            salt:(nullable NSString *)salt
{
    return [[self alloc] initWithName:name attributeKeys:attributeKeys salt:salt];
}

+ (instancetype)defaultVersion
{
    static PBCrossIdentifierVersion *version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [self versionWithName:@"20261001" attributeKeys:@[
            PBCrossAttributeKeyBootTimeInSec,
            PBCrossAttributeKeyDeviceName,
            PBCrossAttributeKeyDeviceInitTime,
            PBCrossAttributeKeySysFileTime,
            PBCrossAttributeKeyMachine,
            PBCrossAttributeKeyModel,
            PBCrossAttributeKeyDisk,
            PBCrossAttributeKeyMemory,
            PBCrossAttributeKeyScreenResolution,
            PBCrossAttributeKeyProcessorCount,
            PBCrossAttributeKeyMntID,
        ]];
    });
    return [version copy];
}

+ (instancetype)compatibilityVersion
{
    static PBCrossIdentifierVersion *version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [self versionWithName:@"20260301"
                          attributeKeys:[PBCrossDeviceAttributes CAIDCompatibleAttributeKeys]];
    });
    return [version copy];
}

- (instancetype)initWithName:(NSString *)name
               attributeKeys:(NSArray<PBCrossAttributeKey> *)attributeKeys
                        salt:(nullable NSString *)salt
{
    self = [super init];
    if (self) {
        _name = [name isKindOfClass:[NSString class]] ? [name copy] : @"";
        _salt = ([salt isKindOfClass:[NSString class]] && salt.length > 0) ? [salt copy] : nil;

        NSArray *candidateKeys = [attributeKeys isKindOfClass:[NSArray class]] ? attributeKeys : @[];
        NSMutableArray<PBCrossAttributeKey> *keys = [NSMutableArray arrayWithCapacity:candidateKeys.count];
        NSMutableSet<NSString *> *seenKeys = [NSMutableSet setWithCapacity:candidateKeys.count];
        for (id key in candidateKeys) {
            if (![key isKindOfClass:[NSString class]] || [key length] == 0 || [seenKeys containsObject:key]) {
                continue;
            }
            [seenKeys addObject:key];
            [keys addObject:key];
        }
        _attributeKeys = [keys copy];
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[PBCrossIdentifierVersion class]]) {
        return NO;
    }
    PBCrossIdentifierVersion *other = object;
    return [self.name isEqualToString:other.name]
        && [self.attributeKeys isEqualToArray:other.attributeKeys]
        && ((self.salt == other.salt) || [self.salt isEqualToString:other.salt]);
}

- (NSUInteger)hash
{
    return self.name.hash ^ self.attributeKeys.hash ^ self.salt.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; name=%@; keys=%lu; salt=%@>",
            NSStringFromClass([self class]),
            self,
            self.name,
            (unsigned long)self.attributeKeys.count,
            self.salt ? @"custom" : @"default"];
}

@end

@implementation PBCrossRemoteConfiguration

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enabled = NO;
        _requestTimeout = 10.0;
        _cacheTimeToLive = 24 * 60 * 60;
        _dailyRequestLimit = 5;
        _requiresUserConsent = YES;
        _userConsentGranted = NO;
        _allowsInsecureHTTP = NO;
    }
    return self;
}

- (BOOL)isConfigured
{
    return self.endpointURL != nil
        && self.developerID.length > 0
        && self.publicKey.length > 0;
}

- (BOOL)validateWithError:(NSError **)error
{
    if (!self.enabled) {
        return YES;
    }

    if (!self.endpointURL || self.endpointURL.host.length == 0) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossRemoteErrorInvalidEndpoint, @"远端服务地址为空");
        }
        return NO;
    }

    NSString *scheme = self.endpointURL.scheme.lowercaseString;
    BOOL isHTTPS = [scheme isEqualToString:@"https"];
    BOOL isHTTP = [scheme isEqualToString:@"http"];
    if (!isHTTPS && !(self.allowsInsecureHTTP && isHTTP)) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossRemoteErrorInvalidEndpoint,
                                      @"远端服务必须使用 HTTPS（调试可设置 allowsInsecureHTTP）");
        }
        return NO;
    }

    if (self.developerID.length == 0) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossRemoteErrorNotConfigured, @"缺少 developerID（dev_id）");
        }
        return NO;
    }

    if (self.publicKey.length == 0) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossRemoteErrorNotConfigured, @"缺少服务端公钥");
        }
        return NO;
    }

    if (self.requestTimeout <= 0) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossRemoteErrorNotConfigured, @"requestTimeout 必须大于 0");
        }
        return NO;
    }

    if (self.cacheTimeToLive <= 0) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossRemoteErrorNotConfigured, @"cacheTimeToLive 必须大于 0");
        }
        return NO;
    }

    if (self.dailyRequestLimit == 0) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossRemoteErrorNotConfigured, @"dailyRequestLimit 必须大于 0");
        }
        return NO;
    }

    return YES;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    PBCrossRemoteConfiguration *configuration = [[[self class] allocWithZone:zone] init];
    configuration.enabled = self.enabled;
    configuration.endpointURL = self.endpointURL;
    configuration.developerID = self.developerID;
    configuration.publicKey = self.publicKey;
    configuration.requestTimeout = self.requestTimeout;
    configuration.cacheTimeToLive = self.cacheTimeToLive;
    configuration.dailyRequestLimit = self.dailyRequestLimit;
    configuration.requiresUserConsent = self.requiresUserConsent;
    configuration.userConsentGranted = self.userConsentGranted;
    configuration.allowsInsecureHTTP = self.allowsInsecureHTTP;
    return configuration;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; enabled=%@; endpoint=%@; devID=%@; ttl=%.0fs; limit=%lu>",
            NSStringFromClass([self class]),
            self,
            self.enabled ? @"YES" : @"NO",
            self.endpointURL.absoluteString ?: @"-",
            self.developerID ?: @"-",
            self.cacheTimeToLive,
            (unsigned long)self.dailyRequestLimit];
}

@end

@implementation PBCrossConfiguration

- (instancetype)init
{
    self = [super init];
    if (self) {
        _salt = [PBCrossDefaultSalt copy];
        _supportedVersions = @[[PBCrossIdentifierVersion defaultVersion], [PBCrossIdentifierVersion compatibilityVersion]];
        _keychainService = [PBCrossDefaultKeychainService copy];
        _collectsDeviceName = YES;
        _collectsCarrierInformation = YES;
        _allowsAdvertisingIdentifier = NO;
        _emitsRawAdvertisingIdentifier = NO;
        _emitsLegacyCAIDFields = NO;
        _identityCacheDuration = 5 * 60;
        _loggingEnabled = NO;
        _remoteConfiguration = [[PBCrossRemoteConfiguration alloc] init];
        _automaticallyRefreshesRemoteIdentity = YES;
    }
    return self;
}

- (BOOL)validateWithError:(NSError **)error
{
    if (self.salt.length == 0) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossIdentifierErrorInvalidConfiguration, @"salt 不能为空");
        }
        return NO;
    }

    if (![self.supportedVersions isKindOfClass:[NSArray class]] || self.supportedVersions.count == 0) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossIdentifierErrorInvalidConfiguration, @"supportedVersions 不能为空");
        }
        return NO;
    }

    NSMutableSet<NSString *> *names = [NSMutableSet setWithCapacity:self.supportedVersions.count];
    for (PBCrossIdentifierVersion *version in self.supportedVersions) {
        if (![version isKindOfClass:[PBCrossIdentifierVersion class]]) {
            if (error) {
                *error = PBCrossErrorMake(PBCrossIdentifierErrorInvalidConfiguration, @"supportedVersions 元素类型错误");
            }
            return NO;
        }
        if (version.name.length == 0) {
            if (error) {
                *error = PBCrossErrorMake(PBCrossIdentifierErrorInvalidConfiguration, @"算法版本号不能为空");
            }
            return NO;
        }
        if (version.attributeKeys.count == 0) {
            if (error) {
                *error = PBCrossErrorMake(PBCrossIdentifierErrorInvalidConfiguration,
                                          @"算法版本 %@ 的字段集不能为空", version.name);
            }
            return NO;
        }
        if ([names containsObject:version.name]) {
            if (error) {
                *error = PBCrossErrorMake(PBCrossIdentifierErrorInvalidConfiguration,
                                          @"算法版本号 %@ 重复", version.name);
            }
            return NO;
        }
        [names addObject:version.name];
    }

    if (self.keychainService.length == 0) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossIdentifierErrorInvalidConfiguration, @"keychainService 不能为空");
        }
        return NO;
    }

    if (self.identityCacheDuration < 0) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossIdentifierErrorInvalidConfiguration, @"identityCacheDuration 不能为负数");
        }
        return NO;
    }

    if (self.remoteConfiguration.enabled
        && ![self.remoteConfiguration validateWithError:error]) {
        return NO;
    }

    return YES;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    PBCrossConfiguration *configuration = [[[self class] allocWithZone:zone] init];
    configuration.salt = self.salt;
    configuration.supportedVersions = self.supportedVersions;
    configuration.keychainAccessGroup = self.keychainAccessGroup;
    configuration.keychainService = self.keychainService;
    configuration.appGroupIdentifier = self.appGroupIdentifier;
    configuration.collectsDeviceName = self.collectsDeviceName;
    configuration.collectsCarrierInformation = self.collectsCarrierInformation;
    configuration.allowsAdvertisingIdentifier = self.allowsAdvertisingIdentifier;
    configuration.emitsRawAdvertisingIdentifier = self.emitsRawAdvertisingIdentifier;
    configuration.emitsLegacyCAIDFields = self.emitsLegacyCAIDFields;
    configuration.identityCacheDuration = self.identityCacheDuration;
    configuration.loggingEnabled = self.loggingEnabled;
    configuration.remoteConfiguration = [self.remoteConfiguration copy];
    configuration.automaticallyRefreshesRemoteIdentity = self.automaticallyRefreshesRemoteIdentity;
    return configuration;
}

- (NSString *)description
{
    NSMutableArray<NSString *> *versions = [NSMutableArray arrayWithCapacity:self.supportedVersions.count];
    for (PBCrossIdentifierVersion *version in self.supportedVersions) {
        [versions addObject:version.name];
    }
    return [NSString stringWithFormat:@"<%@: %p; versions=[%@]; salt=%@; keychainGroup=%@; appGroup=%@; remote=%@>",
            NSStringFromClass([self class]),
            self,
            [versions componentsJoinedByString:@","],
            self.salt.length > 0 ? @"configured" : @"-",
            self.keychainAccessGroup ?: @"-",
            self.appGroupIdentifier ?: @"-",
            self.remoteConfiguration.enabled ? @"enabled" : @"disabled"];
}

@end
