//
//  PBCrossRemoteResolver.m
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import "PBCrossRemoteResolver.h"
#import "PBCrossConfiguration.h"
#import "PBCrossDeviceAttributes.h"
#import "PBCrossIdentityStore.h"
#import "PBCrossIdentifier.h"
#import "PBCrossRSACrypto.h"
#import "PBCrossErrors.h"
#import "PBCrossLogging.h"

@interface PBCrossRemoteResolver ()

@property (nonatomic, copy, readwrite) PBCrossConfiguration *configuration;
@property (nonatomic, strong) PBCrossIdentityStore *store;

@end

@implementation PBCrossRemoteResolver {
    SecKeyRef _publicKey;
}

- (instancetype)initWithConfiguration:(PBCrossConfiguration *)configuration
                                store:(PBCrossIdentityStore *)store
{
    self = [super init];
    if (self) {
        _configuration = [configuration copy] ?: [[PBCrossConfiguration alloc] init];
        _store = store;
        _publicKey = NULL;
    }
    return self;
}

- (void)dealloc
{
    if (_publicKey != NULL) {
        CFRelease(_publicKey);
        _publicKey = NULL;
    }
}

#pragma mark - Cache

- (nullable NSArray<PBCrossIdentifier *> *)identifiersFromDictionaries:(NSArray *)dictionaries
{
    NSMutableArray<PBCrossIdentifier *> *identifiers = [NSMutableArray array];
    for (id object in dictionaries) {
        if (![object isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSDictionary *dictionary = object;
        id value = dictionary[@"id"] ?: dictionary[@"caid"] ?: dictionary[@"value"];
        id version = dictionary[@"version"];
        if (![value isKindOfClass:[NSString class]] || ![version isKindOfClass:[NSString class]]) {
            continue;
        }
        PBCrossIdentifier *identifier = [PBCrossIdentifier identifierWithValue:value
                                                                       version:version
                                                                          kind:PBCrossIdentifierKindRemote];
        if (identifier) {
            [identifiers addObject:identifier];
        }
    }
    return [identifiers copy];
}

- (nullable NSDictionary<NSString *, id> *)cacheDictionary
{
    return [self.store remoteCache];
}

- (nullable NSArray<PBCrossIdentifier *> *)cachedIdentifiersWithResolvedAt:(NSDate **)resolvedAt
{
    NSDictionary<NSString *, id> *cache = [self cacheDictionary];
    if (!cache) {
        return nil;
    }

    NSArray *rawIdentifiers = cache[@"identifiers"];
    if (![rawIdentifiers isKindOfClass:[NSArray class]]) {
        return nil;
    }

    NSArray<PBCrossIdentifier *> *identifiers = [self identifiersFromDictionaries:rawIdentifiers];
    if (identifiers.count == 0) {
        return nil;
    }

    id resolvedAtValue = cache[@"resolved_at"];
    if ([resolvedAtValue isKindOfClass:[NSNumber class]]) {
        if (resolvedAt) {
            *resolvedAt = [NSDate dateWithTimeIntervalSince1970:[resolvedAtValue doubleValue]];
        }
    } else if (resolvedAt) {
        *resolvedAt = nil;
    }
    return identifiers;
}

- (BOOL)hasFreshCache
{
    NSDate *resolvedAt = nil;
    NSArray<PBCrossIdentifier *> *identifiers = [self cachedIdentifiersWithResolvedAt:&resolvedAt];
    if (identifiers.count == 0 || resolvedAt == nil) {
        return NO;
    }

    NSTimeInterval age = [NSDate date].timeIntervalSince1970 - resolvedAt.timeIntervalSince1970;
    return age >= -60 && age < self.configuration.remoteConfiguration.cacheTimeToLive;
}

#pragma mark - Resolve

- (void)resolveIdentifiersWithAttributes:(PBCrossDeviceAttributes *)attributes
                              completion:(PBCrossRemoteResolutionCompletion)completion
{
    PBCrossRemoteConfiguration *remoteConfiguration = self.configuration.remoteConfiguration;
    if (!remoteConfiguration.enabled) {
        [self finishWithIdentifiers:nil resolvedAt:nil
                              error:PBCrossErrorMake(PBCrossRemoteErrorNotConfigured,
                                                     @"%@", PBCrossRemoteErrorDescription(PBCrossRemoteErrorNotConfigured))
                         completion:completion];
        return;
    }

    NSError *configurationError = nil;
    if (![remoteConfiguration validateWithError:&configurationError]) {
        [self finishWithIdentifiers:nil resolvedAt:nil
                              error:configurationError ?: PBCrossErrorMake(PBCrossRemoteErrorNotConfigured,
                                                                           @"%@", PBCrossRemoteErrorDescription(PBCrossRemoteErrorNotConfigured))
                         completion:completion];
        return;
    }

    if (remoteConfiguration.requiresUserConsent && !remoteConfiguration.hasUserConsent) {
        [self finishWithIdentifiers:nil resolvedAt:nil
                              error:PBCrossErrorMake(PBCrossRemoteErrorConsentRequired,
                                                     @"%@", PBCrossRemoteErrorDescription(PBCrossRemoteErrorConsentRequired))
                         completion:completion];
        return;
    }

    NSDate *cachedResolvedAt = nil;
    NSArray<PBCrossIdentifier *> *cachedIdentifiers = [self cachedIdentifiersWithResolvedAt:&cachedResolvedAt];
    if ([self hasFreshCache]) {
        PBCrossLog(self.configuration, @"命中远端 ID 缓存: %lu 个版本", (unsigned long)cachedIdentifiers.count);
        [self finishWithIdentifiers:cachedIdentifiers resolvedAt:cachedResolvedAt error:nil completion:completion];
        return;
    }

    NSArray<NSString *> *requiredKeys = @[
        PBCrossAttributeKeyBootTimeInSec,
        PBCrossAttributeKeyCountryCode,
        PBCrossAttributeKeyLanguage,
        PBCrossAttributeKeyDeviceName,
        PBCrossAttributeKeySystemVersion,
        PBCrossAttributeKeyMachine,
        PBCrossAttributeKeyCarrierInfo,
        PBCrossAttributeKeyMemory,
        PBCrossAttributeKeyDisk,
        PBCrossAttributeKeySysFileTime,
        PBCrossAttributeKeyModel,
        PBCrossAttributeKeyTimeZone,
    ];
    NSMutableArray<NSString *> *missingKeys = [NSMutableArray array];
    for (NSString *key in requiredKeys) {
        if ([attributes valueForKey:key].length == 0) {
            [missingKeys addObject:key];
        }
    }
    if (missingKeys.count > 0) {
        [self finishWithIdentifiers:nil resolvedAt:nil
                              error:PBCrossErrorMake(PBCrossRemoteErrorMissingDeviceAttributes,
                                                     @"%@: %@",
                                                     PBCrossRemoteErrorDescription(PBCrossRemoteErrorMissingDeviceAttributes),
                                                     [missingKeys componentsJoinedByString:@","])
                         completion:completion];
        return;
    }

    NSError *publicKeyError = nil;
    SecKeyRef publicKey = [self resolvedPublicKeyWithError:&publicKeyError];
    if (publicKey == NULL) {
        [self finishWithIdentifiers:nil resolvedAt:nil error:publicKeyError completion:completion];
        return;
    }

    NSMutableDictionary<NSString *, NSString *> *deviceInfo =
        [[attributes CAIDDeviceInfoDictionaryIncludingEmptyValues:YES] mutableCopy];
    // mntId / deviceInitTime 在 CAID 协议中为可选项，未采集到时不传，避免被严格校验拒绝。
    if (deviceInfo[PBCrossAttributeKeyMntID].length == 0) {
        [deviceInfo removeObjectForKey:PBCrossAttributeKeyMntID];
    }
    if (deviceInfo[PBCrossAttributeKeyDeviceInitTime].length == 0) {
        [deviceInfo removeObjectForKey:PBCrossAttributeKeyDeviceInitTime];
    }
    NSError *jsonError = nil;
    NSData *plainData = [NSJSONSerialization dataWithJSONObject:deviceInfo options:0 error:&jsonError];
    if (!plainData) {
        [self finishWithIdentifiers:nil resolvedAt:nil
                              error:PBCrossErrorMake(PBCrossRemoteErrorEncryptionFailed,
                                                     @"设备信息序列化失败: %@", jsonError.localizedDescription ?: @"unknown")
                         completion:completion];
        return;
    }

    NSError *encryptionError = nil;
    NSData *encryptedData = [PBCrossRSACrypto encryptData:plainData publicKey:publicKey error:&encryptionError];
    if (!encryptedData) {
        [self finishWithIdentifiers:nil resolvedAt:nil error:encryptionError completion:completion];
        return;
    }

    NSDictionary<NSString *, id> *body = @{
        @"dev_id": remoteConfiguration.developerID,
        @"encrypted_device_info": [encryptedData base64EncodedStringWithOptions:0],
    };
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&jsonError];
    if (!bodyData) {
        [self finishWithIdentifiers:nil resolvedAt:nil
                              error:PBCrossErrorMake(PBCrossRemoteErrorEncryptionFailed,
                                                     @"请求序列化失败: %@", jsonError.localizedDescription ?: @"unknown")
                         completion:completion];
        return;
    }

    if (![self.store registerRemoteRequestIfAllowed:remoteConfiguration.dailyRequestLimit]) {
        [self finishWithIdentifiers:nil resolvedAt:nil
                              error:PBCrossErrorMake(PBCrossRemoteErrorDailyLimitExceeded,
                                                     @"%@(%lu)",
                                                     PBCrossRemoteErrorDescription(PBCrossRemoteErrorDailyLimitExceeded),
                                                     (unsigned long)remoteConfiguration.dailyRequestLimit)
                         completion:completion];
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:remoteConfiguration.endpointURL
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:remoteConfiguration.requestTimeout];
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyData;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];

    PBCrossLog(self.configuration, @"请求远端 ID 服务: %@", remoteConfiguration.endpointURL.absoluteString);

    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *data,
                                                                                     NSURLResponse *response,
                                                                                     NSError *networkError) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [strongSelf handleResponseData:data response:response networkError:networkError completion:completion];
    }];
    [task resume];
}

