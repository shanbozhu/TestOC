//
//  PBDatabase.h
//  TestBundle
//
//  Created by DaMaiIOS on 2017/11/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBDataPList.h"
#import "PBSandBox.h"
#import "PBArchiver.h"

@interface PBDatabase : NSObject

+ (id)sharedDatabase;

- (void)setValue:(id)value forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)defaultName;
- (id)valueForKey:(NSString *)key;
- (void)removeAllObjects;

@end
