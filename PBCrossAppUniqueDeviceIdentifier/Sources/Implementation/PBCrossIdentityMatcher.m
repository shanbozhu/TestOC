//
//  PBCrossIdentityMatcher.m
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import "PBCrossIdentityMatcher.h"
#import "PBCrossConfiguration.h"

NSString *PBCrossIdentityMatchReasonDescription(PBCrossIdentityMatchReason reason)
{
    switch (reason) {
        case PBCrossIdentityMatchReasonNone:
            return @"none";
        case PBCrossIdentityMatchReasonSharedIdentifier:
            return @"shared_identifier";
        case PBCrossIdentityMatchReasonVersionedIdentifier:
            return @"versioned_identifier";
        case PBCrossIdentityMatchReasonAdvertisingIdentifier:
            return @"advertising_identifier";
        case PBCrossIdentityMatchReasonDeviceAttributes:
            return @"device_attributes";
    }
    return @"none";
}

static NSDictionary<PBCrossAttributeKey, NSNumber *> *PBCrossDefaultAttributeWeights(void)
{
    static NSDictionary<PBCrossAttributeKey, NSNumber *> *weights;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        weights = @{
            PBCrossAttributeKeyMachine: @3.0,
            PBCrossAttributeKeyModel: @2.0,
            PBCrossAttributeKeyDisk: @2.0,
            PBCrossAttributeKeyMemory: @2.0,
            PBCrossAttributeKeyScreenResolution: @2.0,
            PBCrossAttributeKeyProcessorCount: @1.0,
            PBCrossAttributeKeyDeviceInitTime: @3.0,
            PBCrossAttributeKeySysFileTime: @2.0,
            PBCrossAttributeKeyMntID: @3.0,
            PBCrossAttributeKeyBootTimeInSec: @1.0,
            PBCrossAttributeKeySystemVersion: @1.0,
            PBCrossAttributeKeyCountryCode: @0.5,
            PBCrossAttributeKeyLanguage: @0.5,
            PBCrossAttributeKeyTimeZone: @0.5,
            PBCrossAttributeKeyCarrierInfo: @0.5,
            PBCrossAttributeKeyDeviceName: @1.0,
        };
    });
    return weights;
}

static NSSet<NSString *> *PBCrossComparableNumericKeys(void)
{
    static NSSet<NSString *> *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = [NSSet setWithObjects:
                PBCrossAttributeKeyBootTimeInSec,
                PBCrossAttributeKeyMemory,
                PBCrossAttributeKeyDisk,
                PBCrossAttributeKeyTimeZone,
                PBCrossAttributeKeyProcessorCount,
                nil];
    });
    return keys;
}

static NSString *PBCrossComparableAttributeValue(NSString *rawValue, PBCrossAttributeKey key)
{
    if (rawValue.length == 0) {
        return @"";
    }

    NSString *value = [rawValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![PBCrossComparableNumericKeys() containsObject:key] || value.length == 0) {
        return value;
    }

    NSString *sign = @"";
    NSUInteger start = 0;
    unichar first = [value characterAtIndex:0];
    if (first == '-' || first == '+') {
        sign = first == '-' ? @"-" : @"";
        start = 1;
    }
    if (start >= value.length) {
        return value;
    }

    for (NSUInteger index = start; index < value.length; index++) {
        unichar character = [value characterAtIndex:index];
        if (character < '0' || character > '9') {
            return value;
        }
    }

    NSString *digits = [value substringFromIndex:start];
    NSUInteger index = 0;
    while (index + 1 < digits.length && [digits characterAtIndex:index] == '0') {
        index++;
    }
    if (index > 0) {
        digits = [digits substringFromIndex:index];
    }
    return [sign stringByAppendingString:digits];
}

@interface PBCrossIdentityMatchResult ()

@property (nonatomic, assign, readwrite) BOOL matched;
@property (nonatomic, assign, readwrite) double confidence;
@property (nonatomic, assign, readwrite) double attributeSimilarity;
@property (nonatomic, assign, readwrite) PBCrossIdentityMatchReason reason;
@property (nonatomic, copy, readwrite, nullable) NSString *matchedIdentifier;
@property (nonatomic, copy, readwrite, nullable) NSString *matchedVersion;
@property (nonatomic, copy, readwrite) NSDictionary<PBCrossAttributeKey, NSString *> *attributeMatches;

