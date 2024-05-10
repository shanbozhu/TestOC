//
//  PBLinkageContainerCell.h
//  TestOC
//
//  Created by shanbo on 2022/1/12.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kSectionZeroViewHeight 50
#define kSectionViewHeight 70
#define kHeight (APPLICATION_FRAME_HEIGHT - APPLICATION_NAVIGATIONBAR_HEIGHT - kSectionViewHeight - kSectionZeroViewHeight)

@protocol PBLinkageContainerCellDelegate <NSObject>

@optional
- (void)linkageContainerCellScrollViewDidScroll:(UIScrollView *)scrollView;

- (void)linkageContainerCellScrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end

@interface PBLinkageContainerCell : UITableViewCell

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, assign) BOOL objectCanScroll;
@property (nonatomic, weak) id <PBLinkageContainerCellDelegate> delegate;

+ (instancetype)linkageContainerCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
