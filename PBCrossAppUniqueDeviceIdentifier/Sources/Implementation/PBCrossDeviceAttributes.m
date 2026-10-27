//
//  PBCrossDeviceAttributes.m
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import "PBCrossDeviceAttributes.h"

PBCrossAttributeKey const PBCrossAttributeKeyBootTimeInSec = @"bootTimeInSec";
PBCrossAttributeKey const PBCrossAttributeKeyCountryCode = @"countryCode";
PBCrossAttributeKey const PBCrossAttributeKeyLanguage = @"language";
PBCrossAttributeKey const PBCrossAttributeKeyDeviceName = @"deviceName";
PBCrossAttributeKey const PBCrossAttributeKeySystemVersion = @"systemVersion";
PBCrossAttributeKey const PBCrossAttributeKeyMachine = @"machine";
PBCrossAttributeKey const PBCrossAttributeKeyCarrierInfo = @"carrierInfo";
PBCrossAttributeKey const PBCrossAttributeKeyMemory = @"memory";
PBCrossAttributeKey const PBCrossAttributeKeyDisk = @"disk";
PBCrossAttributeKey const PBCrossAttributeKeySysFileTime = @"sysFileTime";
PBCrossAttributeKey const PBCrossAttributeKeyModel = @"model";
PBCrossAttributeKey const PBCrossAttributeKeyTimeZone = @"timeZone";
PBCrossAttributeKey const PBCrossAttributeKeyMntID = @"mntId";
PBCrossAttributeKey const PBCrossAttributeKeyDeviceInitTime = @"deviceInitTime";
PBCrossAttributeKey const PBCrossAttributeKeyIDFV = @"idfv";
PBCrossAttributeKey const PBCrossAttributeKeyIDFAMD5 = @"idfa_md5";
PBCrossAttributeKey const PBCrossAttributeKeyScreenResolution = @"screenResolution";
PBCrossAttributeKey const PBCrossAttributeKeyProcessorCount = @"processorCount";
PBCrossAttributeKey const PBCrossAttributeKeyTimeZoneIdentifier = @"timeZoneIdentifier";
PBCrossAttributeKey const PBCrossAttributeKeySystemName = @"systemName";
PBCrossAttributeKey const PBCrossAttributeKeyCarrierMCC = @"carrierMCC";
PBCrossAttributeKey const PBCrossAttributeKeyCarrierMNC = @"carrierMNC";
PBCrossAttributeKey const PBCrossAttributeKeySimulator = @"simulator";

static NSDictionary<PBCrossAttributeKey, NSString *> *PBCrossSanitizedValues(NSDictionary *values)
{
    if (![values isKindOfClass:[NSDictionary class]] || values.count == 0) {
        return @{};
    }

    NSMutableDictionary<PBCrossAttributeKey, NSString *> *result = [NSMutableDictionary dictionaryWithCapacity:values.count];
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        if (![key isKindOfClass:[NSString class]]) {
            return;
        }

        NSString *stringValue = nil;
        if ([value isKindOfClass:[NSString class]]) {
            stringValue = value;
        } else if ([value isKindOfClass:[NSNumber class]]) {
            stringValue = [value stringValue];
        } else {
            return;
        }

        stringValue = [stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (stringValue.length > 0) {
            result[key] = stringValue;
        }
    }];
    return [result copy];
}

@interface PBCrossDeviceAttributes ()

@property (nonatomic, copy, readwrite) NSDictionary<PBCrossAttributeKey, NSString *> *values;
@property (nonatomic, copy, readwrite, nullable) NSString *advertisingIdentifier;

- (instancetype)initWithValues:(NSDictionary *)values advertisingIdentifier:(nullable NSString *)advertisingIdentifier;

@end

@implementation PBCrossDeviceAttributes

+ (instancetype)attributesWithValues:(NSDictionary<PBCrossAttributeKey, NSString *> *)values
{
    return [[self alloc] initWithValues:values advertisingIdentifier:nil];
}

+ (instancetype)attributesWithValues:(NSDictionary<PBCrossAttributeKey, NSString *> *)values
             advertisingIdentifier:(nullable NSString *)advertisingIdentifier
{
    return [[self alloc] initWithValues:values advertisingIdentifier:advertisingIdentifier];
}

+ (nullable instancetype)attributesWithDictionaryRepresentation:(NSDictionary<NSString *, id> *)dictionary
{
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return [[self alloc] initWithValues:PBCrossSanitizedValues(dictionary) advertisingIdentifier:nil];
}

