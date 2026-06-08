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
            item.name = @"DeviceCheck";
            item.uniquenessScope = @"全局（Apple 服务器状态位）";
            item.persistAfterReinstall = @"不变";
            item.requiresPermission = @"否";
            item.purpose = @"风控、反欺诈、黑白名单";
            item.recommendation = @"★★★★☆（特定场景）";
            item.available = YES;
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
    return [NSString stringWithFormat:@"标识值：%@\n唯一性：%@ | 卸载重装：%@ | 权限：%@\n用途：%@ | 推荐：%@",
            self.identifierValue,
            self.uniquenessScope,
            self.persistAfterReinstall,
            self.requiresPermission,
            self.purpose,
            self.recommendation];
}

@end
