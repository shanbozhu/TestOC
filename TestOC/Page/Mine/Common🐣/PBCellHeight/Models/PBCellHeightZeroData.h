//
//  PBCellHeightZeroData.h
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/15.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define HEIGHT_Cell              @"height_cell"

@interface PBCellHeightZeroData : NSObject

@property (nonatomic, assign) CGFloat cellHeight; // cell的高度
@property (nonatomic, copy) NSString *content;

// 布局信息
@property (nonatomic ,strong) NSMutableDictionary *layoutInfoMutDic;
@property (nonatomic, assign) BOOL layoutCalculated;

+ (id)testListDataWithDict:(NSDictionary *)dict;

@end
