//
//  PBSeatsView.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBSeatsView.h"
#import "PBSeatButton.h"
#import "PBTestEspressosSCSLSeatInfo.h"

@implementation PBSeatsView

+ (id)seatsView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
    }
    return self;
}

- (void)setTestEspressos:(PBTestEspressos *)testEspressos {
    _testEspressos = testEspressos;
    
    [self fillSeatsView];
}

- (void)fillSeatsView {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    for (int i = 0; i < self.testEspressos.seats.count; i++) {
        NSArray *tmpArr = self.testEspressos.seats[i];
        
        for (int j = 0; j < tmpArr.count; j++) {
            PBTestEspressosSCSeatList *seatList = tmpArr[j];
            
            PBSeatButton *seatBtn = [PBSeatButton buttonWithType:UIButtonTypeCustom];
            [self addSubview:seatBtn];
            seatBtn.frame = CGRectMake(j * self.seatBtnWidth, i * self.seatBtnHeight, self.seatBtnWidth, self.seatBtnHeight);
            seatBtn.seatList = seatList;
            
            // type表示  0过道,1座位,2换行
            // state表示 0已售,2可选(还可以继续细分不同价格,使用dmPriceId字段继续细分)
            if (seatList.type == 0) {
                continue;
            }
            
            if (seatList.type == 1) {
                if (seatList.seatInfo.state == 0) {
                    [seatBtn setImage:[UIImage imageNamed:@"pbseatselection_yishou"] forState:UIControlStateNormal];
                }
                if (seatList.seatInfo.state == 2) {
                    [seatBtn setImage:[UIImage imageNamed:@"pbseatselection_kexuan"] forState:UIControlStateNormal];
                    [seatBtn setImage:[UIImage imageNamed:@"pbseatselection_xuanzhong"] forState:UIControlStateSelected];
                }
            }
            [seatBtn addTarget:self action:@selector(seatBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)seatBtnClick:(PBSeatButton *)btn {
    btn.selected = !btn.selected;
    
    if (btn.selected == YES) {

    } else {

    }
    
    NSLog(@"seatInfo.x = %ld, seatInfo.y = %ld, seatInfo.rowNo = %@", btn.seatList.seatInfo.x, btn.seatList.seatInfo.y, btn.seatList.seatInfo.rowNo);
    
    if ([self.delegate respondsToSelector:@selector(seatsView:andSeatBtn:)]) {
        [self.delegate seatsView:self andSeatBtn:btn];
    }
}

@end
