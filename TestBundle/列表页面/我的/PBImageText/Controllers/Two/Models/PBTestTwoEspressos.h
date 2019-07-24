//
//  PBTestTwoEspressos.h
//  TestBundle
//
//  Created by Zhu,Shanbo on 2019/6/26.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBActivityDetailContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBTestTwoEspressos : NSObject

@property (nonatomic, strong) PBActivityDetailContent *activityDetailContent;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, weak) UITableView *tableView; // 算高时需要使用

+ (id)testTwoEspressosWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
