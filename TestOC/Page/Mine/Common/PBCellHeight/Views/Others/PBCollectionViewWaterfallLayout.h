//
//  PBCollectionViewWaterfallLayout.h
//  TestOC
//
//  Created by shanbo on 2022/4/23.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PBCollectionViewWaterfallLayout;
@protocol PBCollectionViewWaterfallLayoutDelegate <NSObject>

@required
- (CGFloat)collectionViewWaterfallLayout:(PBCollectionViewWaterfallLayout *)PBCollectionViewWaterfallLayout heightForRowAtIndexPath:(NSInteger)index itemWidth:(CGFloat)itemWidth;

@optional
- (CGFloat)colCountInCollectionViewWaterfallLayout:(PBCollectionViewWaterfallLayout *)PBCollectionViewWaterfallLayout;
- (CGFloat)colMarginInCollectionViewWaterfallLayout:(PBCollectionViewWaterfallLayout *)PBCollectionViewWaterfallLayout;
- (CGFloat)rowMarginInCollectionViewWaterfallLayout:(PBCollectionViewWaterfallLayout *)PBCollectionViewWaterfallLayout;
- (UIEdgeInsets)edgeInsetsInCollectionViewWaterfallLayout:(PBCollectionViewWaterfallLayout *)PBCollectionViewWaterfallLayout;

@end

@interface PBCollectionViewWaterfallLayout : UICollectionViewLayout

@property (nonatomic ,weak) id<PBCollectionViewWaterfallLayoutDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
