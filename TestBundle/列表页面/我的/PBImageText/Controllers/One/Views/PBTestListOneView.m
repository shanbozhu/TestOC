//
//  PBTestListOneView.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBTestListOneView.h"
#import "PBTestListOneCell.h"
#import "UITableView+FDTemplateLayoutCell.h"


@interface PBTestListOneView ()<UITableViewDelegate, UITableViewDataSource, PBPhotoBrowserViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *indexArr;

@end

@implementation PBTestListOneView

- (NSMutableArray *)indexArr {
    if (_indexArr == nil) {
        _indexArr = [NSMutableArray array];
    }
    return _indexArr;
}

+ (id)testListOneView {
    return [[[NSBundle mainBundle]loadNibNamed:@"PBTestListOneView" owner:nil options:nil]lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setTestOneEspressos:(PBTestOneEspressos *)testOneEspressos {
    _testOneEspressos = testOneEspressos;
    
    // indexArr存储所有是图片的模型对象所在原数组的下标(索引)
    for (int i = 0; i < self.testOneEspressos.pEle.count; i++) {
        PBContentOneModel *contentOneModel = self.testOneEspressos.pEle[i];
        if (contentOneModel.isImg == YES) {
            [self.indexArr addObject:[NSNumber numberWithInteger:i]];
        }
    }
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testOneEspressos.pEle.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBContentOneModel *contentOneModel = self.testOneEspressos.pEle[indexPath.row];
    
    if (contentOneModel.isImg == YES) {
        [tableView registerClass:[PBTestListOneCell class] forCellReuseIdentifier:@"imageView"];
        if ([contentOneModel height] == 0) {
            [contentOneModel setHeight:[tableView fd_heightForCellWithIdentifier:@"imageView" configuration:^(id cell) {
                
                PBTestListOneCell *testListOneCell = cell;
                testListOneCell.fd_enforceFrameLayout = YES;
                
                testListOneCell.contentOneModel = contentOneModel;
            }]];
        }
        
        if (indexPath.row == self.testOneEspressos.pEle.count-1) {
            return [contentOneModel height] + 10;
        } else {
            return [contentOneModel height];
        }
    } else {
        [tableView registerClass:[PBTestListOneCell class] forCellReuseIdentifier:@"lab"];
        if ([contentOneModel height] == 0) {
            [contentOneModel setHeight:[tableView fd_heightForCellWithIdentifier:@"lab" configuration:^(id cell) {
                
                PBTestListOneCell *testListOneCell = cell;
                testListOneCell.fd_enforceFrameLayout = YES;
                
                testListOneCell.contentOneModel = contentOneModel;
            }]];
        }
        if (indexPath.row == self.testOneEspressos.pEle.count-1) {
            return [contentOneModel height] + 10;
        } else {
            return [contentOneModel height];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBContentOneModel *contentOneModel = self.testOneEspressos.pEle[indexPath.row];
    
    if (contentOneModel.isImg == YES) {
        PBTestListOneCell *cell = [PBTestListOneCell testListOneCellWithTableView:tableView andReuseIdentifier:@"imageView"];
        cell.contentOneModel = contentOneModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        return cell;
    } else {
        PBTestListOneCell *cell = [PBTestListOneCell testListOneCellWithTableView:tableView andReuseIdentifier:@"lab"];
        cell.contentOneModel = contentOneModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PBContentOneModel *contentOneModel = self.testOneEspressos.pEle[indexPath.row];
    
    if (contentOneModel.isImg == YES) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        //启动图片浏览器
        PBPhotoBrowserView *photoBrowserView = [PBPhotoBrowserView photoBrowserView];
        photoBrowserView.sourceImageFatherView = cell.contentView; //原图的父控件
        photoBrowserView.imageCount = self.testOneEspressos.imageObjs.count;
        photoBrowserView.currentImageIndex = [self.testOneEspressos.imageObjs indexOfObject:contentOneModel.src];
        photoBrowserView.sourceImageSlideView = tableView;
        photoBrowserView.imgModelIndexArr = self.indexArr;
        photoBrowserView.delegate = self;
        [photoBrowserView show];
    }
}

// 缩略图视图
- (UIImageView *)photoBrowserView:(PBPhotoBrowserView *)photoBrowserView andThumbImageURLWithIndex:(NSInteger)index {
    PBContentOneModel *contentOneModel = self.testOneEspressos.pEle[[self.indexArr[index] integerValue]];
    
    NSLog(@"index = %ld, contentOneModel = %d", index, contentOneModel.isImg);
    
    if (contentOneModel.isImg == YES) {
        PBTestListOneCell *cell = (PBTestListOneCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.indexArr[index] integerValue] inSection:0]];
        return cell.oneImageView;
    }
    return nil;
}

// 高清图地址
- (NSURL *)photoBrowserView:(PBPhotoBrowserView *)photoBrowserView andHDImageURLWithIndex:(NSInteger)index {
    NSLog(@"index = %ld", index);
    return [NSURL URLWithString:self.testOneEspressos.imageObjs[index]];
}

@end
