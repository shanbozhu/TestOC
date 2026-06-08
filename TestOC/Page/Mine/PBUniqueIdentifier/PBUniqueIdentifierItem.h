//
//  PBUniqueIdentifierItem.h
//  TestOC
//
//  Created by zhushanbo on 2026/6/8.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PBUniqueIdentifierSchemeType) {
    PBUniqueIdentifierSchemeTypeUDID = 0,
    PBUniqueIdentifierSchemeTypeIDFA,
    PBUniqueIdentifierSchemeTypeIDFV,
    PBUniqueIdentifierSchemeTypeKeychainUUID,
    PBUniqueIdentifierSchemeTypeDeviceCheck,
    PBUniqueIdentifierSchemeTypeMACAddress,
};

@interface PBUniqueIdentifierItem : NSObject

@property (nonatomic, assign) PBUniqueIdentifierSchemeType schemeType;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *identifierValue;
@property (nonatomic, copy) NSString *uniquenessScope;
@property (nonatomic, copy) NSString *persistAfterReinstall;
@property (nonatomic, copy) NSString *requiresPermission;
@property (nonatomic, copy) NSString *purpose;
@property (nonatomic, copy) NSString *recommendation;
@property (nonatomic, assign, getter=isAvailable) BOOL available;

+ (instancetype)itemWithSchemeType:(PBUniqueIdentifierSchemeType)schemeType;

- (NSString *)summaryText;

@end

NS_ASSUME_NONNULL_END
