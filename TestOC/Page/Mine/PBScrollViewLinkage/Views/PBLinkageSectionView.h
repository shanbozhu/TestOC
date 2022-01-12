//
//  PBLinkageSectionView.h
//  TestOC
//
//  Created by shanbo on 2022/1/12.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMSegmentedControl.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBLinkageSectionView : UITableViewHeaderFooterView

@property (nonatomic, strong) HMSegmentedControl *segmentControl;

+ (instancetype)linkageSectionViewWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