- (instancetype)initWithMatched:(BOOL)matched
                     confidence:(double)confidence
            attributeSimilarity:(double)attributeSimilarity
                         reason:(PBCrossIdentityMatchReason)reason
              matchedIdentifier:(nullable NSString *)matchedIdentifier
                 matchedVersion:(nullable NSString *)matchedVersion
               attributeMatches:(NSDictionary<PBCrossAttributeKey, NSString *> *)attributeMatches;

@end

@implementation PBCrossIdentityMatchResult

- (instancetype)initWithMatched:(BOOL)matched
                     confidence:(double)confidence
            attributeSimilarity:(double)attributeSimilarity
                         reason:(PBCrossIdentityMatchReason)reason
              matchedIdentifier:(nullable NSString *)matchedIdentifier
                 matchedVersion:(nullable NSString *)matchedVersion
               attributeMatches:(NSDictionary<PBCrossAttributeKey, NSString *> *)attributeMatches
{
    self = [super init];
    if (self) {
        _matched = matched;
        _confidence = confidence;
        _attributeSimilarity = attributeSimilarity;
        _reason = reason;
        _matchedIdentifier = [matchedIdentifier copy];
        _matchedVersion = [matchedVersion copy];
        _attributeMatches = [attributeMatches copy] ?: @{};
    }
    return self;
}

- (NSDictionary<NSString *, id> *)dictionaryRepresentation
{
    NSMutableDictionary<NSString *, id> *dictionary = [@{
        @"matched": @(self.matched),
        @"confidence": @(self.confidence),
        @"attribute_similarity": @(self.attributeSimilarity),
        @"reason": PBCrossIdentityMatchReasonDescription(self.reason),
        @"attributes": self.attributeMatches,
    } mutableCopy];

    if (self.matchedIdentifier.length > 0) {
        dictionary[@"matched_identifier"] = self.matchedIdentifier;
    }
    if (self.matchedVersion.length > 0) {
        dictionary[@"matched_version"] = self.matchedVersion;
    }
    return [dictionary copy];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; matched=%@; reason=%@; confidence=%.3f; similarity=%.3f>",
            NSStringFromClass([self class]),
            self,
            self.matched ? @"YES" : @"NO",
            PBCrossIdentityMatchReasonDescription(self.reason),
            self.confidence,
            self.attributeSimilarity];
}

@end

@interface PBCrossIdentityMatcher ()

- (NSDictionary<PBCrossAttributeKey, NSNumber *> *)resolvedAttributeWeights;
- (PBCrossIdentityMatchResult *)emptyResult;

@end

@implementation PBCrossIdentityMatcher

- (instancetype)init
{
    self = [super init];
    if (self) {
        _attributeMatchThreshold = 0.9;
        _minimumComparableAttributeWeight = 6.0;
        _matchesAdvertisingIdentifier = YES;
    }
    return self;
}

