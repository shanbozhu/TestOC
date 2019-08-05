//
//  PBDataPList.h
//  TestBundle
//
//  Created by DaMaiIOS on 2017/11/18.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBDataPList : NSObject

+ (id)sharedDataPList;

- (void)setValue:(id)value forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)defaultName;
- (id)valueForKey:(NSString *)key;
- (void)removeAllObjects;

@end
