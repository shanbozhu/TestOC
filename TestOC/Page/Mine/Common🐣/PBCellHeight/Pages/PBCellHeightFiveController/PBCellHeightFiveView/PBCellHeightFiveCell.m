//
//  PBCellHeightFiveCell.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/16.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightFiveCell.h"
#import <YYText.h>
#import <Masonry.h>

static CGFloat const labFont = 15;

static NSString * const kPBCellHeightFiveCellTitleRect = @"kPBCellHeightFiveCellTitleRect";
static NSString * const kPBCellHeightFiveCellImageRect = @"kPBCellHeightFiveCellImageRect";

@interface PBCellHeightFiveCell ()

@property (nonatomic, weak) YYLabel *lab;
@property (nonatomic, weak) UIImageView *oneImageView;

@end

@implementation PBCellHeightFiveCell

#pragma mark - init

- (void)dealloc {
    NSLog(@"PBCellHeightFiveCell对象被释放了");
}

+ (instancetype)testListFiveCellWithTableView:(UITableView *)tableView {
    [tableView registerClass:[self class] forCellReuseIdentifier:@"PBCellHeightFiveCell"];
    PBCellHeightFiveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PBCellHeightFiveCell"];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //
        YYLabel *lab = [[YYLabel alloc] init];
        self.lab = lab;
        [self.contentView addSubview:lab];
        lab.numberOfLines = 0;
        lab.font = [UIFont systemFontOfSize:labFont];
        lab.layer.borderColor = [UIColor redColor].CGColor;
        lab.layer.borderWidth = 1.1;
        
        //
        UIImageView *imageView = [[UIImageView alloc] init];
        self.oneImageView = imageView;
        [self.contentView addSubview:imageView];
        imageView.layer.borderColor = [UIColor redColor].CGColor;
        imageView.layer.borderWidth = 1.1;
    }
    return self;
}

- (void)setTestListData:(PBCellHeightZeroData *)testListData {
    _testListData = testListData;
    [self configWithViewModel:testListData];
}

#pragma mark - config

- (void)configWithViewModel:(PBCellHeightZeroData *)testListData {
    //
    CGRect titleRect = [[self.testListData.layoutInfoMutDic valueForKey:kPBCellHeightFiveCellTitleRect] CGRectValue];
    self.lab.frame = titleRect;
    self.lab.text = self.testListData.content;
    
    //
    CGRect imageRect = [[self.testListData.layoutInfoMutDic valueForKey:kPBCellHeightFiveCellImageRect] CGRectValue];
    self.oneImageView.frame = imageRect;
}

#pragma mark - calculateLayout

+ (void)calculateLayoutWithViewModel:(PBCellHeightZeroData *)testListData preferredSize:(CGSize)preferredSize {
    if (![testListData isKindOfClass:[PBCellHeightZeroData class]] ||
        testListData.layoutCalculated) {
        return;
    }
    
    //
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, CGFLOAT_MAX);
    
    // labRect
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:testListData.content];
    [attStr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:labFont]} range:NSMakeRange(0, testListData.content.length)];
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:attStr];
    CGRect titleRect = CGRectMake(20, 20, layout.textBoundingSize.width, layout.textBoundingSize.height);
    [testListData.layoutInfoMutDic setValue:@(titleRect) forKey:kPBCellHeightFiveCellTitleRect];
    
    // imageViewRect
    CGRect ImageRect = CGRectMake(CGRectGetMinX(titleRect), CGRectGetMaxY(titleRect) + 10, 150, 50 * (1 + arc4random_uniform(3)));
    [testListData.layoutInfoMutDic setObject:@(ImageRect) forKey:kPBCellHeightFiveCellImageRect];
    
    // cellHeight
    CGFloat cellHeight = CGRectGetMaxY(ImageRect) + 20;
    [testListData.layoutInfoMutDic setObject:@(cellHeight) forKey:HEIGHT_Cell];
    testListData.layoutCalculated = YES;
}

@end
