//
//  PBUniqueIdentifierItem.m
//  TestOC
//
//  Created by zhushanbo on 2026/6/8.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBUniqueIdentifierItem.h"

@implementation PBUniqueIdentifierItem

+ (instancetype)itemWithSchemeType:(PBUniqueIdentifierSchemeType)schemeType {
    PBUniqueIdentifierItem *item = [[PBUniqueIdentifierItem alloc] init];
    item.schemeType = schemeType;
    item.identifierValue = @"加载中...";
    item.identifierCopyable = YES;
    
    switch (schemeType) {
        case PBUniqueIdentifierSchemeTypeUDID:
            item.name = @"UDID";
            item.uniquenessScope = @"全局唯一";
            item.persistAfterReinstall = @"不变";
            item.requiresPermission = @"否（已废弃）";
            item.purpose = @"已废弃，不可使用";
            item.recommendation = @"★☆☆☆☆";
            item.available = NO;
            break;
        case PBUniqueIdentifierSchemeTypeIDFA:
            item.name = @"IDFA";
            item.uniquenessScope = @"全局唯一";
            item.persistAfterReinstall = @"不变（除非用户重置）";
            item.requiresPermission = @"是（ATT 弹窗）";
            item.purpose = @"广告营销";
            item.recommendation = @"★★★☆☆";
            item.available = YES;
            break;
        case PBUniqueIdentifierSchemeTypeIDFV:
            item.name = @"IDFV";
            item.uniquenessScope = @"同 Vendor 内唯一";
            item.persistAfterReinstall = @"同 Vendor 应用全部卸载后会变";
            item.requiresPermission = @"否";
            item.purpose = @"内部统计、多 App 关联";
            item.recommendation = @"★★★★☆";
            item.available = YES;
            break;
        case PBUniqueIdentifierSchemeTypeKeychainUUID:
            item.name = @"Keychain + UUID";
            item.uniquenessScope = @"单 App 唯一";
            item.persistAfterReinstall = @"不变（推荐方案）";
            item.requiresPermission = @"否";
            item.purpose = @"用户识别、登录、常规业务";
            item.recommendation = @"★★★★★";
            item.available = YES;
            break;
        case PBUniqueIdentifierSchemeTypeDeviceCheck:
            item.name = @"DeviceCheck（风控状态）";
            item.uniquenessScope = @"非设备 ID（每开发者 2 bit）";
            item.persistAfterReinstall = @"状态位由 Apple 保存；Token 每次不同";
            item.requiresPermission = @"否";
            item.purpose = @"风控、防刷；不能作为唯一标识";
            item.recommendation = @"★★★☆☆（仅作风控信号）";
            item.available = YES;
            item.identifierCopyable = NO;
            break;
        case PBUniqueIdentifierSchemeTypeMACAddress:
            item.name = @"MAC 地址";
            item.uniquenessScope = @"—";
            item.persistAfterReinstall = @"—";
            item.requiresPermission = @"—";
            item.purpose = @"现代 iOS 已失效";
            item.recommendation = @"★☆☆☆☆";
            item.available = NO;
            break;
    }
    return item;
}

- (NSString *)summaryText {
    NSString *value = self.identifierValue.length > 0 ? self.identifierValue : @"不可用";
    if (self.identifierError.length > 0) {
        value = [NSString stringWithFormat:@"不可用（%@）", self.identifierError];
    }
    NSString *valueLabel = self.schemeType == PBUniqueIdentifierSchemeTypeDeviceCheck ? @"当前状态" : @"标识值";
    return [NSString stringWithFormat:@"%@：%@\n唯一性：%@ | 卸载重装：%@ | 权限：%@\n用途：%@ | 推荐：%@",
            valueLabel,
            value,
            self.uniquenessScope,
            self.persistAfterReinstall,
            self.requiresPermission,
            self.purpose,
            self.recommendation];
}

@end
