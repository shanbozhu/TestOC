//
//  PBLinkageSectionView.m
//  TestOC
//
//  Created by shanbo on 2022/1/12.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBLinkageSectionView.h"

@interface PBLinkageSectionView ()

@property (nonatomic, strong) HMSegmentedControl *segmentControl;

@end

@implementation PBLinkageSectionView

+ (instancetype)linkageSectionViewWithTableView:(UITableView *)tableView {
    [tableView registerClass:[self class] forHeaderFooterViewReuseIdentifier:@"PBLinkageSectionView"];
    PBLinkageSectionView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"PBLinkageSectionView"];
    return headerView;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.segmentControl];
    }
    return self;
}

- (HMSegmentedControl *)segmentControl {
    if (!_segmentControl) {
        NSArray *titles = @[@"page1",@"page2",@"page3"];
        _segmentControl = [[HMSegmentedControl alloc] initWithSectionTitles:titles];
        _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentControl.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _segmentControl.selectionIndicatorHeight = 5;
        _segmentControl.selectionIndicatorColor = [UIColor redColor];
        
        NSDictionary *attributesNormal = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil];
        NSDictionary *attributesSelected = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14], NSFontAttributeName, [UIColor blueColor], NSForegroundColorAttributeName, nil];
        _segmentControl.titleTextAttributes = attributesNormal;
        _segmentControl.selectedTitleTextAttributes = attributesSelected;
    }
    return _segmentControl;
}

@end
