//
//  PBCellHeightZeroData.h
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/15.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PBCellHeightZeroData : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGSize cellSize;

+ (id)testListDataWithDict:(NSDictionary *)dict;

@end
