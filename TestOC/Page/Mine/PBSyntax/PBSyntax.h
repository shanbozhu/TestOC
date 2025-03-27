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
+ (NSString *)fn;

@end

#pragma mark - interface

@interface PBSyntax : NSObject <PBSyntaxProtocol>
{
    NSString *_height; // 手动声明私有成员变量
}

@property (nonatomic, copy) NSString *age;
@property (nonatomic, copy) NSString *height;

// 类属性：类对象的属性。class property
@property (nonatomic, class) NSString *someString; // 类属性存储“对象”
@property (nonatomic, class) Class<PBSyntaxProtocol> someCls; // 类属性存储“类对象”

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
