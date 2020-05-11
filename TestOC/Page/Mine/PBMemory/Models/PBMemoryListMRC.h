//
//  PBMemoryListMRC.h
//  TestOC
//
//  Created by DaMaiIOS on 2017/11/29.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMemoryListMRCOne.h"

@interface PBMemoryListMRC : NSObject
{
    PBMemoryListMRCOne *_testListMRCOne;
}

// 将下面的@property展开就是具有手动内存管理功能的getter和setter
@property (nonatomic, retain) PBMemoryListMRCOne *testListMRCOne;

@end
