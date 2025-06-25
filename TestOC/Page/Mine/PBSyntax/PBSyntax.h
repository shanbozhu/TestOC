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

// 属性：对象属性。instance property
@property (nonatomic, copy) NSString *age;

// 类属性：类对象的属性。class property
@property (nonatomic, class) NSString *someString; // 类属性存储“对象”
@property (nonatomic, class) Class<PBSyntaxProtocol> someCls; // 类属性存储“类对象”

// 3.3.2 接口或扩展里面 复制一份 协议里的属性。
//@property (nonatomic, copy) NSString *name;

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
