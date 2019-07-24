//
//  PBTestTwoEspressos.m
//  TestBundle
//
//  Created by Zhu,Shanbo on 2019/6/26.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBTestTwoEspressos.h"

@implementation PBTestTwoEspressos

+ (id)testTwoEspressosWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        // 处理详情内容
        PBActivityDetailContent *activityDetailContent = [PBActivityDetailContent activityDetailContentWithHtmlStr:dict[@"espressos"]];
        self.activityDetailContent = activityDetailContent;
    }
    return self;
}

@end
