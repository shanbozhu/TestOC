//
//  PBTestListOneController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBTestListOneController.h"
#import "PBTestListOneView.h"
#import "PBTestOneEspressos.h"
#import "YYFPSLabel.h"
#import "TFHpple.h"
#import "PBContentOneModel.h"
#import "AFNetworking.h"

@interface PBTestListOneController ()

@property (nonatomic, weak) PBTestListOneView *testListOneView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, assign) NSInteger randomId;

@end

@implementation PBTestListOneController

- (void)requestData {
    //NSString *espressos = @"『乐翻了运动生态园』园区位于北京朝阳区孙河镇顺   <p>走进蹦床乐园立刻被快乐包围，这里充满着欢声笑语、炫动的灯光、炫酷的音乐</p>  @@从亲子互动到亲朋聚会一站式满足您的运动休闲生活。@@";
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"pbimage_text" ofType:@"html"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *espressos = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    //NSLog(@"espressos = %@", espressos);
    
    PBTestOneEspressos *testOneEspressos = [PBTestOneEspressos testOneEspressosWithHtmlStr:espressos];
    self.testListOneView.testOneEspressos = testOneEspressos;
    self.testListOneView.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];

    PBTestListOneView *testListOneView = [PBTestListOneView testListOneView];
    self.testListOneView = testListOneView;
    [self.view addSubview:testListOneView];
    testListOneView.frame = self.view.bounds;
    testListOneView.hidden = YES;
    
    [self requestData];
}

@end
