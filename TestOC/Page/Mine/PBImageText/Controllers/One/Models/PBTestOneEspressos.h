//
//  PBTestOneEspressos.h
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TFHpple.h"
#import "PBContentOneModel.h"
#import "PBPhotoBrowserView.h"

@interface PBTestOneEspressos : NSObject

@property (nonatomic, strong) NSArray *pEle; // arr 所有p标签(结点)组成的数组

@property (nonatomic, strong) NSMutableArray *imageObjs;

+ (id)testOneEspressosWithHtmlStr:(NSString *)htmlStr;

@end