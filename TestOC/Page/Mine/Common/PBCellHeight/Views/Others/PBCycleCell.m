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
        lab.font = [UIFont systemFontOfSize:15];
        
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
    CGFloat imageWidth = ([UIScreen mainScreen].bounds.size.width - 13 * 2 - 10) / 2.0;
    self.lab.frame = CGRectMake(0, 0, imageWidth, 10000);
    //self.lab.text = self.testListData.content;
    self.lab.text = [NSString stringWithFormat:@"%ld", self.index];
    [self.lab sizeToFit];
}

- (void)dealloc {
    NSLog(@"PBCycleCell对象被释放了");
}

@end
