//
//  PBCrossLogicVerification.m
//  PBCrossAppUniqueDeviceIdentifier
//
//  纯逻辑自检：指纹测试向量、匹配器、广告适配器、JSON 往返。
//  通过 Tools/verify_logic.sh 在 macOS 上编译运行，不依赖 iOS 设备。
//

#import <Foundation/Foundation.h>
#import "PBCrossAdRequestAdapter.h"
#import "PBCrossConfiguration.h"
#import "PBCrossDeviceAttributes.h"
#import "PBCrossIdentifier.h"
#import "PBCrossIdentity.h"
#import "PBCrossIdentityGenerator.h"
#import "PBCrossIdentityMatcher.h"

static int PBCrossFailures = 0;

static void PBCrossAssert(BOOL condition, NSString *name)
{
    if (condition) {
        printf("PASS %s\n", name.UTF8String);
    } else {
        fprintf(stderr, "FAIL %s\n", name.UTF8String);
        PBCrossFailures++;
    }
}

static void PBCrossAssertEqual(NSString *actual, NSString *expected, NSString *name)
{
    BOOL equal = (actual == expected) || [actual isEqualToString:expected];
    if (!equal) {
        fprintf(stderr, "FAIL %s: got %s expected %s\n",
                name.UTF8String,
                actual.UTF8String ?: "(nil)",
                expected.UTF8String ?: "(nil)");
        PBCrossFailures++;
    } else {
        printf("PASS %s: %s\n", name.UTF8String, actual.UTF8String);
    }
}

static PBCrossIdentity *PBCrossTestIdentity(NSArray<PBCrossIdentifier *> *identifiers,
                                            NSString *sharedID,
                                            PBCrossDeviceAttributes *attributes)
{
    return [[PBCrossIdentity alloc] initWithSharedID:sharedID ?: @""
                                          identifiers:identifiers ?: @[]
                                           attributes:attributes ?: [PBCrossDeviceAttributes attributesWithValues:@{}]
                            previousSystemUpdateTime:@""
                                            algorithm:PBCrossIdentifierAlgorithmName
                                              sources:PBCrossIdentitySourceFingerprint
                                          generatedAt:[NSDate date]
                                     remoteResolvedAt:nil];
}