- (nullable SecKeyRef)resolvedPublicKeyWithError:(NSError **)error
{
    @synchronized(self) {
        if (_publicKey == NULL) {
            _publicKey = [PBCrossRSACrypto PBCopyPublicKeyFromString:self.configuration.remoteConfiguration.publicKey
                                                               error:error];
        }
        return _publicKey;
    }
}

- (void)handleResponseData:(nullable NSData *)data
                  response:(nullable NSURLResponse *)response
              networkError:(nullable NSError *)networkError
                completion:(nullable PBCrossRemoteResolutionCompletion)completion
{
    if (networkError) {
        [self finishWithIdentifiers:nil resolvedAt:nil
                              error:PBCrossErrorMake(PBCrossRemoteErrorNetwork,
                                                     @"%@: %@",
                                                     PBCrossRemoteErrorDescription(PBCrossRemoteErrorNetwork),
                                                     networkError.localizedDescription ?: @"unknown")
                         completion:completion];
        return;
    }

    NSInteger statusCode = 0;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        statusCode = ((NSHTTPURLResponse *)response).statusCode;
    }
    if (statusCode < 200 || statusCode >= 300) {
        [self finishWithIdentifiers:nil resolvedAt:nil
                              error:PBCrossErrorMake(PBCrossRemoteErrorNetwork,
                                                     @"%@: HTTP %ld",
                                                     PBCrossRemoteErrorDescription(PBCrossRemoteErrorNetwork),
                                                     (long)statusCode)
                         completion:completion];
        return;
    }

    id responseObject = data.length > 0
        ? [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]
        : nil;
    if (![responseObject isKindOfClass:[NSDictionary class]]) {
        [self finishWithIdentifiers:nil resolvedAt:nil
                              error:PBCrossErrorMake(PBCrossRemoteErrorInvalidResponse,
                                                     @"%@: 响应不是 JSON 对象",
                                                     PBCrossRemoteErrorDescription(PBCrossRemoteErrorInvalidResponse))
                         completion:completion];
        return;
    }

    NSDictionary *responseDictionary = responseObject;
    id codeValue = responseDictionary[@"code"];
    NSInteger code = [codeValue respondsToSelector:@selector(integerValue)] ? [codeValue integerValue] : -1;
    if (code != 0) {
        NSString *message = [responseDictionary[@"message"] isKindOfClass:[NSString class]]
            ? responseDictionary[@"message"] : @"";
        [self finishWithIdentifiers:nil resolvedAt:nil
                              error:PBCrossErrorMake(PBCrossRemoteErrorServerCode,
                                                     @"%@: code=%@ %@",
                                                     PBCrossRemoteErrorDescription(PBCrossRemoteErrorServerCode),
                                                     codeValue ?: @"-",
                                                     message)
                         completion:completion];
        return;
    }

    id payload = responseDictionary[@"data"];
    if (payload == nil) {
        [self finishWithIdentifiers:nil resolvedAt:nil
                              error:PBCrossErrorMake(PBCrossRemoteErrorInvalidResponse,
                                                     @"%@: 缺少 data",
                                                     PBCrossRemoteErrorDescription(PBCrossRemoteErrorInvalidResponse))
                         completion:completion];
        return;
    }

    NSArray *rawIdentifiers = nil;
    if ([payload isKindOfClass:[NSArray class]]) {
        rawIdentifiers = payload;
    } else if ([payload isKindOfClass:[NSDictionary class]]) {
        rawIdentifiers = @[payload];
    } else if ([payload isKindOfClass:[NSString class]]) {
        NSError *decryptionError = nil;
        NSData *cipherData = [[NSData alloc] initWithBase64EncodedString:payload
                                                                 options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSData *plainData = cipherData.length > 0
            ? [PBCrossRSACrypto decryptData:cipherData publicKey:_publicKey error:&decryptionError]
            : nil;
        if (!plainData) {
            [self finishWithIdentifiers:nil resolvedAt:nil
                                  error:decryptionError ?: PBCrossErrorMake(PBCrossRemoteErrorDecryptionFailed,
                                                                            @"%@",
                                                                            PBCrossRemoteErrorDescription(PBCrossRemoteErrorDecryptionFailed))
                             completion:completion];
            return;
        }

        id plainObject = [NSJSONSerialization JSONObjectWithData:plainData options:0 error:NULL];
        if ([plainObject isKindOfClass:[NSArray class]]) {
            rawIdentifiers = plainObject;
        } else if ([plainObject isKindOfClass:[NSDictionary class]]) {
            rawIdentifiers = @[plainObject];
        }
    }

    if (![rawIdentifiers isKindOfClass:[NSArray class]]) {
        [self finishWithIdentifiers:nil resolvedAt:nil
                              error:PBCrossErrorMake(PBCrossRemoteErrorInvalidResponse,
                                                     @"%@: data 格式错误",
                                                     PBCrossRemoteErrorDescription(PBCrossRemoteErrorInvalidResponse))
                         completion:completion];
        return;
    }

    NSMutableArray<PBCrossIdentifier *> *identifiers =
        [[self identifiersFromDictionaries:rawIdentifiers] mutableCopy];
    if (identifiers.count == 0) {
        [self finishWithIdentifiers:nil resolvedAt:nil
                              error:PBCrossErrorMake(PBCrossRemoteErrorInvalidResponse,
                                                     @"%@: 未解析到有效 ID",
                                                     PBCrossRemoteErrorDescription(PBCrossRemoteErrorInvalidResponse))
                         completion:completion];
        return;
    }

    [identifiers sortUsingComparator:^NSComparisonResult(PBCrossIdentifier *left, PBCrossIdentifier *right) {
        return [right.version compare:left.version];
    }];
    if (identifiers.count > 2) {
        [identifiers removeObjectsInRange:NSMakeRange(2, identifiers.count - 2)];
    }

    NSDate *resolvedAt = [NSDate date];
    NSMutableArray<NSDictionary<NSString *, id> *> *cacheIdentifiers =
        [NSMutableArray arrayWithCapacity:identifiers.count];
    for (PBCrossIdentifier *identifier in identifiers) {
        [cacheIdentifiers addObject:@{
            @"id": identifier.value,
            @"version": identifier.version,
        }];
    }
    [self.store setRemoteCache:@{
        @"resolved_at": @([resolvedAt timeIntervalSince1970]),
        @"identifiers": cacheIdentifiers,
    }];

    PBCrossLog(self.configuration, @"远端 ID 解析成功: %lu 个版本", (unsigned long)identifiers.count);
    [self finishWithIdentifiers:[identifiers copy] resolvedAt:resolvedAt error:nil completion:completion];
}

- (void)finishWithIdentifiers:(nullable NSArray<PBCrossIdentifier *> *)identifiers
                   resolvedAt:(nullable NSDate *)resolvedAt
                        error:(nullable NSError *)error
                   completion:(nullable PBCrossRemoteResolutionCompletion)completion
{
    if (!completion) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(identifiers, resolvedAt, error);
    });
}

@end
