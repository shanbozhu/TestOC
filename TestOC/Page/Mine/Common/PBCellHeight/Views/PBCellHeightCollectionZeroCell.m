//
//  PBCellHeightCollectionZeroCell.m
//  TestOC
//
//  Created by shanbo on 2022/4/21.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightCollectionZeroCell.h"
#import <YYText.h>

@interface PBCellHeightCollectionZeroCell ()

@property (nonatomic, weak) YYLabel *lab;

@end

@implementation PBCellHeightCollectionZeroCell

+ (id)testListCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:@"PBCellHeightCollectionZeroCell"];
    PBCellHeightCollectionZeroCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PBCellHeightCollectionZeroCell" forIndexPath:indexPath];
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 1.1;
        
        {
            YYLabel *lab = [[YYLabel alloc] init];
            self.lab = lab;
            [self.contentView addSubview:lab];
            lab.numberOfLines = 0;
            lab.font = [UIFont systemFontOfSize:15];
        }
    }
    return self;
}

- (void)setTestListData:(PBCellHeightZeroData *)testListData {
    _testListData = testListData;
    
    [self fillTestListCell];
}

- (void)fillTestListCell {
    self.lab.frame = CGRectMake(20, 20, [UIScreen mainScreen].bounds.size.width - 40, 10000);
    self.lab.text = self.testListData.content;
    [self.lab sizeToFit];
    
    CGRect rect = self.frame;
    rect.size.height = CGRectGetMaxY(self.lab.frame) + 20;
    self.frame = rect;
}

- (void)dealloc {
    NSLog(@"PBCellHeightCollectionZeroCell对象被释放了");
}

@end
