//
//  PBSandBox.m
//  TestBundle
//
//  Created by DaMaiIOS on 16/3/31.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import "PBSandBox.h"

@implementation PBSandBox

+ (NSString *)path4Home {
    return NSHomeDirectory();
}

+ (NSString *)path4Documents {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
}

+ (NSString *)path4Library {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)lastObject];
}

+ (NSString *)path4LibraryCaches {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
}

+ (NSString *)path4Tmp {
    return NSTemporaryDirectory();
}

@end
