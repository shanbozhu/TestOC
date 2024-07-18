//
//  PBTestEspressos.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBTestEspressos.h"
#import <YYText/YYText.h>
#import "UIImageView+WebCache.h"
#import "PBTestEspressosSCSeatList.h"

@interface PBTestEspressos ()

@property (nonatomic, strong) NSMutableArray *currentArr;

@property (nonatomic, strong) PBTestEspressosSCSeatList *lastSeatList;

@end

@implementation PBTestEspressos

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSMutableArray *objsArr = [NSMutableArray array];
    for (int i = 0; i < self.seatContainer.seatList.count; i++) {
        PBTestEspressosSCSeatList *seatList = self.seatContainer.seatList[i];
        
        if (i == 0) {
            self.currentArr = [NSMutableArray array];
            [self.currentArr addObject:seatList];
            
            [objsArr addObject:self.currentArr];
        } else {
            if (seatList.type != 2) {
                [self.currentArr addObject:seatList];
            } else {
                self.currentArr = [NSMutableArray array];
                //[self.currentArr addObject:seatList]; // 表示换行的模型对象没有任何用处，舍弃
                
                [objsArr addObject:self.currentArr];
            }
        }
        self.lastSeatList = seatList;
    }
    self.seats = objsArr;
    
    NSMutableArray *objsSeatsRowN = [NSMutableArray array];
    for (int i = 0; i < self.seats.count; i++) {
        NSArray *tmpArr = self.seats[i];
        
        if (tmpArr.count > self.maxColCount) {
            self.maxColCount = tmpArr.count;
        }
        
        if (tmpArr.count == 0) {
            [objsSeatsRowN addObject:@""];
        }
        for (int j = 0; j < tmpArr.count; j++) {
            PBTestEspressosSCSeatList *seatList = tmpArr[j];
            if (seatList.seatInfo.rowNo != nil) {
                
                [objsSeatsRowN addObject:seatList.seatInfo.rowNo];
                break;
            }
        }
    }
    self.seatsRowN = objsSeatsRowN;
    
    return YES;
}

@end
