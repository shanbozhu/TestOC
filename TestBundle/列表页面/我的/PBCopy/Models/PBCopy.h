//
//  PBCopy.h
//  TestBundle
//
//  Created by DaMaiIOS on 2017/12/5.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBCopy : NSObject<NSCopying, NSMutableCopying>

@property (nonatomic, copy) NSString *name;

@end
