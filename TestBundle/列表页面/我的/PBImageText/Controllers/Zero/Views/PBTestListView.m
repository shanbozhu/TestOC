//
//  PBTestListView.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBTestListView.h"
#import "PBTestListCell.h"
#import "UITableView+FDTemplateLayoutCell.h"

@interface PBTestListView ()<UITableViewDelegate, UITableViewDataSource, PBPhotoBrowserViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PBTestListView

+ (id)testListView {
    return [[[NSBundle mainBundle]loadNibNamed:@"PBTestListView" owner:nil options:nil]lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(show:) name:@"hhhh" object:nil];
}

- (void)setTestEspressos:(PBTestZeroEspressos *)testEspressos {
    _testEspressos = testEspressos;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testEspressos.pEle.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBContentModel *contentModel = self.testEspressos.pEle[indexPath.row];
    
    [tableView registerClass:[PBTestListCell class] forCellReuseIdentifier:@"PBTestListCell"];
    if ([contentModel height] == 0) {
        [self.testEspressos.pEle[indexPath.row]setHeight:[tableView fd_heightForCellWithIdentifier:@"PBTestListCell" configuration:^(id cell) {
            PBTestListCell *testListCell = cell;
            testListCell.fd_enforceFrameLayout = YES;
            
            testListCell.contentModel = self.testEspressos.pEle[indexPath.row];
        }]];
    }
    
    if (indexPath.row == self.testEspressos.pEle.count-1) {
        return [contentModel height] + 10;
    } else {
        return [contentModel height];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBTestListCell *cell = [PBTestListCell testListCellWithTableView:tableView];
    
    cell.contentModel = self.testEspressos.pEle[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    return cell;
}

- (void)show:(NSNotification *)noti {
    //NSLog(@"indexPath.row = %ld", indexPath.row);
    
    PBContentModel *contentModel = self.testEspressos.pEle[0];
    NSDictionary *info = noti.userInfo;
    PBTestListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    // 启动图片浏览器
    PBPhotoBrowserView *photoBrowserView = [PBPhotoBrowserView photoBrowserView];
#ifdef USEYYLabel
    photoBrowserView.sourceImageFatherView = cell.lab; // 原图的父控件
#else
    photoBrowserView.sourceImageFatherView = cell.textView.inputView; // 原图的父控件
#endif
    photoBrowserView.imageCount = contentModel.imageArr.count;
    photoBrowserView.currentImageIndex = [info[@"tag"] integerValue];
    photoBrowserView.sourceImageSlideView = nil;
    photoBrowserView.delegate = self;
    [photoBrowserView show];
}

// 缩略图视图
- (UIImageView *)photoBrowserView:(PBPhotoBrowserView *)photoBrowserView andThumbImageURLWithIndex:(NSInteger)index {
    PBContentModel *contentModel = self.testEspressos.pEle[0];
    NSLog(@"contentModel.imageViewArr[index] = %@", contentModel.imageViewArr[index]);
    return contentModel.imageViewArr[index];
}

// 高清图地址
- (NSURL *)photoBrowserView:(PBPhotoBrowserView *)photoBrowserView andHDImageURLWithIndex:(NSInteger)index {
    NSLog(@"index = %ld", index);
    PBContentModel *contentModel = self.testEspressos.pEle[0];
    return [NSURL URLWithString:contentModel.imageArr[index]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
