//
//  DemoMUVidEarnViewController.m
//  Menta-iOS_Example
//
//  Created by vlion on 2026/3/3.
//  Copyright © 2026 JiaDingYi. All rights reserved.
//

#import "DemoMUVidEarnViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <MentaUnifiedSDK/MentaUnifiedSDK-umbrella.h>
#import "DemoTaskTableViewCell.h"

@interface DemoMUVidEarnData : NSObject

@end

@implementation DemoMUVidEarnData

+ (instancetype)sharedInstance {
    static DemoMUVidEarnData *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DemoMUVidEarnData alloc] init];
    });
    return instance;
}

@end

@interface DemoMUVidEarnViewController () <MentaUnifiedVidEarnAdDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) MentaUnifiedVidEarnAd *vidEarnAd;
@property (nonatomic, assign) BOOL isLoded;
@property (nonatomic, strong) NSArray<MUVidEarnAdObject *> *adObjects;

@end


@implementation DemoMUVidEarnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addButtonWithTitle:@"用户注册" action:@selector(showUserRegisterAlert)];
    [self addButtonWithTitle:@"加载广告" action:@selector(loadAd)];
    [self addButtonWithTitle:@"展现广告" action:@selector(showAd)];
    [self addButtonWithTitle:@"使用缓存刷新" action:@selector(cacheRefresh)];
    //[self addButtonWithTitle:@"媒体跳转按钮" action:@selector(go)];
}

- (void)go {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *schema = [NSURL URLWithString:@"baiduboxlite://"];
    [application openURL:schema options:@{} completionHandler:^(BOOL success) {
    }];
}

- (NSString *)defaultSlotId {
    return @"P3486,P3487,P3488,P3489,P3490";
}

- (MentaUnifiedVidEarnAd *)createAd {
    if (self.vidEarnAd) {
        self.vidEarnAd.delegate = nil;
        self.vidEarnAd = nil;
    }
    
    NSArray *ids = [self.currentSlotId componentsSeparatedByString:@","];
    
    MUVidEarnAdConfig *config = MUVidEarnAdConfig.new;
    config.slotIds = ids;
    config.viewController = self;
    /**
    config.taskTextProvider = ^MUVidEarnAdTaskText * _Nullable(MUVidEarnAdTask *task) {
        MUVidEarnAdTaskText *taskText = MUVidEarnAdTaskText.new;
        switch (task.taskStatus) {
            case MUVidEarnAdTaskStatusReady:
                taskText.btnTitle = @"立即去做";
                taskText.taskMessage = task.type == MUVidEarnAdTaskTypeAppDownload ? @"请从当前页面下载安装，完成后可领取奖励" : @"请从当前页面打开指定 App，完成后可领取奖励";
                break;
            case MUVidEarnAdTaskStatusStarted:
                taskText.btnTitle = @"继续打开";
                taskText.taskMessage = @"检测到您已经开始任务，请打开并停留10秒领取奖励";
                break;
            case MUVidEarnAdTaskStatusClientFinished:
                taskText.btnTitle = @"等待发奖";
                taskText.taskMessage = @"任务已提交，奖励预计3小时内发放";
                break;
            case MUVidEarnAdTaskStatusServerFinished:
                taskText.btnTitle = @"已领取";
                taskText.taskMessage = @"奖励已发放，请在发放记录中查看";
                break;
        }
        return taskText;
    };
     */
    
    MentaUnifiedVidEarnAd *nativeAd = [[MentaUnifiedVidEarnAd alloc] initWithConfig:config];
    nativeAd.delegate = self;
    return nativeAd;
}

- (void)showUserRegisterAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"注册"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"媒体用户Id";
        textField.text = @"1";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"媒体用户手机号";
        textField.text = @"18888888888";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"用户签名";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *userId = alertController.textFields[0].text;
        NSString *phone = alertController.textFields[1].text;
        NSString *sign = alertController.textFields[2].text;
        
        [self userRegisterWithUserId:userId phone:phone sign:sign];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)userRegisterWithUserId:(NSString *)userId phone:(NSString *)phone sign:(NSString *)sign {
    if (!self.vidEarnAd) {
        self.vidEarnAd = [self createAd];
    }
    
    MUVidEarnAdAppUser *appUser = MUVidEarnAdAppUser.new;
    appUser.userId = userId;              // 媒体用户Id
    appUser.md5Phone = [self md5:phone];  // md5手机号
    appUser.sign = sign;                  // 用户签名（用于后端校验用户有效性）
    [self.vidEarnAd userRegister:appUser];
}

- (void)loadAd {
    [self appendLog:@"开始加载广告"];
    
    NSString *slotId = self.currentSlotId;
    if (!slotId || !slotId.length) {
        [self appendLog:@"加载失败，广告位Id为空"];
        return;
    }
    
    self.isLoded = NO;
    self.vidEarnAd = [self createAd];    // ⚠️每次都要重新创建
    [self.vidEarnAd loadAd];
}

- (void)showAd {
    if (!self.isLoded) {
        [self appendLog:@"广告物料未加载成功"];
        return;
    }
    
    // 展示任务列表
    [self showTaskList];
}

