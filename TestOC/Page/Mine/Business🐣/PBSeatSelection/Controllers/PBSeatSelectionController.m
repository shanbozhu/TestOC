//
//  PBSeatSelectionController.m
//  TestOC
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
    // 大麦app，开心麻花.戏剧新体验<婿事待发> 08-25周五19:30场次
    
    /**
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
     */
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *path = [[NSBundle mainBundle]pathForResource:@"pbseat_selection" ofType:@"json"];
            NSString *jsonStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"jsonDict = %@", jsonDict);
            
            PBTestEspressos *testEspressos = [PBTestEspressos yy_modelWithDictionary:jsonDict];
            
            self.seatSelectionView.testEspressos = testEspressos;
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.automaticallyAdjustsScrollViewInsets = NO; // 取消自动调节ScrollView内边距

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];

    PBSeatSelectionView *seatSelectionView = [PBSeatSelectionView seatSelectionViewWithFrame:CGRectMake(0, APPLICATION_NAVIGATIONBAR_HEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - APPLICATION_NAVIGATIONBAR_HEIGHT - APPLICATION_SAFE_AREA_BOTTOM_MARGIN)];
    self.seatSelectionView = seatSelectionView;
    [self.view addSubview:seatSelectionView];
    
    [self requestData];
}

@end
