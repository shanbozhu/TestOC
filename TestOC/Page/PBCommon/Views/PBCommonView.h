//
//  PBCommonView.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/7/17.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PBCommonView;
@protocol PBCommonViewDelegate <NSObject>

- (void)commonView:(PBCommonView *)commonView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface PBCommonView : UIView

@property (nonatomic, strong) id<PBCommonViewDelegate> delegate;

+ (id)commonView;

@end

NS_ASSUME_NONNULL_END
