//
//  PBLinkageContainerCell.h
//  TestOC
//
//  Created by shanbo on 2022/1/12.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kSectionViewHeight 70
#define kHeight ([UIScreen mainScreen].bounds.size.height - ([UIApplication sharedApplication].statusBarFrame.size.height + 44) - kSectionViewHeight - kSectionViewHeight)

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
