//
//  PBCrossAdRequestAdapter.m
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import "PBCrossAdRequestAdapter.h"
#import "PBCrossConfiguration.h"

static BOOL PBCrossScreenPixelSize(PBCrossDeviceAttributes *attributes, NSInteger *width, NSInteger *height)
{
    NSString *resolution = attributes.screenResolution;
    if (resolution.length == 0) {
        return NO;
    }

    NSString *sizePart = [[resolution componentsSeparatedByString:@"@"] firstObject];
    NSArray<NSString *> *dimensions = [sizePart componentsSeparatedByString:@"x"];
    if (dimensions.count != 2) {
        return NO;
    }

    NSInteger parsedWidth = [dimensions[0] integerValue];
    NSInteger parsedHeight = [dimensions[1] integerValue];
    if (parsedWidth <= 0 || parsedHeight <= 0) {
        return NO;
    }

    if (width) {
        *width = parsedWidth;
    }
    if (height) {
        *height = parsedHeight;
    }
    return YES;
}

static NSString *PBCrossPDDCarrierValue(PBCrossDeviceAttributes *attributes)
{
    NSString *mobileCountryCode = attributes.carrierMobileCountryCode;
    NSString *mobileNetworkCode = attributes.carrierMobileNetworkCode;
    if ([mobileCountryCode isEqualToString:@"460"] && mobileNetworkCode.length > 0) {
        NSSet<NSString *> *chinaMobile = [NSSet setWithObjects:@"00", @"02", @"07", @"08", nil];
        NSSet<NSString *> *chinaUnicom = [NSSet setWithObjects:@"01", @"06", @"09", nil];
        NSSet<NSString *> *chinaTelecom = [NSSet setWithObjects:@"03", @"05", @"11", nil];
        if ([chinaMobile containsObject:mobileNetworkCode]) {
            return @"mobile";
        }
        if ([chinaUnicom containsObject:mobileNetworkCode]) {
            return @"unicom";
        }
        if ([chinaTelecom containsObject:mobileNetworkCode]) {
            return @"telecom";
        }
    }

    NSString *carrierInfo = attributes.carrierInfo;
    if ([carrierInfo containsString:@"移动"]) {
        return @"mobile";
    }
    if ([carrierInfo containsString:@"联通"]) {
        return @"unicom";
    }
    if ([carrierInfo containsString:@"电信"]) {
        return @"telecom";
    }
    return @"unknown";
}

@implementation PBCrossAdRequestContext

