//
//  DemoTaskTableViewCell.h
//  Menta-iOS_Example
//
//  Created by vlion on 2026/3/3.
//  Copyright © 2026 JiaDingYi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MentaUnifiedSDK/MentaUnifiedSDK-umbrella.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoTaskTableViewCell : UITableViewCell

- (void)updateWithAdObject:(MUVidEarnAdObject *)object;

@end

NS_ASSUME_NONNULL_END
