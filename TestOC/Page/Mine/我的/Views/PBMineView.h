//
//  PBMineView.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/7/17.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PBMineView;
@protocol PBMineViewDelegate <NSObject>

- (void)mineView:(PBMineView *)mineView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface PBMineView : UIView

@property (nonatomic, strong) id<PBMineViewDelegate> delegate;
@property (nonatomic, strong) NSArray *pageArr;

+ (id)mineView;

@end

NS_ASSUME_NONNULL_END
