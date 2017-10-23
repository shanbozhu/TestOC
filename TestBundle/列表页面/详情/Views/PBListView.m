//
//  PBListView.m
//  PBHome
//
//  Created by DaMaiIOS on 17/9/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBListView.h"
#import "PBListCell.h"
#import "UIImage+ImageEffects.h"
#import <YYText/YYText.h>

@interface PBListView ()<UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) UITableView *tableView;

@property(nonatomic, weak)UIImageView *imageView;

@end

@implementation PBListView

+(id)listView {
    return [[self alloc]initWithFrame:CGRectZero];
}

-(id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        self.tableView = tableView;
        [self addSubview:tableView];
        //tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
        tableView.contentInset = UIEdgeInsetsMake(44+150, 0, 0, 0);
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        
        //缩放视图
        UIView *bgView = [[UIView alloc]init];
        tableView.backgroundView = bgView;
        //bgView.frame = CGRectMake(0, 0, tableView.frame.size.width, 0);
        bgView.backgroundColor = [UIColor redColor];
        
        
        UIImageView *imageView = [[UIImageView alloc]init];
        self.imageView = imageView;
        [bgView addSubview:imageView];
        imageView.frame = CGRectMake(0, 0, tableView.frame.size.width, 64+150);
        imageView.backgroundColor = [UIColor yellowColor];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //imageView.image = [UIImage imageNamed:@"pbhome_sport_headerline"];
        imageView.image = [[UIImage imageNamed:@"pbhome_header.jpg"] applyLightEffect];
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
        [imageView addGestureRecognizer:tap];
        
        
        
        UIView *coverView = [[UIView alloc]init];
        [bgView addSubview:coverView];
        coverView.frame = bgView.bounds;
        coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        coverView.backgroundColor = [UIColor colorWithRed:22/255.0 green:6/255.0 blue:34/255.0 alpha:0.4];
        //coverView.backgroundColor = [UIColor redColor];
        coverView.userInteractionEnabled = YES;
        
        
        
        //测试
        UIButton *otherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [tableView addSubview:otherBtn];
        otherBtn.frame = CGRectMake(20, -70, 120, 120);
        otherBtn.backgroundColor = [UIColor yellowColor];
        [otherBtn addTarget:self action:@selector(otherBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        YYLabel *otherLab = [[YYLabel alloc]init];
        [tableView addSubview:otherLab];
        otherLab.frame = CGRectMake(CGRectGetMaxX(otherBtn.frame)+20, -70, [UIScreen mainScreen].bounds.size.width-20-(CGRectGetMaxX(otherBtn.frame)+20), 100);
        otherLab.numberOfLines = 3;
        otherLab.textColor = [UIColor whiteColor];
        otherLab.text = @"收到货发动机佛挡杀佛鼎折覆餗电话发了多少见风使舵缴费基数的势均力敌返回了肯定是金粉世家东方丽景是独立放假时间到分类";
        [otherLab sizeToFit];
        otherLab.textTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            NSLog(@"点击了标题");
        };
    }
    return self;
}

-(void)otherBtnClick:(UIButton *)btn {
    NSLog(@"点击了头像");
}

-(void)tapClick:(UITapGestureRecognizer *)tap {
    NSLog(@"点击了背景图片");
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self.delegate listView:self andScrollView:scrollView];
    
    
    if (scrollView.contentOffset.y < -(150+64)) {
        CGFloat sx = scrollView.contentOffset.y / -(150+64);
        self.imageView.transform = CGAffineTransformMakeScale(sx, sx);
        
//        self.imageView.center = CGPointMake(self.frame.size.width/2.0, self.imageView.frame.size.height/2.0);
        self.imageView.center = CGPointMake(self.frame.size.width/2.0, self.imageView.frame.size.height/2.0);
    } else {
        
//        CGFloat sx = scrollView.contentOffset.y / -(150+64);
//        self.imageView.transform = CGAffineTransformMakeScale(sx, sx);
        
        //        self.imageView.center = CGPointMake(self.frame.size.width/2.0, self.imageView.frame.size.height/2.0);
        //self.imageView.center = CGPointMake(self.frame.size.width/2.0, self.imageView.frame.size.height/2.0);
        
        
        CGRect rect = self.imageView.frame;
        rect.origin.y = -(scrollView.contentOffset.y + (150+64)) * 0.3;
        self.imageView.frame = rect;
        
    }
}



-(void)setListArr:(NSArray *)listArr {
    _listArr = listArr;
    
    [self.tableView reloadData];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.listArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PBListCell *cell = [PBListCell listCellWithTableView:tableView];
    
    cell.list = self.listArr[indexPath.row];
    
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate listView:self];
}

@end
