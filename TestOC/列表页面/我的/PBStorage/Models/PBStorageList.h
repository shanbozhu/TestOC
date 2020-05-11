//
//  PBStorageList.h
//  TestOC
//
//  Created by DaMaiIOS on 2017/11/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBArchiver.h"

@interface PBStorageList : PBArchiver

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;

@end
