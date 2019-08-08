//
//  PBSandBox.h
//  TestBundle
//
//  Created by DaMaiIOS on 16/3/31.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBSandBox : NSObject

+ (NSString *)path4Home;
+ (NSString *)path4Documents;
+ (NSString *)path4Library;
+ (NSString *)path4Tmp;
+ (NSString *)path4LibraryCaches;

@end
