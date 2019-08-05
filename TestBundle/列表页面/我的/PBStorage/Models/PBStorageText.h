//
//  PBStorageText.h
//  TestBundle
//
//  Created by DaMaiIOS on 2017/11/17.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBArchiver.h"

@interface PBStorageText : PBArchiver

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;

@end
