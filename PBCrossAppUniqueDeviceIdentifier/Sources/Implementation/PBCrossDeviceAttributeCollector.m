//
//  PBCrossDeviceAttributeCollector.m
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import "PBCrossDeviceAttributeCollector.h"
#import "PBCrossConfiguration.h"
#import "PBCrossCrypto.h"
#import "PBCrossLogging.h"

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <TargetConditionals.h>

#import <math.h>
#import <sys/mount.h>
#import <sys/stat.h>
#import <sys/sysctl.h>
#import <sys/time.h>
#import <sys/types.h>
#import <string.h>

#pragma mark - 基础属性

static NSString *PBCrossSysctlString(const char *name)
{
    size_t size = 0;
    if (sysctlbyname(name, NULL, &size, NULL, 0) != 0 || size == 0) {
        return nil;
    }

    char *buffer = calloc(size + 1, sizeof(char));
    if (buffer == NULL) {
        return nil;
    }
    if (sysctlbyname(name, buffer, &size, NULL, 0) != 0) {
        free(buffer);
        return nil;
    }

    NSString *value = [NSString stringWithUTF8String:buffer];
    free(buffer);
    return value.length > 0 ? value : nil;
}

static NSString *PBCrossBootTimeInSec(void)
{
    struct timeval bootTime;
    size_t length = sizeof(bootTime);
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    if (sysctl(mib, 2, &bootTime, &length, NULL, 0) != 0) {
        return nil;
    }
    return [NSString stringWithFormat:@"%lld", (long long)bootTime.tv_sec];
}

static NSString *PBCrossPhysicalMemory(void)
{
    unsigned long long memory = [NSProcessInfo processInfo].physicalMemory;
    return memory > 0 ? [NSString stringWithFormat:@"%llu", memory] : nil;
}

