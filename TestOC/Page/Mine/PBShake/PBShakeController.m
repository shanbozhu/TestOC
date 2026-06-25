//
//  PBShakeController.m
//  TestOC
//
//  Created by zhushanbo on 2026/6/25.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBShakeController.h"
#import <CoreMotion/CoreMotion.h>

@interface PBShakeController ()

@property (nonatomic, strong) UILabel *shakeTipLabel;
@property (nonatomic, strong) UILabel *twistTipLabel;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) NSTimeInterval lastTwistTriggerTime;

@end

@implementation PBShakeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Shake";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    [self setupMotionManager];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self becomeFirstResponder];
    [self startTwistMonitoring];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self resignFirstResponder];
    [self.motionManager stopGyroUpdates];
}

#pragma mark - Shake

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [super motionEnded:motion withEvent:event];
    
    if (motion == UIEventSubtypeMotionShake) {
        [self handleShakeAction];
    }
}

- (void)handleShakeAction {
    NSLog(@"摇一摇触发");
    [self updateResultWithText:@"摇一摇触发了 handleShakeAction"];
}

#pragma mark - Twist

- (void)setupMotionManager {
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.gyroUpdateInterval = 0.1;
}

- (void)startTwistMonitoring {
    if (self.motionManager.isGyroActive || !self.motionManager.isGyroAvailable) {
        if (!self.motionManager.isGyroAvailable) {
            self.twistTipLabel.text = @"扭一扭：当前设备不支持陀螺仪";
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || error) {
            return;
        }
        
        [strongSelf detectTwistWithGyroData:gyroData];
    }];
}

- (void)detectTwistWithGyroData:(CMGyroData *)gyroData {
    // rotationRate.z 表示手机绕屏幕垂直方向旋转，适合演示“扭一扭”。
    static const double kTwistThreshold = 4.5;
    static const NSTimeInterval kTwistCooldown = 1.0;
    
    NSTimeInterval currentTime = CACurrentMediaTime();
    if (fabs(gyroData.rotationRate.z) >= kTwistThreshold &&
        currentTime - self.lastTwistTriggerTime > kTwistCooldown) {
        self.lastTwistTriggerTime = currentTime;
        [self handleTwistAction];
    }
}

- (void)handleTwistAction {
    NSLog(@"扭一扭触发");
    [self updateResultWithText:@"扭一扭触发了 handleTwistAction"];
}

#pragma mark - UI

- (void)setupUI {
    CGFloat left = 24;
    CGFloat width = CGRectGetWidth(self.view.bounds) - left * 2;
    
    self.shakeTipLabel = [self labelWithText:@"摇一摇：快速晃动手机，触发 handleShakeAction"];
    self.shakeTipLabel.frame = CGRectMake(left, 120, width, 50);
    [self.view addSubview:self.shakeTipLabel];
    
    self.twistTipLabel = [self labelWithText:@"扭一扭：像拧瓶盖一样旋转手机，触发 handleTwistAction"];
    self.twistTipLabel.frame = CGRectMake(left, CGRectGetMaxY(self.shakeTipLabel.frame) + 18, width, 50);
    [self.view addSubview:self.twistTipLabel];
    
    self.resultLabel = [self labelWithText:@"等待手势触发"];
    self.resultLabel.frame = CGRectMake(left, CGRectGetMaxY(self.twistTipLabel.frame) + 32, width, 80);
    self.resultLabel.textAlignment = NSTextAlignmentCenter;
    self.resultLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.resultLabel.layer.borderWidth = 1.0;
    self.resultLabel.layer.cornerRadius = 6.0;
    self.resultLabel.layer.masksToBounds = YES;
    [self.view addSubview:self.resultLabel];
}

- (UILabel *)labelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor darkTextColor];
    label.font = [UIFont systemFontOfSize:16];
    label.numberOfLines = 0;
    return label;
}

- (void)updateResultWithText:(NSString *)text {
    self.resultLabel.text = [NSString stringWithFormat:@"%@\n%@", text, [NSDate date]];
}

@end
