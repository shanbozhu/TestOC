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
@interface PBSyntax : PBSyntaxBase <PBSyntaxProtocol> {
    NSString *_nationality;
}

@property (nonatomic, copy) NSString *age;

@property (nonatomic, copy) NSString *height;

@property (nonatomic, copy) NSString *nationality;

@end

#pragma mark - extension
@interface PBSyntax ()

@property (nonatomic, copy) NSString *weight;

- (NSString *)hobby;

@end

#pragma mark - category
@interface PBSyntax (ability)

@property (nonatomic, copy) NSString *sing;

@end



NS_ASSUME_NONNULL_END
