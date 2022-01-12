//
//  PBLinkageSectionView.m
//  TestOC
//
//  Created by shanbo on 2022/1/12.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBLinkageSectionView.h"

@implementation PBLinkageSectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.segmentControl];
    }
    return self;
}

- (HMSegmentedControl *)segmentControl {
    if (!_segmentControl) {
        NSArray *titles = @[@"page 1",@"page 2",@"page 3"];
        _segmentControl = [[HMSegmentedControl alloc] initWithSectionTitles:titles];
        _segmentControl.frame = CGRectMake(0, 0, APPLICATION_FRAME_WIDTH, 60);
        _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentControl.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _segmentControl.selectionIndicatorHeight = 5;
        _segmentControl.selectionIndicatorColor = [UIColor redColor];
        
        NSDictionary *attributesNormal = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"PingFangSC-Regular" size:14],NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName,nil];
        NSDictionary *attributesSelected = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"PingFangSC-Semibold" size:14],NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName,nil];
        _segmentControl.titleTextAttributes = attributesNormal;
        _segmentControl.selectedTitleTextAttributes = attributesSelected;
    }
    return _segmentControl;
}

@end
