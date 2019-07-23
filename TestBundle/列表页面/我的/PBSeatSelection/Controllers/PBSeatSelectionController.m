//
//  PBSeatSelectionController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBSeatSelectionController.h"
#import "PBSeatSelectionView.h"
#import "PBTestEspressos.h"
#import "YYFPSLabel.h"
#import "AFNetworking.h"
#import <YYModel/YYModel.h>
#import "PBTestEspressos.h"

@interface PBSeatSelectionController ()

@property (nonatomic, weak) PBSeatSelectionView *seatSelectionView;

@end

@implementation PBSeatSelectionController

- (void)requestData {
    // 大麦app, 开心麻花.戏剧新体验<婿事待发> 08-25周五19:30场次
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"https://mapi.damai.cn/B2B2C/Seat/getSeatInfo.aspx?cityId=852&osType=3&pfId=2138521420&source=10099&standId=1699297&version=50808" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
    
        NSLog(@"jsonStr = %@", [jsonDict yy_modelToJSONString]);
        
        PBTestEspressos *testEspressos = [PBTestEspressos yy_modelWithDictionary:jsonDict];
        
        self.seatSelectionView.testEspressos = testEspressos;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.automaticallyAdjustsScrollViewInsets = NO; //取消默认自动将scrollView的内边距设为64

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];

    PBSeatSelectionView *seatSelectionView = [PBSeatSelectionView seatSelectionViewWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 100 - 36)];
    self.seatSelectionView = seatSelectionView;
    [self.view addSubview:seatSelectionView];
    
    [self requestData];
}

@end
