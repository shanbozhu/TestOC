//
//  PBAVPlayerListController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBAVPlayerListController.h"
#import "PBAVPlayerListView.h"
#import "PBAVPlayerList.h"
#import "YYFPSLabel.h"
#import "TFHpple.h"
#import "AFNetworking.h"
#import <YYModel/YYModel.h>
#import "PBAVPlayerListCell.h"
#import "PBPlayerView.h"
#import "PBGCDTimerManager.h"

@interface PBAVPlayerListController ()<PBAVPlayerListCellDelegate>

@property (nonatomic, weak) PBAVPlayerListView *testListView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, assign) NSInteger randomId;

@end

@implementation PBAVPlayerListController

- (BOOL)pb_panGestureRecognizerEnabled {
    return NO;
}

- (void)requestData {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"PBAVPlayerList" ofType:@"json"]];
        NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

        NSMutableArray *objs = [NSMutableArray array];
        for (NSDictionary *dict in jsonArr) {
            PBAVPlayerList *testList = [PBAVPlayerList yy_modelWithDictionary:dict];
            [objs addObject:testList];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.testListView.testEspressosArr = objs;
            self.testListView.hidden = NO;
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];

    PBAVPlayerListView *testListView = [PBAVPlayerListView testListView];
    self.testListView = testListView;
    [self.view addSubview:testListView];
    testListView.frame = self.view.bounds;
    testListView.hidden = YES;
    
    [self requestData];
}

- (void)testListCell:(PBAVPlayerListCell *)testListCell andTestEspressos:(PBAVPlayerList *)testEspressos {
    PBPlayerView *playerView = [PBPlayerView playerViewWithFrame:CGRectMake(0, 0, testListCell.frame.size.width, 300)];
    [testListCell.contentView addSubview:playerView];
    
    playerView.url = testEspressos.videoUrl;
    
    [playerView playVideo];
}

@end