static NSString *PBCrossDiskCapacity(void)
{
    NSError *error = nil;
    NSDictionary<NSFileAttributeKey, id> *attributes =
        [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error || ![attributes isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    NSNumber *size = attributes[NSFileSystemSize];
    if (![size isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    long long bytes = size.longLongValue;
    return bytes > 0 ? [NSString stringWithFormat:@"%lld", bytes] : nil;
}

static NSString *PBCrossSystemUpdateTime(void)
{
    // /var/mobile/Library/UserConfigurationProfiles/PublicInfo/MCMeta.plist
    static NSString *path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *base64 = @"L3Zhci9tb2JpbGUvTGlicmFyeS9Vc2VyQ29uZmlndXJhdGlvblByb2ZpbGVzL1B1YmxpY0luZm8vTUNNZXRhLnBsaXN0";
        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
        path = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    });
    if (path.length == 0) {
        return nil;
    }

    NSError *error = nil;
    NSDictionary<NSFileAttributeKey, id> *attributes =
        [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if (error) {
        return nil;
    }

    NSDate *date = attributes[NSFileCreationDate];
    if (![date isKindOfClass:[NSDate class]]) {
        return nil;
    }
    return [NSString stringWithFormat:@"%.6f", date.timeIntervalSince1970];
}

static NSString *PBCrossMountIdentifier(void)
{
    struct statfs filesystem;
    if (statfs("/", &filesystem) != 0) {
        return nil;
    }

    const char *prefix = "com.apple.os.update-";
    size_t prefixLength = strlen(prefix);
    size_t nameLength = strnlen(filesystem.f_mntfromname, sizeof(filesystem.f_mntfromname));
    if (nameLength <= prefixLength || strncmp(filesystem.f_mntfromname, prefix, prefixLength) != 0) {
        return nil;
    }

    NSString *identifier = [[NSString alloc] initWithBytes:(filesystem.f_mntfromname + prefixLength)
                                                   length:(nameLength - prefixLength)
                                                 encoding:NSUTF8StringEncoding];
    return identifier.length > 0 ? identifier : nil;
}

static NSString *PBCrossDeviceInitializationTime(void)
{
    struct stat info;
    if (stat("/var/mobile", &info) != 0) {
        return nil;
    }
    return [NSString stringWithFormat:@"%lld.%09ld",
            (long long)info.st_birthtimespec.tv_sec,
            (long)info.st_birthtimespec.tv_nsec];
}

#pragma mark - 运营商

static __attribute__((unused)) NSString *PBCrossCarrierName(NSString *mobileCountryCode, NSString *mobileNetworkCode, NSString *fallback)
{
    if ([mobileCountryCode isEqualToString:@"460"] && mobileNetworkCode.length > 0) {
        NSSet<NSString *> *chinaMobile = [NSSet setWithObjects:@"00", @"02", @"07", @"08", nil];
        NSSet<NSString *> *chinaUnicom = [NSSet setWithObjects:@"01", @"06", @"09", nil];
        NSSet<NSString *> *chinaTelecom = [NSSet setWithObjects:@"03", @"05", @"11", nil];

        if ([chinaMobile containsObject:mobileNetworkCode]) {
            return @"中国移动";
        }
        if ([chinaUnicom containsObject:mobileNetworkCode]) {
            return @"中国联通";
        }
        if ([chinaTelecom containsObject:mobileNetworkCode]) {
            return @"中国电信";
        }
        if ([mobileNetworkCode isEqualToString:@"04"]) {
            return @"中国卫通";
        }
        if ([mobileNetworkCode isEqualToString:@"20"]) {
            return @"中国铁通";
        }
    }

    return fallback.length > 0 ? fallback : @"unknown";
}

static NSDictionary<NSString *, NSString *> *PBCrossCarrierInformation(void)
{
#if TARGET_OS_SIMULATOR
    return @{@"carrier": @"SIMULATOR"};
#else
    __block NSString *carrierName = nil;
    __block NSString *mobileCountryCode = nil;
    __block NSString *mobileNetworkCode = nil;

    NSLock *lock = [[NSLock alloc] init];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.pb.crossapp.carrier", DISPATCH_QUEUE_SERIAL);
    });

    dispatch_async(queue, ^{
        @autoreleasepool {
            NSString *resolvedCarrier = nil;
            NSString *resolvedMCC = nil;
            NSString *resolvedMNC = nil;

            CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
            CTCarrier *carrier = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            NSDictionary<NSString *, CTCarrier *> *providers = networkInfo.serviceSubscriberCellularProviders;
            NSArray<NSString *> *keys = [providers.allKeys sortedArrayUsingSelector:@selector(compare:)];
            if (keys.count > 0) {
                carrier = providers[keys.firstObject];
                if (carrier.mobileNetworkCode.length == 0) {
                    carrier = providers[keys.lastObject];
                }
            }
            if (!carrier) {
                carrier = networkInfo.subscriberCellularProvider;
            }

            if (carrier) {
                resolvedMCC = [carrier.mobileCountryCode copy];
                resolvedMNC = [carrier.mobileNetworkCode copy];
                resolvedCarrier = PBCrossCarrierName(resolvedMCC, resolvedMNC, carrier.carrierName);
            }
#pragma clang diagnostic pop

            [lock lock];
            carrierName = resolvedCarrier;
            mobileCountryCode = resolvedMCC;
            mobileNetworkCode = resolvedMNC;
            [lock unlock];

            dispatch_semaphore_signal(semaphore);
        }
    });

    // CoreTelephony 在少数机型上可能阻塞，最多等待 0.5 秒。
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    if (dispatch_semaphore_wait(semaphore, timeout) != 0) {
        return @{@"carrier": @"unknown"};
    }

    [lock lock];
    NSMutableDictionary<NSString *, NSString *> *result = [NSMutableDictionary dictionary];
    result[@"carrier"] = carrierName.length > 0 ? carrierName : @"unknown";
    if (mobileCountryCode.length > 0) {
        result[@"mcc"] = mobileCountryCode;
    }
    if (mobileNetworkCode.length > 0) {
        result[@"mnc"] = mobileNetworkCode;
    }
    NSDictionary<NSString *, NSString *> *snapshot = [result copy];
    [lock unlock];
    return snapshot;
#endif
}

#pragma mark - IDFA

@protocol PBCrossTrackingManagerClass <NSObject>
+ (NSInteger)trackingAuthorizationStatus;
@end

@protocol PBCrossIdentifierManagerClass <NSObject>
+ (id)sharedManager;
- (BOOL)isAdvertisingTrackingEnabled;
- (NSUUID *)advertisingIdentifier;
@end

static NSString *PBCrossAdvertisingIdentifier(void)
{
    if (@available(iOS 14.0, *)) {
        Class trackingManagerClass = NSClassFromString(@"ATTrackingManager");
        if ([trackingManagerClass respondsToSelector:@selector(trackingAuthorizationStatus)]) {
            NSInteger status = [(id<PBCrossTrackingManagerClass>)trackingManagerClass trackingAuthorizationStatus];
            // 3 = ATTrackingManagerAuthorizationStatusAuthorized
            if (status != 3) {
                return nil;
            }
        }
    }

    Class identifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (![identifierManagerClass respondsToSelector:@selector(sharedManager)]) {
        return nil;
    }

    id<PBCrossIdentifierManagerClass> identifierManager =
        [(id<PBCrossIdentifierManagerClass>)identifierManagerClass sharedManager];
    if ([identifierManager respondsToSelector:@selector(isAdvertisingTrackingEnabled)]
        && ![identifierManager isAdvertisingTrackingEnabled]) {
        return nil;
    }
    if (![identifierManager respondsToSelector:@selector(advertisingIdentifier)]) {
        return nil;
    }

    NSUUID *advertisingIdentifier = identifierManager.advertisingIdentifier;
    if (![advertisingIdentifier isKindOfClass:[NSUUID class]]) {
        return nil;
    }

    NSString *value = advertisingIdentifier.UUIDString;
    if (value.length == 0 || [[value lowercaseString] isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
        return nil;
    }
    // 保留标准大写 UUID 形式，按业界惯例对其做 MD5（idfa_md5）。
    return value;
}

#pragma mark - Collector

static void PBCrossRunOnMainThreadSynchronously(dispatch_block_t block)
{
    if ([NSThread isMainThread]) {
        block();
        return;
    }
    dispatch_sync(dispatch_get_main_queue(), block);
}

@implementation PBCrossDeviceAttributeCollector

+ (PBCrossDeviceAttributes *)collectAttributesWithConfiguration:(PBCrossConfiguration *)configuration
{
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    NSMutableDictionary<PBCrossAttributeKey, NSString *> *values =
        [NSMutableDictionary dictionaryWithCapacity:24];

    __block NSString *deviceName = nil;
    __block NSString *systemVersion = nil;
    __block NSString *systemName = nil;
    __block NSString *identifierForVendor = nil;
    __block NSInteger screenWidth = 0;
    __block NSInteger screenHeight = 0;
    __block CGFloat screenScale = 0;

    PBCrossRunOnMainThreadSynchronously(^{
        UIDevice *device = [UIDevice currentDevice];
        deviceName = [device.name copy];
        systemVersion = [device.systemVersion copy];
        systemName = [device.systemName copy];
        identifierForVendor = [device.identifierForVendor.UUIDString lowercaseString];

        UIScreen *screen = [UIScreen mainScreen];
        screenScale = screen.scale;
        CGRect nativeBounds = screen.nativeBounds;
        screenWidth = (NSInteger)llround(nativeBounds.size.width);
        screenHeight = (NSInteger)llround(nativeBounds.size.height);
        if (screenWidth <= 0 || screenHeight <= 0) {
            CGSize boundsSize = screen.bounds.size;
            screenWidth = (NSInteger)llround(boundsSize.width * screenScale);
            screenHeight = (NSInteger)llround(boundsSize.height * screenScale);
        }
    });

    // CAID 兼容字段
    NSString *bootTimeInSec = PBCrossBootTimeInSec();
    if (bootTimeInSec) {
        values[PBCrossAttributeKeyBootTimeInSec] = bootTimeInSec;
    }

    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    if (countryCode.length > 0) {
        values[PBCrossAttributeKeyCountryCode] = countryCode;
    }

    NSArray<NSString *> *preferredLanguages = [NSLocale preferredLanguages];
    NSString *language = preferredLanguages.firstObject ?: [locale objectForKey:NSLocaleLanguageCode];
    if (language.length > 0) {
        values[PBCrossAttributeKeyLanguage] = language;
    }

    if (configuration.collectsDeviceName && deviceName.length > 0) {
        values[PBCrossAttributeKeyDeviceName] = [PBCrossCrypto MD5HexString:deviceName];
    }

    if (systemVersion.length > 0) {
        values[PBCrossAttributeKeySystemVersion] = systemVersion;
    }

    NSString *machine = PBCrossSysctlString("hw.machine");
    if (machine.length > 0) {
        values[PBCrossAttributeKeyMachine] = machine;
    }

    NSString *hardwareModel = PBCrossSysctlString("hw.model");
    if (hardwareModel.length > 0) {
        values[PBCrossAttributeKeyModel] = hardwareModel;
    }

    if (configuration.collectsCarrierInformation) {
        NSDictionary<NSString *, NSString *> *carrier = PBCrossCarrierInformation();
        if (carrier[@"carrier"].length > 0) {
            values[PBCrossAttributeKeyCarrierInfo] = carrier[@"carrier"];
        }
        if (carrier[@"mcc"].length > 0) {
            values[PBCrossAttributeKeyCarrierMCC] = carrier[@"mcc"];
        }
        if (carrier[@"mnc"].length > 0) {
            values[PBCrossAttributeKeyCarrierMNC] = carrier[@"mnc"];
        }
    }

    NSString *memory = PBCrossPhysicalMemory();
    if (memory.length > 0) {
        values[PBCrossAttributeKeyMemory] = memory;
    }

    NSString *disk = PBCrossDiskCapacity();
    if (disk.length > 0) {
        values[PBCrossAttributeKeyDisk] = disk;
    }

    NSString *systemUpdateTime = PBCrossSystemUpdateTime();
    if (systemUpdateTime.length > 0) {
        values[PBCrossAttributeKeySysFileTime] = systemUpdateTime;
    }

    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    values[PBCrossAttributeKeyTimeZone] = [NSString stringWithFormat:@"%ld", (long)timeZone.secondsFromGMT];
    if (timeZone.name.length > 0) {
        values[PBCrossAttributeKeyTimeZoneIdentifier] = timeZone.name;
    }

    NSString *mountIdentifier = PBCrossMountIdentifier();
    if (mountIdentifier.length > 0) {
        values[PBCrossAttributeKeyMntID] = mountIdentifier;
    }

    NSString *deviceInitTime = PBCrossDeviceInitializationTime();
    if (deviceInitTime.length > 0) {
        values[PBCrossAttributeKeyDeviceInitTime] = deviceInitTime;
    }

    // 扩展字段
    if (identifierForVendor.length > 0) {
        values[PBCrossAttributeKeyIDFV] = identifierForVendor;
    }
    if (systemName.length > 0) {
        values[PBCrossAttributeKeySystemName] = systemName;
    }
    if (screenWidth > 0 && screenHeight > 0) {
        NSString *scale = [NSString stringWithFormat:@"%g", screenScale];
        values[PBCrossAttributeKeyScreenResolution] =
            [NSString stringWithFormat:@"%ldx%ld@%@", (long)screenWidth, (long)screenHeight, scale];
    }
    if (NSProcessInfo.processInfo.processorCount > 0) {
        values[PBCrossAttributeKeyProcessorCount] =
            [NSString stringWithFormat:@"%lu", (unsigned long)NSProcessInfo.processInfo.processorCount];
    }

#if TARGET_OS_SIMULATOR
    values[PBCrossAttributeKeySimulator] = @"1";
#else
    values[PBCrossAttributeKeySimulator] = @"0";
#endif

    NSString *advertisingIdentifier = nil;
    if (configuration.allowsAdvertisingIdentifier) {
        advertisingIdentifier = PBCrossAdvertisingIdentifier();
        if (advertisingIdentifier.length > 0) {
            values[PBCrossAttributeKeyIDFAMD5] = [PBCrossCrypto MD5HexString:advertisingIdentifier];
        }
    }

    PBCrossDeviceAttributes *attributes =
        [PBCrossDeviceAttributes attributesWithValues:values advertisingIdentifier:advertisingIdentifier];

    PBCrossLog(configuration, @"设备属性采集完成 keys=%lu cost=%.3fs idfv=%@",
               (unsigned long)attributes.values.count,
               CFAbsoluteTimeGetCurrent() - startTime,
               identifierForVendor.length > 0 ? @"yes" : @"no");
    return attributes;
}

@end
