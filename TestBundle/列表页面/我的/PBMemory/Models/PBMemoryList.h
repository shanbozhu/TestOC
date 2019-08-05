//
//  PBMemoryList.h
//  TestBundle
//
//  Created by DaMaiIOS on 2017/11/29.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBMemoryList : NSObject
//{
//    NSString *_name;
//    NSInteger _age;
//}

// 将下面的@property展开就是具有自动内存管理功能的getter和setter
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;

@end
