//
//  PBSyntax.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/12.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - protocol

@protocol PBSyntaxProtocol <NSObject>
@optional

@property (nonatomic, copy) NSString *name;

- (NSString *)sex;
+ (NSString *)func;

@end

#pragma mark - interface

@interface PBSyntax : NSObject <PBSyntaxProtocol> {
    NSString *_height;
}

@property (nonatomic, copy) NSString *age;
@property (nonatomic, copy) NSString *height;

// class property
@property (class, nonatomic) NSString *someString; // 类属性存储对象
@property (class, nonatomic) Class<PBSyntaxProtocol> someCls; // 类属性存储类对象

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
