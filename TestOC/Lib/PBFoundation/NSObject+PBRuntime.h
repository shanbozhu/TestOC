//
//  NSObject+PBRuntime.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/12.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (PBRuntime)

/// 获取类的所有属性
- (NSArray *)pb_propertyList;

@end

NS_ASSUME_NONNULL_END
