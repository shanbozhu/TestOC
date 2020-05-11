//
//  PBContentOneModel.h
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <YYText/YYText.h>

@interface PBContentOneModel : NSObject

@property (nonatomic, assign) CGFloat imgWidth;
@property (nonatomic, assign) CGFloat imgHeight;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, copy) NSMutableAttributedString *text; // 文本
@property (nonatomic, copy) NSString *src; // 图片地址
@property (nonatomic, assign) BOOL isImg; // 是否为图片


@end
