//
//  PBContentLink.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/21.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBContentLink.h"

NSString *const PBContentLinkTextAttributeName = @"PBContentLinkTextAttributeName";

@implementation PBContentLinkAttribute

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        
    }
    return self;
}

+ (instancetype)itemWithDict:(NSDictionary *)dict {
    return [[[self class] alloc] initWithDict:dict];
}

@end


@interface PBContentLink ()

@property (nonatomic, strong) NSString *identiferString;
@property (nonatomic, strong) NSAttributedString *text;
@property (nonatomic, copy) NSDictionary *userInfo;

@end

@implementation PBContentLink

- (instancetype)initWithIdentifer:(NSString *)identifer text:(NSAttributedString *)text userInfo:(NSDictionary *)userInfo {
    if (self = [super init]) {
        self.identiferString = identifer;
        self.text = text;
        self.userInfo = userInfo;
    }
    return self;
}

@end
