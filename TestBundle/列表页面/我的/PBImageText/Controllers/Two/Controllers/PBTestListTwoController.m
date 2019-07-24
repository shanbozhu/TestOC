//
//  PBTestListTwoController.m
//  TestBundle
//
//  Created by Zhu,Shanbo on 2019/6/26.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBTestListTwoController.h"
#import "PBTestListTwoView.h"
#import "PBTestTwoEspressos.h"

@interface PBTestListTwoController ()

@property (nonatomic, weak) PBTestListTwoView *testListTwoView;

@end

@implementation PBTestListTwoController

- (void)requestData {
    //NSString *espressos = @"『乐翻了运动生态园』园区位于北京朝阳区孙河镇顺   <p>走进蹦床乐园立刻被快乐包围，这里充满着欢声笑语、炫动的灯光、炫酷的音乐</p>  @@从亲子互动到亲朋聚会一站式满足您的运动休闲生活。@@";
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"pbimage_text" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *espressos = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
  
    //NSLog(@"espressos = %@", espressos);
    
    PBTestTwoEspressos *testTwoEspressos = [PBTestTwoEspressos testTwoEspressosWithDict:@{@"espressos":espressos}];
    self.testListTwoView.testTwoEspressos = testTwoEspressos;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PBTestListTwoView *testListTwoView = [PBTestListTwoView testListTwoView];
    self.testListTwoView = testListTwoView;
    [self.view addSubview:testListTwoView];
    testListTwoView.frame = self.view.bounds;
    
    [self requestData];
}

@end
