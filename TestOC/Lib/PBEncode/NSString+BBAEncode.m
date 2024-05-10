//
//  NSString+BBAEnode.m
//  BBAFoundation
//
//  Created by Zhu,Yusong on 2018/9/20.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "NSString+BBAEncode.h"
#import "NSData+BBAEncode.h"

@implementation NSString (BBAEncode)

- (NSString*)bdp_md5Hash {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] bdp_md5Hash];
}

- (NSString*)bdp_sha1Hash {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] bdp_sha1Hash];
}

@end