- (void)feedback {
    if (!self.vidEarnAd) {
        self.vidEarnAd = [self createAd];
    }
    
    MUVidEarnAdFeedback *feedback = MUVidEarnAdFeedback.new;
    feedback.desc = @"反馈描述内容";
    [self.vidEarnAd feedback:feedback];
}

- (void)cacheRefresh {
    NSArray *objs = [[NSUserDefaults standardUserDefaults] objectForKey:@"impressionId"];
    self.vidEarnAd = [self createAd];    // ⚠️每次都要重新创建
    __weak typeof(self) weakSelf = self;
    [self.vidEarnAd adObjectsForImpressionIds:objs completion:^(NSArray<MUVidEarnAdObject *> * _Nullable adObjects, NSError * _Nullable error) {
        weakSelf.adObjects = adObjects;
        [weakSelf showTaskList];
    }];
}

#pragma mark - Private

- (NSString *)md5:(NSString *)string {
    const char *cStr = string.UTF8String;
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);

    NSMutableString *out = [NSMutableString stringWithCapacity:32];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [out appendFormat:@"%02x", digest[i]];
    }
    return out;
}

- (void)showTaskList {
    if (!self.tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                       self.currentY,
                                                                       self.view.bounds.size.width,
                                                                       self.maxY - self.currentY - 50)];
        self.tableView.backgroundColor = UIColor.blackColor;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self.tableView registerClass:DemoTaskTableViewCell.class forCellReuseIdentifier:NSStringFromClass(DemoTaskTableViewCell.class)];
        [self.view addSubview:self.tableView];
    }
    
    [self.tableView reloadData];
}

#pragma mark - MentaUnifiedVidEarnAdDelegate

/**
 广告加载成功

 @param ad 广告对象
 @param objects 广告对象数组
 */
- (void)menta_vidEarnAd:(MentaUnifiedVidEarnAd *)ad didLoadWithAdObjects:(NSArray<MUVidEarnAdObject *> *)objects {
    [self appendLog:[NSString stringWithFormat:@"广告加载成功，数量：%ld", objects.count]];
    
    self.adObjects = objects;
    self.isLoded = YES;
    
    // 来自网络请求数据
    NSMutableArray *objs = [NSMutableArray array];
    for (MUVidEarnAdObject *ad in self.adObjects) {
        [objs addObject:ad.impressionId];
    }
    [[NSUserDefaults standardUserDefaults] setObject:objs forKey:@"impressionId"];
}

/**
 广告加载失败

 @param ad 广告对象
 @param error 错误
 */
- (void)menta_vidEarnAd:(MentaUnifiedVidEarnAd *)ad didFailToLoadWithError:(NSError *)error {
    [self appendLog:[NSString stringWithFormat:@"广告加载失败：%@", error.localizedDescription]];
    
    self.adObjects = nil;
    self.isLoded = NO;
}

/**
 广告曝光成功回调
 
 @param ad 广告对象
 @param object 广告对象
 */
- (void)menta_vidEarnAd:(MentaUnifiedVidEarnAd *)ad didExposeWithAdObject:(MUVidEarnAdObject *)object {
    [self appendLog:[NSString stringWithFormat:@"广告曝光：%@ TaskCode:%@", object.slotId, object.task.code]];
}

/**
 广告曝光失败
 
 @param ad 广告对象
 @param object 广告对象
 @param error 错误
 */
- (void)menta_vidEarnAd:(MentaUnifiedVidEarnAd *)ad didFailToExposeWithAdObject:(MUVidEarnAdObject *)object error:(nullable NSError *)error {
    [self appendLog:[NSString stringWithFormat:@"广告曝光失败：%@ TaskCode:%@ Error:%@", object.slotId, object.task.code, error]];
}

/**
 广告点击回调
 
 @param ad 广告对象
 @param object 广告对象
 */
- (void)menta_vidEarnAd:(MentaUnifiedVidEarnAd *)ad didClickWithAdObject:(MUVidEarnAdObject *)object {
    [self appendLog:[NSString stringWithFormat:@"广告点击：%@ TaskCode:%@", object.slotId, object.task.code]];
}

/**
 广告关闭
 
 @param ad 广告对象
 @param object 广告对象
 */
- (void)menta_vidEarnAd:(MentaUnifiedVidEarnAd *)ad didCloseWithAdObject:(MUVidEarnAdObject *)object {
    [self appendLog:[NSString stringWithFormat:@"广告关闭：%@", object.slotId]];
}

/**
 用户注册成功

 @param ad 广告对象
 @param user 用户信息
 */
- (void)menta_vidEarnAd:(MentaUnifiedVidEarnAd *)ad userDidRegisterWithUser:(MUVidEarnAdUser *)user {
    [self appendLog:[NSString stringWithFormat:@"广告用户注册成功：%@", user.userId]];
}

/**
 用户注册失败

 @param ad 广告对象
 @param error 错误
 */
- (void)menta_vidEarnAd:(MentaUnifiedVidEarnAd *)ad userDidFailToRegisterWithError:(NSError *)error {
    [self appendLog:[NSString stringWithFormat:@"广告用户注册失败：%@", error]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.adObjects ? self.adObjects.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DemoTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(DemoTaskTableViewCell.class)
                                                                  forIndexPath:indexPath];
    
    MUVidEarnAdObject *adObj = self.adObjects[indexPath.row];
    [cell updateWithAdObject:adObj];
    
    return cell;
}

@end
