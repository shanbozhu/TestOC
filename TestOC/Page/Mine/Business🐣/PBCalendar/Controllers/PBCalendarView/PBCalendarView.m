//
//  PBCalendarView.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/4/20.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCalendarView.h"
#import "PBCalendarCell.h"
#import "PBCalendar.h"

@interface PBCalendarView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UILabel *titleLab;
@property (nonatomic, strong) NSArray *weekArr;
@property (nonatomic, strong) NSArray *dayArr;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSMutableDictionary *mutDict;
@property (nonatomic, strong) PBCalendar *calendar;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, copy) NSString *nowYearMonth;

@end

@implementation PBCalendarView

+ (id)calendarViewWithFrame:(CGRect)frame {
    return [[self alloc]initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 显示的年月
        UILabel *titleLab = [[UILabel alloc]init];
        self.titleLab = titleLab;
        [self addSubview:titleLab];
        titleLab.frame = CGRectMake((self.frame.size.width-120)/2.0, 20, 120, 20);
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.backgroundColor = [UIColor redColor];
        
        // 上一月
        UIButton *lastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:lastBtn];
        lastBtn.frame = CGRectMake(20, 20, 60, 20);
        [lastBtn setTitle:@"上一月" forState:UIControlStateNormal];
        [lastBtn addTarget:self action:@selector(lastBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [lastBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        lastBtn.backgroundColor = [UIColor redColor];
        
        // 下一月
        UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:nextBtn];
        nextBtn.frame = CGRectMake(self.frame.size.width-20-60, 20, 60, 20);
        [nextBtn setTitle:@"下一月" forState:UIControlStateNormal];
        [nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        nextBtn.backgroundColor = [UIColor redColor];
        
        // 星期
        CGFloat width = self.frame.size.width / 7.0;
        NSArray *weekArr = @[@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六"];
        self.weekArr = weekArr;
        NSMutableArray *weekBtnArr = [NSMutableArray array];
        for (int i = 0; i < weekArr.count; i++) {
            UIButton *weekBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self addSubview:weekBtn];
            weekBtn.frame = CGRectMake(i * width, CGRectGetMaxY(nextBtn.frame), width, width);
            [weekBtn setTitle:weekArr[i] forState:UIControlStateNormal];
            [weekBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            weekBtn.backgroundColor = [UIColor redColor];
            [weekBtnArr addObject:weekBtn];
        }
        
        // 日
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY([weekBtnArr.lastObject frame]), self.frame.size.width, self.frame.size.height-CGRectGetMaxY([weekBtnArr.lastObject frame])) collectionViewLayout:flowLayout];
        self.collectionView = collectionView;
        [self addSubview:collectionView];
        collectionView.backgroundColor = [UIColor yellowColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.alwaysBounceVertical = YES;
        
        // 初始化数据
        PBCalendar *calendar = [[PBCalendar alloc]init];
        self.calendar = calendar;
        calendar.dateBlock = ^(NSInteger year, NSInteger month) {
            self.titleLab.text = [NSString stringWithFormat:@"%ld年%ld月", year, month];
            
            if (self.nowYearMonth == nil) {
                self.nowYearMonth = self.titleLab.text;
            }
        };
        
        self.dayArr = [calendar setDayArr];
        self.index = calendar.index;
        self.mutDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)lastBtnClick:(UIButton *)btn {
    [self.mutDict removeAllObjects];
    self.dayArr = [self.calendar lastMonthDataArr];
    [self.collectionView reloadData];
}

- (void)nextBtnClick:(UIButton *)btn {
    [self.mutDict removeAllObjects];
    self.dayArr = [self.calendar nextMonthDataArr];
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.mutDict removeAllObjects];
    [self.mutDict setValue:@"haha" forKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dayArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PBCalendarCell *cell = [PBCalendarCell calendarCellWithCollectionView:collectionView indexPath:indexPath];
    cell.lab.text = self.dayArr[indexPath.row];
    
    if (indexPath.row == self.index && [self.nowYearMonth isEqualToString:self.titleLab.text]) {
        cell.backgroundColor = [UIColor lightGrayColor];
    } else {
        if ([[self.mutDict valueForKey:[NSString stringWithFormat:@"%ld", indexPath.row]] isEqualToString:@"haha"]) {
            cell.backgroundColor = [UIColor redColor];
        } else {
            cell.backgroundColor = [UIColor clearColor];
        }
    }
    
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.frame.size.width/7.0, self.frame.size.width/7.0);
}

@end
