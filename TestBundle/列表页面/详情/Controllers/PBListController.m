//
//  PBListController.m
//  PBHome
//
//  Created by DaMaiIOS on 17/9/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBListController.h"
#import "PBListView.h"
#import "PBList.h"
#import "PBListTwoController.h"


@interface PBListController ()<PBListViewDelegate>

@property(nonatomic, weak)PBListView *listView;

@property(nonatomic, weak)UIView *barView;

@end

@implementation PBListController

-(void)requestData {
    
    
    
    NSMutableArray *objs = [NSMutableArray array];
    for (int i = 0; i < 20; i++) {
        
        PBList *testEspressos = [[PBList alloc]init];
        testEspressos.summaryText = @"这是测试GOGOGO!";
        
        [objs addObject:testEspressos];
    }
    
    NSLog(@"objs.count = %ld", objs.count);
    
    self.listView.listArr = objs;
    
}

//-(BOOL)pb_panGestureRecognizerEnabled {
//    return NO;
//}
-(BOOL)pb_navigationBarHidden {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    //self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
    
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    PBListView *listView = [PBListView listView];
    self.listView = listView;
    [self.view addSubview:listView];
    listView.frame = self.view.bounds;
    listView.delegate = self;
    
    [self requestData];
    
    
    UIView *barView = [[UIView alloc]init];
    self.barView = barView;
    [listView addSubview:barView];
    barView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
    barView.backgroundColor = [UIColor blueColor];
    barView.alpha = 0.0;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [barView.superview addSubview:backBtn];
    backBtn.frame = CGRectMake(20, 25, 40, 44-10);
    backBtn.backgroundColor = [UIColor redColor];
    backBtn.alpha = 1;
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)backBtnClick:(UIButton *)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)listView:(PBListView *)listView andScrollView:(UIScrollView *)scrollView {
    
    
    NSLog(@"scrollView.contentOffset.y = %lf", scrollView.contentOffset.y);
    if (scrollView.contentOffset.y <= -(44+20+150)) {
        self.barView.alpha = 0;
    } else if (scrollView.contentOffset.y > -(44+20+150) && scrollView.contentOffset.y < -(44+20)) {
        self.barView.alpha = 1-fabsf(scrollView.contentOffset.y+44+20)/(150);
    } else {
        self.barView.alpha = 1;
    }
    NSLog(@"self.barView.alpha = %f", self.barView.alpha);
    
    

}

-(void)listView:(PBListView *)listView {
    
    PBListTwoController *vc = [[PBListTwoController alloc]init];
    vc.hidesBottomBarWhenPushed = YES;
    //[self.tabBarController.navigationController pushViewController:vc animated:YES];
    [self.navigationController pushViewController:vc animated:YES];
    vc.view.backgroundColor = [UIColor whiteColor];
}



@end