- (PBCrossIdentityMatchResult *)matchIdentity:(PBCrossIdentity *)identity
                                withIdentity:(PBCrossIdentity *)otherIdentity
{
    if (!identity || !otherIdentity) {
        return [self emptyResult];
    }

    // 1. 共享自建 ID
    if (identity.sharedID.length > 0
        && otherIdentity.sharedID.length > 0
        && [identity.sharedID caseInsensitiveCompare:otherIdentity.sharedID] == NSOrderedSame) {
        return [[PBCrossIdentityMatchResult alloc] initWithMatched:YES
                                                        confidence:1.0
                                               attributeSimilarity:0
                                                            reason:PBCrossIdentityMatchReasonSharedIdentifier
                                                 matchedIdentifier:identity.sharedID
                                                    matchedVersion:nil
                                                  attributeMatches:@{}];
    }

    // 2. 任一版本 ID
    PBCrossIdentifier *firstIdentifier = nil;
    for (PBCrossIdentifier *identifier in identity.allIdentifiers) {
        for (PBCrossIdentifier *otherIdentifier in otherIdentity.allIdentifiers) {
            if ([identifier.value caseInsensitiveCompare:otherIdentifier.value] == NSOrderedSame) {
                firstIdentifier = identifier;
                break;
            }
        }
        if (firstIdentifier) {
            break;
        }
    }
    if (firstIdentifier) {
        return [[PBCrossIdentityMatchResult alloc] initWithMatched:YES
                                                        confidence:1.0
                                               attributeSimilarity:0
                                                            reason:PBCrossIdentityMatchReasonVersionedIdentifier
                                                 matchedIdentifier:firstIdentifier.value
                                                    matchedVersion:firstIdentifier.version
                                                  attributeMatches:@{}];
    }

    // 3. IDFA MD5（双方都必须已获授权且非全零）
    if (self.matchesAdvertisingIdentifier) {
        NSString *advertisingIdentifier = identity.attributes.advertisingIdentifierMD5;
        NSString *otherAdvertisingIdentifier = otherIdentity.attributes.advertisingIdentifierMD5;
        if (advertisingIdentifier.length > 0
            && otherAdvertisingIdentifier.length > 0
            && [advertisingIdentifier caseInsensitiveCompare:otherAdvertisingIdentifier] == NSOrderedSame) {
            return [[PBCrossIdentityMatchResult alloc] initWithMatched:YES
                                                            confidence:0.99
                                                   attributeSimilarity:0
                                                                reason:PBCrossIdentityMatchReasonAdvertisingIdentifier
                                                     matchedIdentifier:nil
                                                        matchedVersion:nil
                                                      attributeMatches:@{}];
        }
    }

    // 4. 设备属性相似度
    NSDictionary<PBCrossAttributeKey, NSNumber *> *weights = [self resolvedAttributeWeights];
    NSMutableDictionary<PBCrossAttributeKey, NSString *> *attributeMatches = [NSMutableDictionary dictionary];
    double comparableWeight = 0;
    double matchedWeight = 0;

    for (PBCrossAttributeKey key in weights) {
        double weight = weights[key].doubleValue;
        if (weight <= 0) {
            continue;
        }

        NSString *value = PBCrossComparableAttributeValue([identity.attributes valueForKey:key], key);
        NSString *otherValue = PBCrossComparableAttributeValue([otherIdentity.attributes valueForKey:key], key);
        if (value.length == 0 || otherValue.length == 0) {
            attributeMatches[key] = @"not_comparable";
            continue;
        }

        comparableWeight += weight;
        if ([value caseInsensitiveCompare:otherValue] == NSOrderedSame) {
            matchedWeight += weight;
            attributeMatches[key] = @"equal";
        } else {
            attributeMatches[key] = @"different";
        }
    }

    double similarity = comparableWeight > 0 ? matchedWeight / comparableWeight : 0;
    double threshold = MAX(0.0, MIN(1.0, self.attributeMatchThreshold));
    double minimumWeight = MAX(0.0, self.minimumComparableAttributeWeight);
    BOOL matched = comparableWeight >= minimumWeight && similarity >= threshold;

    return [[PBCrossIdentityMatchResult alloc] initWithMatched:matched
                                                    confidence:matched ? similarity : 0
                                           attributeSimilarity:similarity
                                                        reason:matched ? PBCrossIdentityMatchReasonDeviceAttributes : PBCrossIdentityMatchReasonNone
                                             matchedIdentifier:nil
                                                matchedVersion:nil
                                              attributeMatches:attributeMatches];
}

- (NSDictionary<PBCrossAttributeKey, NSNumber *> *)resolvedAttributeWeights
{
    NSMutableDictionary<PBCrossAttributeKey, NSNumber *> *weights =
        [PBCrossDefaultAttributeWeights() mutableCopy];
    [self.attributeWeights enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        if (![key isKindOfClass:[NSString class]] || ![value isKindOfClass:[NSNumber class]]) {
            return;
        }
        if ([value doubleValue] >= 0) {
            weights[key] = value;
        }
    }];
    return [weights copy];
}

- (PBCrossIdentityMatchResult *)emptyResult
{
    return [[PBCrossIdentityMatchResult alloc] initWithMatched:NO
                                                    confidence:0
                                           attributeSimilarity:0
                                                        reason:PBCrossIdentityMatchReasonNone
                                             matchedIdentifier:nil
                                                matchedVersion:nil
                                              attributeMatches:@{}];
}

@end
