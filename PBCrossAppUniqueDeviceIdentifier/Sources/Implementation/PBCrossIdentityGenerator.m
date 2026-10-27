//
//  PBCrossIdentityGenerator.m
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import "PBCrossIdentityGenerator.h"
#import "PBCrossConfiguration.h"
#import "PBCrossIdentifier.h"
#import "PBCrossCrypto.h"

static NSSet<NSString *> *PBCrossNumericAttributeKeys(void)
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

/// 去掉数字字符串的前导零，保证不同语言/序列化方式得到的 "0400" 与 "400" 一致。
static NSString *PBCrossNormalizedNumericString(NSString *value)
{
    if (value.length == 0) {
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

static NSString *PBCrossNormalizedAttributeValue(PBCrossAttributeKey key, NSString *rawValue)
{
    if (rawValue.length == 0) {
        return @"";
    }

    NSString *value = [rawValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // "|" 是规范化字符串的分隔符，换行会破坏可读性；统一替换为空格。
    value = [value stringByReplacingOccurrencesOfString:@"|" withString:@" "];
    value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    value = [value stringByReplacingOccurrencesOfString:@"\r" withString:@" "];

    if ([PBCrossNumericAttributeKeys() containsObject:key]) {
        value = PBCrossNormalizedNumericString(value);
    }
    return value;
}

@implementation PBCrossIdentityGenerator

+ (NSArray<PBCrossIdentifier *> *)fingerprintIdentifiersWithAttributes:(PBCrossDeviceAttributes *)attributes
                                                        configuration:(PBCrossConfiguration *)configuration
{
    NSMutableArray<PBCrossIdentifier *> *identifiers =
        [NSMutableArray arrayWithCapacity:configuration.supportedVersions.count];

    for (PBCrossIdentifierVersion *version in configuration.supportedVersions) {
        if (![version isKindOfClass:[PBCrossIdentifierVersion class]] || version.name.length == 0) {
            continue;
        }

        NSString *salt = version.salt.length > 0 ? version.salt : configuration.salt;
        NSString *canonicalString = [self canonicalStringForVersion:version attributes:attributes];
        NSString *identifierValue = [self identifierStringForCanonicalString:canonicalString salt:salt];
        if (identifierValue.length == 0) {
            continue;
        }

        PBCrossIdentifier *identifier = [PBCrossIdentifier identifierWithValue:identifierValue
                                                                       version:version.name
                                                                          kind:PBCrossIdentifierKindFingerprint];
        if (identifier) {
            [identifiers addObject:identifier];
        }
    }

    return [identifiers copy];
}

+ (NSString *)canonicalStringForVersion:(PBCrossIdentifierVersion *)version
                             attributes:(PBCrossDeviceAttributes *)attributes
{
    NSArray<PBCrossAttributeKey> *keys =
        [version.attributeKeys sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray<NSString *> *pairs = [NSMutableArray arrayWithCapacity:keys.count];

    for (PBCrossAttributeKey key in keys) {
        NSString *value = [attributes valueForKey:key] ?: @"";
        [pairs addObject:[NSString stringWithFormat:@"%@=%@",
                          key,
                          PBCrossNormalizedAttributeValue(key, value)]];
    }

    return [NSString stringWithFormat:@"%@|%@|%@",
            PBCrossIdentifierAlgorithmName,
            version.name,
            [pairs componentsJoinedByString:@"|"]];
}

+ (NSString *)identifierStringForCanonicalString:(NSString *)canonicalString salt:(NSString *)salt
{
    if (canonicalString.length == 0 || salt.length == 0) {
        return @"";
    }

    NSString *hash = [PBCrossCrypto HMACSHA256HexString:canonicalString key:salt];
    if (hash.length <= 32) {
        return hash;
    }
    return [hash substringToIndex:32];
}

@end
