//
//  PBSyntax.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/12.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBSyntaxBase.h"

NS_ASSUME_NONNULL_BEGIN


#pragma mark - protocol
@protocol PBSyntaxProtocol <NSObject>

@property (nonatomic, copy) NSString *name;

- (NSString *)sex;

@end

#pragma mark - interface
@interface PBSyntax : PBSyntaxBase <PBSyntaxProtocol>

@property (nonatomic, copy) NSString *age;

@property (nonatomic, copy) NSString *height;

@end

#pragma mark - category
@interface PBSyntax (ability)

@end





NS_ASSUME_NONNULL_END
