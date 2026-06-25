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
@property (nonatomic, strong) UILabel *shakeThresholdLabel;
@property (nonatomic, strong) UILabel *twistThresholdLabel;
@property (nonatomic, strong) UILabel *cooldownLabel;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) double shakeThreshold;
@property (nonatomic, assign) double twistThreshold;
@property (nonatomic, assign) NSTimeInterval triggerCooldown;
@property (nonatomic, assign) NSTimeInterval lastShakeTriggerTime;
@property (nonatomic, assign) NSTimeInterval lastTwistTriggerTime;

@end

@implementation PBShakeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Shake";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupMotionManager];
    [self setupDefaultParams];
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startShakeMonitoring];
    [self startTwistMonitoring];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopGyroUpdates];
}

#pragma mark - Shake

- (void)startShakeMonitoring {
    if (self.motionManager.isAccelerometerActive || !self.motionManager.isAccelerometerAvailable) {
        if (!self.motionManager.isAccelerometerAvailable) {
            self.shakeTipLabel.text = @"摇一摇：当前设备不支持加速度计";
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || error) {
            return;
        }
        
        [strongSelf detectShakeWithAccelerometerData:accelerometerData];
    }];
}

- (void)detectShakeWithAccelerometerData:(CMAccelerometerData *)accelerometerData {
    CMAcceleration acceleration = accelerometerData.acceleration;
    double accelerationValue = sqrt(acceleration.x * acceleration.x +
                                    acceleration.y * acceleration.y +
                                    acceleration.z * acceleration.z);
    
    NSTimeInterval currentTime = CACurrentMediaTime();
    if (accelerationValue >= self.shakeThreshold &&
        currentTime - self.lastShakeTriggerTime > self.triggerCooldown) {
        self.lastShakeTriggerTime = currentTime;
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
    self.motionManager.accelerometerUpdateInterval = 0.05;
    self.motionManager.gyroUpdateInterval = 0.05;
}

- (void)setupDefaultParams {
    self.shakeThreshold = 2.4;
    self.twistThreshold = 4.5;
    self.triggerCooldown = 1.0;
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
    NSTimeInterval currentTime = CACurrentMediaTime();
    if (fabs(gyroData.rotationRate.z) >= self.twistThreshold &&
        currentTime - self.lastTwistTriggerTime > self.triggerCooldown) {
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
    
    CGFloat top = CGRectGetMaxY(self.resultLabel.frame) + 30;
    self.shakeThresholdLabel = [self labelWithText:nil];
    top = [self addSliderWithTitleLabel:self.shakeThresholdLabel
                                  value:self.shakeThreshold
                               minValue:1.5
                               maxValue:4.0
                                    top:top
                                  action:@selector(shakeThresholdSliderChanged:)];
    
    self.twistThresholdLabel = [self labelWithText:nil];
    top = [self addSliderWithTitleLabel:self.twistThresholdLabel
                                  value:self.twistThreshold
                               minValue:2.0
                               maxValue:8.0
                                    top:top
                                  action:@selector(twistThresholdSliderChanged:)];
    
    self.cooldownLabel = [self labelWithText:nil];
    [self addSliderWithTitleLabel:self.cooldownLabel
                            value:self.triggerCooldown
                         minValue:0.3
                         maxValue:2.0
                              top:top
                            action:@selector(cooldownSliderChanged:)];
    
    [self updateParamLabels];
}

- (UILabel *)labelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor darkTextColor];
    label.font = [UIFont systemFontOfSize:16];
    label.numberOfLines = 0;
    return label;
}

- (CGFloat)addSliderWithTitleLabel:(UILabel *)titleLabel
                             value:(CGFloat)value
                          minValue:(CGFloat)minValue
                          maxValue:(CGFloat)maxValue
                               top:(CGFloat)top
                             action:(SEL)action {
    CGFloat left = 24;
    CGFloat width = CGRectGetWidth(self.view.bounds) - left * 2;
    
    titleLabel.frame = CGRectMake(left, top, width, 24);
    titleLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:titleLabel];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(left, CGRectGetMaxY(titleLabel.frame) + 6, width, 32)];
    slider.minimumValue = minValue;
    slider.maximumValue = maxValue;
    slider.value = value;
    [slider addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    
    return CGRectGetMaxY(slider.frame) + 16;
}

- (void)shakeThresholdSliderChanged:(UISlider *)slider {
    self.shakeThreshold = slider.value;
    [self updateParamLabels];
}

- (void)twistThresholdSliderChanged:(UISlider *)slider {
    self.twistThreshold = slider.value;
    [self updateParamLabels];
}

- (void)cooldownSliderChanged:(UISlider *)slider {
    self.triggerCooldown = slider.value;
    [self updateParamLabels];
}

- (void)updateParamLabels {
    self.shakeThresholdLabel.text = [NSString stringWithFormat:@"摇一摇阈值 %.2f，越小越灵敏", self.shakeThreshold];
    self.twistThresholdLabel.text = [NSString stringWithFormat:@"扭一扭阈值 %.2f，越小越灵敏", self.twistThreshold];
    self.cooldownLabel.text = [NSString stringWithFormat:@"触发间隔 %.2fs，越小越容易连续触发", self.triggerCooldown];
}

- (void)updateResultWithText:(NSString *)text {
    self.resultLabel.text = [NSString stringWithFormat:@"%@\n%@", text, [NSDate date]];
}

@end
