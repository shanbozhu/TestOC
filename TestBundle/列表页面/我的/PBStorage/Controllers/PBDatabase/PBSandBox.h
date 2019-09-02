//
//  PBSandBox.h
//  TestBundle
//
//  Created by DaMaiIOS on 16/3/31.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBSandBox : NSObject

// AD9F89C9-B544-4A63-B6D8-69B8A61BD54F
+ (NSString *)path4Home;

// /Documents
+ (NSString *)path4Documents;

// /Library
+ (NSString *)path4Library;

// /Library/Caches
+ (NSString *)path4LibraryCaches;

// /tmp/
+ (NSString *)path4Tmp;

@end