- (instancetype)initWithValues:(NSDictionary *)values advertisingIdentifier:(nullable NSString *)advertisingIdentifier
{
    self = [super init];
    if (self) {
        _values = [PBCrossSanitizedValues(values) copy];
        NSString *identifier = [advertisingIdentifier stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _advertisingIdentifier = identifier.length > 0 ? [identifier copy] : nil;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    return self;
}

- (nullable NSString *)valueForKey:(PBCrossAttributeKey)key
{
    if (![key isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *value = self.values[key];
    return value.length > 0 ? value : nil;
}

#pragma mark - CAID 兼容字段

- (nullable NSString *)bootTimeInSec
{
    return [self valueForKey:PBCrossAttributeKeyBootTimeInSec];
}

- (nullable NSString *)countryCode
{
    return [self valueForKey:PBCrossAttributeKeyCountryCode];
}

- (nullable NSString *)language
{
    return [self valueForKey:PBCrossAttributeKeyLanguage];
}

- (nullable NSString *)deviceNameMD5
{
    return [self valueForKey:PBCrossAttributeKeyDeviceName];
}

- (nullable NSString *)systemVersion
{
    return [self valueForKey:PBCrossAttributeKeySystemVersion];
}

- (nullable NSString *)machine
{
    return [self valueForKey:PBCrossAttributeKeyMachine];
}

- (nullable NSString *)carrierInfo
{
    return [self valueForKey:PBCrossAttributeKeyCarrierInfo];
}

- (nullable NSString *)memory
{
    return [self valueForKey:PBCrossAttributeKeyMemory];
}

- (nullable NSString *)disk
{
    return [self valueForKey:PBCrossAttributeKeyDisk];
}

- (nullable NSString *)sysFileTime
{
    return [self valueForKey:PBCrossAttributeKeySysFileTime];
}

- (nullable NSString *)hardwareModel
{
    return [self valueForKey:PBCrossAttributeKeyModel];
}

- (nullable NSString *)timeZone
{
    return [self valueForKey:PBCrossAttributeKeyTimeZone];
}

- (nullable NSString *)mntID
{
    return [self valueForKey:PBCrossAttributeKeyMntID];
}

- (nullable NSString *)deviceInitTime
{
    return [self valueForKey:PBCrossAttributeKeyDeviceInitTime];
}

#pragma mark - 扩展字段

- (nullable NSString *)identifierForVendor
{
    return [self valueForKey:PBCrossAttributeKeyIDFV];
}

- (nullable NSString *)advertisingIdentifierMD5
{
    return [self valueForKey:PBCrossAttributeKeyIDFAMD5];
}

- (nullable NSString *)screenResolution
{
    return [self valueForKey:PBCrossAttributeKeyScreenResolution];
}

- (NSInteger)processorCount
{
    return [[self valueForKey:PBCrossAttributeKeyProcessorCount] integerValue];
}

- (nullable NSString *)timeZoneIdentifier
{
    return [self valueForKey:PBCrossAttributeKeyTimeZoneIdentifier];
}

- (nullable NSString *)systemName
{
    return [self valueForKey:PBCrossAttributeKeySystemName];
}

- (nullable NSString *)carrierMobileCountryCode
{
    return [self valueForKey:PBCrossAttributeKeyCarrierMCC];
}

- (nullable NSString *)carrierMobileNetworkCode
{
    return [self valueForKey:PBCrossAttributeKeyCarrierMNC];
}

- (BOOL)isSimulator
{
    return [[self valueForKey:PBCrossAttributeKeySimulator] boolValue];
}

#pragma mark - 序列化

+ (NSArray<PBCrossAttributeKey> *)CAIDCompatibleAttributeKeys
{
    static NSArray<PBCrossAttributeKey> *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @[
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
            PBCrossAttributeKeyMntID,
            PBCrossAttributeKeyDeviceInitTime,
        ];
    });
    return keys;
}

- (NSDictionary<NSString *, NSString *> *)CAIDDeviceInfoDictionaryIncludingEmptyValues:(BOOL)includingEmptyValues
{
    NSMutableDictionary<NSString *, NSString *> *dictionary = [NSMutableDictionary dictionaryWithCapacity:14];
    for (PBCrossAttributeKey key in [PBCrossDeviceAttributes CAIDCompatibleAttributeKeys]) {
        NSString *value = [self valueForKey:key];
        if (value.length > 0 || includingEmptyValues) {
            dictionary[key] = value ?: @"";
        }
    }
    return [dictionary copy];
}

- (NSDictionary<NSString *, id> *)dictionaryRepresentation
{
    return [self.values copy];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[PBCrossDeviceAttributes class]]) {
        return NO;
    }
    PBCrossDeviceAttributes *other = object;
    return [self.values isEqualToDictionary:other.values]
        && ((self.advertisingIdentifier == other.advertisingIdentifier)
            || [self.advertisingIdentifier isEqualToString:other.advertisingIdentifier]);
}

- (NSUInteger)hash
{
    return self.values.hash ^ self.advertisingIdentifier.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; machine=%@; model=%@; keys=%lu>",
            NSStringFromClass([self class]),
            self,
            self.machine ?: @"-",
            self.hardwareModel ?: @"-",
            (unsigned long)self.values.count];
}

@end
