//
//  PBListView.h
//  PBHome
//
//  Created by DaMaiIOS on 17/9/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PBListView;
@protocol PBListViewDelegate <NSObject>

- (void)listView:(PBListView *)listView;

- (void)listView:(PBListView *)listView andScrollView:(UIScrollView *)scrollView;

@end

@interface PBListView : UIView

@property (nonatomic, strong) NSArray *listArr;

@property (nonatomic, weak) id<PBListViewDelegate> delegate;

+ (id)listView;

@end
