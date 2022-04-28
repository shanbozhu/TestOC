//
//  PBCycleCell.m
//  TestOC
//
//  Created by shanbo on 2022/4/21.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCycleCell.h"
#import <YYText.h>

@interface PBCycleCell ()

@property (nonatomic, weak) YYLabel *lab;

@end

@implementation PBCycleCell

+ (id)testListCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:@"PBCycleCell"];
    PBCycleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PBCycleCell" forIndexPath:indexPath];
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        YYLabel *lab = [[YYLabel alloc] init];
        self.lab = lab;
        [self.contentView addSubview:lab];
        lab.numberOfLines = 0;
        lab.font = [UIFont boldSystemFontOfSize:15];
        lab.textAlignment = NSTextAlignmentCenter;
        
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 1.1;
    }
    return self;
}

- (void)setTestListData:(PBCellHeightZeroData *)testListData {
    _testListData = testListData;
    [self fillTestListCell];
}

- (void)fillTestListCell {
    self.lab.frame = self.bounds;
    self.lab.text = [NSString stringWithFormat:@"%@", self.testListData.content];
}

- (void)dealloc {
    NSLog(@"PBCycleCell对象被释放了");
}

@end
