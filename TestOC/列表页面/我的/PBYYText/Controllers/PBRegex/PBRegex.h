//
//  PBRegex.h
//  TestOC
//
//  Created by DaMaiIOS on 17/9/23.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBRegex : NSObject

+ (NSRegularExpression *)regexAt;
+ (NSRegularExpression *)regexTopic;
+ (NSRegularExpression *)regexEmail;
+ (NSRegularExpression *)regexUrl;
+ (NSRegularExpression *)regexPhone;

@end
