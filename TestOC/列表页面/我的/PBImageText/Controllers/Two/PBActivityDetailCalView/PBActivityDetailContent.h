//
//  PBActivityDetailContent.h
//  TestOC
//
//  Created by DaMaiIOS on 2016/11/11.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//屏幕宽度 屏幕高度
#define kPBSWidth [UIScreen mainScreen].bounds.size.width
#define kPBSHeight [UIScreen mainScreen].bounds.size.height

@interface PBActivityDetailContent : NSObject

@property (nonatomic, copy) NSString *htmlStr; // 存储由content和img拼接生成的新的完整的HTML字符串
@property (nonatomic, strong) NSArray *imageArr; // 存储由img组成的图片数组

+ (id)activityDetailContentWithHtmlStr:(NSString *)HtmlStr;

@end
