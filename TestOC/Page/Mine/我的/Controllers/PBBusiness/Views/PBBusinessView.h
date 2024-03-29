//
//  PBBusinessView.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/7/17.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PBBusinessView;
@protocol PBBusinessViewDelegate <NSObject>

- (void)businessView:(PBBusinessView *)businessView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface PBBusinessView : UIView

@property (nonatomic, strong) id<PBBusinessViewDelegate> delegate;
@property (nonatomic, strong) NSArray *pageArr;

+ (id)businessView;

@end

NS_ASSUME_NONNULL_END