- (instancetype)init
{
    self = [super init];
    if (self) {
        _deviceType = PBCrossDeviceTypePhone;
        _connectionType = PBCrossConnectionTypeUnknown;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    PBCrossAdRequestContext *context = [[[self class] allocWithZone:zone] init];
    context.userAgent = self.userAgent;
    context.ipAddress = self.ipAddress;
    context.ipv6Address = self.ipv6Address;
    context.deviceType = self.deviceType;
    context.connectionType = self.connectionType;
    context.modelName = self.modelName;
    context.carrier = self.carrier;
    context.advertisingIdentifier = self.advertisingIdentifier;
    context.paid = self.paid;
    context.paid14 = self.paid14;
    context.gaid = self.gaid;
    context.gaidMD5 = self.gaidMD5;
    context.screenWidth = self.screenWidth;
    context.screenHeight = self.screenHeight;
    context.additionalExtension = self.additionalExtension;
    return context;
}

@end

@implementation PBCrossAdRequestAdapter

+ (instancetype)adapterWithIdentity:(PBCrossIdentity *)identity
                            context:(PBCrossAdRequestContext *)context
{
    return [[self alloc] initWithIdentity:identity context:context];
}

- (instancetype)initWithIdentity:(PBCrossIdentity *)identity
                         context:(nullable PBCrossAdRequestContext *)context
{
    self = [super init];
    if (self) {
        _identity = identity;
        _context = [context copy] ?: [[PBCrossAdRequestContext alloc] init];
        _emitsRawAdvertisingIdentifier = NO;
        _emitsLegacyCAIDFields = NO;
    }
    return self;
}

#pragma mark - Device

- (NSDictionary<NSString *, id> *)deviceDictionary
{
    PBCrossDeviceAttributes *attributes = self.identity.attributes;
    NSMutableDictionary<NSString *, id> *device = [NSMutableDictionary dictionaryWithCapacity:24];

    if (self.context.userAgent.length > 0) {
        device[@"ua"] = self.context.userAgent;
    }
    if (self.context.ipAddress.length > 0) {
        device[@"ip"] = self.context.ipAddress;
    }
    if (self.context.ipv6Address.length > 0) {
        device[@"ipv6"] = self.context.ipv6Address;
    }

    device[@"devicetype"] = @(self.context.deviceType);
    device[@"make"] = @"apple";

    NSString *model = self.context.modelName.length > 0 ? self.context.modelName : attributes.machine;
    if (model.length > 0) {
        device[@"model"] = model;
    }

    device[@"os"] = @"ios";
    if (attributes.systemVersion.length > 0) {
        device[@"osv"] = attributes.systemVersion;
    }

    NSInteger screenWidth = self.context.screenWidth;
    NSInteger screenHeight = self.context.screenHeight;
    if (screenWidth <= 0 || screenHeight <= 0) {
        NSInteger attributeWidth = 0;
        NSInteger attributeHeight = 0;
        if (PBCrossScreenPixelSize(attributes, &attributeWidth, &attributeHeight)) {
            if (screenWidth <= 0) {
                screenWidth = attributeWidth;
            }
            if (screenHeight <= 0) {
                screenHeight = attributeHeight;
            }
        }
    }
    if (screenWidth > 0) {
        device[@"w"] = @(screenWidth);
    }
    if (screenHeight > 0) {
        device[@"h"] = @(screenHeight);
    }

    device[@"connectiontype"] = @(self.context.connectionType);
    device[@"carrier"] = self.context.carrier.length > 0
        ? self.context.carrier
        : PBCrossPDDCarrierValue(attributes);

    if (attributes.advertisingIdentifierMD5.length > 0) {
        device[@"idfa_md5"] = attributes.advertisingIdentifierMD5;
    }
    if (self.emitsRawAdvertisingIdentifier) {
        NSString *advertisingIdentifier = self.context.advertisingIdentifier.length > 0
            ? self.context.advertisingIdentifier
            : attributes.advertisingIdentifier;
        if (advertisingIdentifier.length > 0) {
            device[@"idfa"] = advertisingIdentifier;
        }
    }

    if (attributes.deviceInitTime.length > 0) {
        device[@"birth_time"] = attributes.deviceInitTime;
    }
    if (attributes.bootTimeInSec.length > 0) {
        device[@"boot_time"] = attributes.bootTimeInSec;
    }
    if (attributes.sysFileTime.length > 0) {
        device[@"update_time"] = attributes.sysFileTime;
    }
    if (self.identity.previousSystemUpdateTime.length > 0) {
        device[@"last_update_time"] = self.identity.previousSystemUpdateTime;
    }

    if (self.context.paid.length > 0) {
        device[@"paid"] = self.context.paid;
    }
    if (self.context.paid14.length > 0) {
        device[@"paid_1_4"] = self.context.paid14;
    }
    if (self.context.gaid.length > 0) {
        device[@"gaid"] = self.context.gaid;
    }
    if (self.context.gaidMD5.length > 0) {
        device[@"gaid_md5"] = self.context.gaidMD5;
    }

    NSString *extensionJSON = [self deviceExtensionJSONString];
    if (extensionJSON.length > 0) {
        device[@"ext"] = extensionJSON;
    }

    if (self.emitsLegacyCAIDFields) {
        NSArray<PBCrossIdentifier *> *identifiers = self.identity.allIdentifiers;
        if (identifiers.count > 0) {
            device[@"caid"] = identifiers.firstObject.value;
        }

        NSMutableArray<NSDictionary<NSString *, NSString *> *> *caidInfo = [NSMutableArray array];
        for (PBCrossIdentifier *identifier in identifiers) {
            [caidInfo addObject:@{
                @"caid": identifier.value,
                @"version": identifier.version,
            }];
        }
        device[@"caid_info"] = [caidInfo copy];
    }

    return [device copy];
}

#pragma mark - Extension

- (NSDictionary<NSString *, id> *)extensionObject
{
    NSMutableDictionary<NSString *, id> *extension = [NSMutableDictionary dictionary];
    if (self.context.additionalExtension.count > 0) {
        [extension addEntriesFromDictionary:self.context.additionalExtension];
    }

    NSMutableDictionary<NSString *, id> *crossApp = [[self.identity dictionaryRepresentation] mutableCopy];
    if (self.identity.currentIdentifier.length > 0) {
        crossApp[@"id"] = self.identity.currentIdentifier;
    }
    if (self.identity.currentVersion.length > 0) {
        crossApp[@"version"] = self.identity.currentVersion;
    }
    if (self.identity.previousIdentifier.length > 0) {
        crossApp[@"previous_id"] = self.identity.previousIdentifier;
    }
    if (self.identity.previousVersion.length > 0) {
        crossApp[@"previous_version"] = self.identity.previousVersion;
    }
    crossApp[@"sdk_version"] = PBCrossAppUniqueDeviceIdentifierVersion;
    extension[@"pb_cross_app"] = [crossApp copy];

    return [extension copy];
}

- (nullable NSString *)deviceExtensionJSONString
{
    NSDictionary<NSString *, id> *extension = [self extensionObject];
    if (![NSJSONSerialization isValidJSONObject:extension]) {
        return nil;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:extension
                                                   options:NSJSONWritingSortedKeys
                                                     error:NULL];
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - Tracking

- (NSDictionary<NSString *, NSString *> *)trackingParameters
{
    NSMutableDictionary<NSString *, NSString *> *parameters = [NSMutableDictionary dictionaryWithCapacity:8];
    if (self.identity.currentIdentifier.length > 0) {
        parameters[@"pb_xid"] = self.identity.currentIdentifier;
    }
    if (self.identity.currentVersion.length > 0) {
        parameters[@"pb_xid_version"] = self.identity.currentVersion;
    }
    if (self.identity.previousIdentifier.length > 0) {
        parameters[@"pb_xid_prev"] = self.identity.previousIdentifier;
    }
    if (self.identity.previousVersion.length > 0) {
        parameters[@"pb_xid_prev_version"] = self.identity.previousVersion;
    }
    if (self.identity.sharedID.length > 0) {
        parameters[@"pb_shared_id"] = self.identity.sharedID;
    }
    parameters[@"pb_algorithm"] = self.identity.algorithm;

    NSString *sources = PBCrossIdentitySourceDescription(self.identity.sources);
    if (sources.length > 0) {
        parameters[@"pb_xid_source"] = sources;
    }

    PBCrossIdentifier *remoteIdentifier = [self.identity identifiersWithKind:PBCrossIdentifierKindRemote].firstObject;
    if (remoteIdentifier.value.length > 0) {
        parameters[@"pb_xid_remote"] = remoteIdentifier.value;
        parameters[@"pb_xid_remote_version"] = remoteIdentifier.version;
    }

    return [parameters copy];
}

@end