int main(int argc, const char *argv[])
{
    @autoreleasepool {
        NSDictionary<PBCrossAttributeKey, NSString *> *fixture = @{
            PBCrossAttributeKeyBootTimeInSec: @"1600607106",
            PBCrossAttributeKeyCountryCode: @"CN",
            PBCrossAttributeKeyLanguage: @"zh-Hans-CN",
            PBCrossAttributeKeyDeviceName: @"e910ddb2748c36b47fcde5dd720eec11",
            PBCrossAttributeKeySystemVersion: @"13.1.1",
            PBCrossAttributeKeyMachine: @"iPhone10,3",
            PBCrossAttributeKeyCarrierInfo: @"中国联通",
            PBCrossAttributeKeyMemory: @"4047224832",
            PBCrossAttributeKeyDisk: @"127938088960",
            PBCrossAttributeKeySysFileTime: @"1595214620.383940",
            PBCrossAttributeKeyModel: @"D22AP",
            PBCrossAttributeKeyTimeZone: @"28800",
            PBCrossAttributeKeyMntID: @"80825948939346695D0D7DD52CB405D11A80344027A07803D5F8410346398776C879BF6BD67627@/dev/disk1s1",
            PBCrossAttributeKeyDeviceInitTime: @"1632467920.301150749",
            PBCrossAttributeKeyScreenResolution: @"1170x2532@3",
            PBCrossAttributeKeyProcessorCount: @"6",
            PBCrossAttributeKeyIDFAMD5: @"8356c484baee55db3144931bd2b3bfc6",
        };
        PBCrossDeviceAttributes *attributes = [PBCrossDeviceAttributes attributesWithValues:fixture];
        PBCrossConfiguration *configuration = [[PBCrossConfiguration alloc] init];

        NSArray<PBCrossIdentifier *> *identifiers =
            [PBCrossIdentityGenerator fingerprintIdentifiersWithAttributes:attributes
                                                              configuration:configuration];
        PBCrossAssert(identifiers.count == 2, @"generates current + previous identifiers");
        PBCrossAssertEqual(identifiers[0].version, @"20261001", @"current version is 20261001");
        PBCrossAssertEqual(identifiers[1].version, @"20260301", @"previous version is 20260301");
        PBCrossAssertEqual(identifiers[0].value,
                           @"820640c66e2c2009becf80c042afda97",
                           @"current fingerprint test vector");
        PBCrossAssertEqual(identifiers[1].value,
                           @"b045cceaf204a9e9846e2f5573dd12d8",
                           @"compatibility fingerprint test vector");

        NSString *canonical = [PBCrossIdentityGenerator canonicalStringForVersion:[PBCrossIdentifierVersion defaultVersion]
                                                                        attributes:attributes];
        PBCrossAssert([canonical hasPrefix:@"pb-xid-v1|20261001|bootTimeInSec=1600607106|"], @"canonical prefix");
        PBCrossAssert([canonical containsString:@"deviceInitTime=1632467920.301150749|deviceName=e910ddb2748c36b47fcde5dd720eec11"], @"canonical key order");

        // 数字字段去前导零后应得到相同 ID
        NSMutableDictionary *paddedFixture = [fixture mutableCopy];
        paddedFixture[PBCrossAttributeKeyBootTimeInSec] = @"01600607106";
        paddedFixture[PBCrossAttributeKeyMemory] = @"0004047224832";
        paddedFixture[PBCrossAttributeKeyTimeZone] = @"+28800";
        PBCrossDeviceAttributes *paddedAttributes = [PBCrossDeviceAttributes attributesWithValues:paddedFixture];
        NSArray<PBCrossIdentifier *> *paddedIdentifiers =
            [PBCrossIdentityGenerator fingerprintIdentifiersWithAttributes:paddedAttributes
                                                              configuration:configuration];
        PBCrossAssertEqual(paddedIdentifiers[0].value, identifiers[0].value, @"numeric leading zeros are normalized");

        PBCrossIdentity *identityA = PBCrossTestIdentity(identifiers, @"shared-test-id", attributes);
        PBCrossIdentity *identityB = PBCrossTestIdentity(identifiers, @"SHARED-TEST-ID", attributes);
        PBCrossIdentityMatcher *matcher = [[PBCrossIdentityMatcher alloc] init];

        PBCrossIdentityMatchResult *sharedResult = [matcher matchIdentity:identityA withIdentity:identityB];
        PBCrossAssert(sharedResult.matched, @"shared identifier matches");
        PBCrossAssert(sharedResult.reason == PBCrossIdentityMatchReasonSharedIdentifier, @"shared identifier reason");

        PBCrossIdentifier *sameValueCurrent = [PBCrossIdentifier identifierWithValue:@"0123456789abcdef0123456789abcdef"
                                                                            version:@"20261001"
                                                                               kind:PBCrossIdentifierKindFingerprint];
        PBCrossIdentifier *sameValuePrevious = [PBCrossIdentifier identifierWithValue:@"0123456789abcdef0123456789abcdef"
                                                                             version:@"20260301"
                                                                                kind:PBCrossIdentifierKindFingerprint];
        PBCrossIdentityMatchResult *versionResult =
            [matcher matchIdentity:PBCrossTestIdentity(@[sameValueCurrent], @"", nil)
                     withIdentity:PBCrossTestIdentity(@[sameValuePrevious], @"", nil)];
        PBCrossAssert(versionResult.matched, @"cross-version identifier matches");
        PBCrossAssert(versionResult.reason == PBCrossIdentityMatchReasonVersionedIdentifier, @"cross-version reason");

        NSMutableDictionary *attributeOnlyFixture = [fixture mutableCopy];
        [attributeOnlyFixture removeObjectForKey:PBCrossAttributeKeyIDFAMD5];
        PBCrossDeviceAttributes *attributeOnlyAttributes =
            [PBCrossDeviceAttributes attributesWithValues:attributeOnlyFixture];
        PBCrossIdentity *attributesOnlyA = PBCrossTestIdentity(@[], @"", attributeOnlyAttributes);
        PBCrossIdentity *attributesOnlyB = PBCrossTestIdentity(@[], @"", attributeOnlyAttributes);
        PBCrossIdentityMatchResult *attributesResult = [matcher matchIdentity:attributesOnlyA withIdentity:attributesOnlyB];
        PBCrossAssert(attributesResult.matched, @"same attributes match");
        PBCrossAssert(attributesResult.reason == PBCrossIdentityMatchReasonDeviceAttributes, @"attribute reason");
        PBCrossAssert(attributesResult.attributeSimilarity > 0.999, @"attribute similarity is 1.0");

        PBCrossDeviceAttributes *idfaAttributes =
            [PBCrossDeviceAttributes attributesWithValues:@{PBCrossAttributeKeyIDFAMD5: @"cccccccccccccccccccccccccccccccc"}];
        PBCrossIdentityMatchResult *idfaResult =
            [matcher matchIdentity:PBCrossTestIdentity(@[], @"", idfaAttributes)
                     withIdentity:PBCrossTestIdentity(@[], @"", idfaAttributes)];
        PBCrossAssert(idfaResult.matched, @"idfa md5 matches");
        PBCrossAssert(idfaResult.reason == PBCrossIdentityMatchReasonAdvertisingIdentifier, @"idfa reason");

        PBCrossDeviceAttributes *weakAttributes =
            [PBCrossDeviceAttributes attributesWithValues:@{PBCrossAttributeKeyMachine: @"iPhone10,3"}];
        PBCrossIdentityMatchResult *weakResult =
            [matcher matchIdentity:PBCrossTestIdentity(@[], @"", weakAttributes)
                     withIdentity:PBCrossTestIdentity(@[], @"", weakAttributes)];
        PBCrossAssert(!weakResult.matched, @"minimum comparable weight guard");

        PBCrossDeviceAttributes *differentAttributes = [PBCrossDeviceAttributes attributesWithValues:@{
            PBCrossAttributeKeyMachine: @"iPhone99,9",
            PBCrossAttributeKeyModel: @"X99AP",
            PBCrossAttributeKeyDisk: @"1",
        }];
        PBCrossIdentityMatchResult *differentResult =
            [matcher matchIdentity:PBCrossTestIdentity(@[], @"", attributes)
                     withIdentity:PBCrossTestIdentity(@[], @"", differentAttributes)];
        PBCrossAssert(!differentResult.matched, @"different hardware does not match");

        NSDictionary *identityDictionary = [identityA dictionaryRepresentation];
        NSData *identityJSON = [NSJSONSerialization dataWithJSONObject:identityDictionary options:0 error:NULL];
        PBCrossAssert(identityJSON.length > 0, @"identity JSON serializable");
        PBCrossIdentity *restoredIdentity = [PBCrossIdentity identityWithDictionaryRepresentation:identityDictionary];
        PBCrossAssertEqual(restoredIdentity.currentIdentifier, identityA.currentIdentifier, @"identity JSON round trip");

        PBCrossAdRequestAdapter *adapter = [[PBCrossAdRequestAdapter alloc] initWithIdentity:identityA context:nil];
        NSDictionary *device = [adapter deviceDictionary];
        PBCrossAssertEqual(device[@"os"], @"ios", @"adapter os");
        PBCrossAssertEqual(device[@"make"], @"apple", @"adapter make");
        PBCrossAssertEqual(device[@"boot_time"], @"1600607106", @"adapter boot_time");
        PBCrossAssertEqual(device[@"birth_time"], @"1632467920.301150749", @"adapter birth_time");
        PBCrossAssertEqual(device[@"update_time"], @"1595214620.383940", @"adapter update_time");
        PBCrossAssertEqual(device[@"idfa_md5"], @"8356c484baee55db3144931bd2b3bfc6", @"adapter idfa_md5");
        PBCrossAssertEqual(device[@"carrier"], @"unicom", @"adapter carrier enum");
        PBCrossAssertEqual([device[@"w"] stringValue], @"1170", @"adapter width");
        PBCrossAssertEqual([device[@"h"] stringValue], @"2532", @"adapter height");

        NSString *extensionJSON = [adapter deviceExtensionJSONString];
        NSDictionary *extension = extensionJSON.length > 0
            ? [NSJSONSerialization JSONObjectWithData:[extensionJSON dataUsingEncoding:NSUTF8StringEncoding]
                                              options:0 error:NULL]
            : nil;
        PBCrossAssert([extension[@"pb_cross_app"][@"id"] isEqualToString:identityA.currentIdentifier],
                      @"adapter ext pb_cross_app id");
        PBCrossIdentity *identityFromExtension = [PBCrossIdentity identityWithAdRequestExtension:extension];
        PBCrossAssertEqual(identityFromExtension.currentIdentifier, identityA.currentIdentifier,
                           @"identity from ad request extension");
        PBCrossIdentity *identityFromExtensionJSON =
            [PBCrossIdentity identityWithAdRequestExtensionJSONString:extensionJSON];
        PBCrossAssertEqual(identityFromExtensionJSON.currentIdentifier, identityA.currentIdentifier,
                           @"identity from ad request extension JSON string");

        NSDictionary<NSString *, NSString *> *tracking = [adapter trackingParameters];
        PBCrossAssertEqual(tracking[@"pb_xid"], identityA.currentIdentifier, @"tracking pb_xid");
        PBCrossAssertEqual(tracking[@"pb_shared_id"], @"shared-test-id", @"tracking shared id");

        adapter.emitsLegacyCAIDFields = YES;
        NSDictionary *legacyDevice = [adapter deviceDictionary];
        PBCrossAssertEqual(legacyDevice[@"caid"], identityA.currentIdentifier, @"legacy caid field");
        PBCrossAssert([legacyDevice[@"caid_info"] isKindOfClass:[NSArray class]]
                      && [legacyDevice[@"caid_info"] count] == 2, @"legacy caid_info field");

        if (PBCrossFailures == 0) {
            printf("\nAll PBCross logic checks passed.\n");
        } else {
            fprintf(stderr, "\n%d PBCross logic check(s) failed.\n", PBCrossFailures);
        }
        return PBCrossFailures == 0 ? 0 : 1;
    }
}
