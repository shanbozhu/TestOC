//
//  PBShakeTwoController.m
//  TestOC
//
//  Created by Codex on 2026/6/26.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBShakeTwoController.h"
#import <CoreMotion/CoreMotion.h>

static const double kPBShakeTwoGravityStandard = 9.80665;
#define PBRadiansToDegrees(radians) ((radians) * (180.0 / M_PI))

typedef NS_ENUM(NSInteger, PBShakeTwoMotionType) {
    PBShakeTwoMotionTypeShake,
    PBShakeTwoMotionTypeTwist
};

typedef NS_ENUM(NSInteger, PBShakeTwoDirectionMode) {
    PBShakeTwoDirectionModeSingle,
    PBShakeTwoDirectionModeDouble
};

typedef NS_ENUM(NSInteger, PBShakeTwoConditionMode) {
    PBShakeTwoConditionModeOr,
    PBShakeTwoConditionModeAnd
};

@interface PBShakeTwoMotionConfig : NSObject

@property (nonatomic, assign) PBShakeTwoMotionType type;
@property (nonatomic, assign) PBShakeTwoDirectionMode directionMode;
@property (nonatomic, assign) PBShakeTwoConditionMode conditionMode;

/// 线性加速度阈值，单位是 m/s^2。生产配置里常用这个过滤“轻微移动”。
@property (nonatomic, assign) double accelerationThreshold;
/// 姿态角度阈值，单位是度。生产配置里常用这个判断“摇/扭的幅度够不够”。
@property (nonatomic, assign) double angleThreshold;
/// 手势持续时间阈值，单位是秒。用于过滤瞬间误触。
@property (nonatomic, assign) NSTimeInterval durationThreshold;
/// 允许动作中断的最大时间，超过后重置本轮识别。
@property (nonatomic, assign) NSTimeInterval idleTimeout;
/// 小于该角度认为没有有效动作，用来判断本轮动作是否还在继续。
@property (nonatomic, assign) double miniSwingAngle;

@end

@implementation PBShakeTwoMotionConfig

- (instancetype)init {
    if (self = [super init]) {
        self.directionMode = PBShakeTwoDirectionModeSingle;
        self.conditionMode = PBShakeTwoConditionModeOr;
        self.accelerationThreshold = 9.8;
        self.angleThreshold = 30.0;
        self.durationThreshold = 0.2;
        self.idleTimeout = 0.5;
        self.miniSwingAngle = 2.0;
    }
    return self;
}

@end

@interface PBShakeTwoController ()

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) NSOperationQueue *motionQueue;
@property (nonatomic, strong) PBShakeTwoMotionConfig *currentConfig;

@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *configLabel;
@property (nonatomic, strong) UILabel *resultLabel;

@property (nonatomic, strong, nullable) CMAttitude *startAttitude;
@property (nonatomic, strong, nullable) NSDate *startActiveTime;
@property (nonatomic, strong, nullable) NSDate *lastActiveTime;

@property (nonatomic, assign) double lastDx;
@property (nonatomic, assign) double lastDy;
@property (nonatomic, assign) double lastDz;
@property (nonatomic, assign) double unwrapDx;
@property (nonatomic, assign) double unwrapDy;
@property (nonatomic, assign) double unwrapDz;

@property (nonatomic, assign) BOOL hasXPos;
@property (nonatomic, assign) BOOL hasXNeg;
@property (nonatomic, assign) BOOL hasXPosToCenter;
@property (nonatomic, assign) BOOL hasXNegToCenter;
@property (nonatomic, assign) BOOL hasYPos;
@property (nonatomic, assign) BOOL hasYNeg;
@property (nonatomic, assign) BOOL hasYPosToCenter;
@property (nonatomic, assign) BOOL hasYNegToCenter;
@property (nonatomic, assign) BOOL hasZPos;
@property (nonatomic, assign) BOOL hasZNeg;
@property (nonatomic, assign) BOOL hasZPosToCenter;
@property (nonatomic, assign) BOOL hasZNegToCenter;

@property (nonatomic, assign) double triggerAcceleration;
@property (nonatomic, assign) double triggerAngle;
@property (nonatomic, assign) double triggerX;
@property (nonatomic, assign) double triggerY;
@property (nonatomic, assign) double triggerZ;

@end

@implementation PBShakeTwoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Shake Two";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupMotionManager];
    [self setupUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopMotionUpdates];
}

#pragma mark - Setup

- (void)setupMotionManager {
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 0.1;
    self.motionQueue = [[NSOperationQueue alloc] init];
    self.motionQueue.name = @"com.testoc.shaketwo.motion";
}

- (void)setupUI {
    CGFloat left = 24;
    CGFloat width = CGRectGetWidth(self.view.bounds) - left * 2;
    
    UILabel *titleLabel = [self labelWithText:@"生产风格：用 DeviceMotion 融合数据做动作识别"];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.frame = CGRectMake(left, 110, width, 28);
    [self.view addSubview:titleLabel];
    
    UILabel *descLabel = [self labelWithText:@"核心思想：以第一帧姿态为基准，后续计算相对角度；同时可组合加速度、角度、持续时间、单双向动作。"];
    descLabel.frame = CGRectMake(left, CGRectGetMaxY(titleLabel.frame) + 8, width, 62);
    [self.view addSubview:descLabel];
    
    UIButton *shakeButton = [self buttonWithTitle:@"启动摇一摇识别"];
    shakeButton.frame = CGRectMake(left, CGRectGetMaxY(descLabel.frame) + 18, (width - 12) / 2, 44);
    [shakeButton addTarget:self action:@selector(startShakeDemo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shakeButton];
    
    UIButton *twistButton = [self buttonWithTitle:@"启动扭一扭识别"];
    twistButton.frame = CGRectMake(CGRectGetMaxX(shakeButton.frame) + 12, CGRectGetMinY(shakeButton.frame), CGRectGetWidth(shakeButton.frame), 44);
    [twistButton addTarget:self action:@selector(startTwistDemo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:twistButton];
    
    UIButton *stopButton = [self buttonWithTitle:@"停止检测"];
    stopButton.frame = CGRectMake(left, CGRectGetMaxY(shakeButton.frame) + 12, width, 44);
    [stopButton addTarget:self action:@selector(stopMotionUpdates) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopButton];
    
    self.stateLabel = [self labelWithText:@"状态：未启动"];
    self.stateLabel.frame = CGRectMake(left, CGRectGetMaxY(stopButton.frame) + 18, width, 24);
    [self.view addSubview:self.stateLabel];
    
    self.configLabel = [self labelWithText:@"配置：点击上方按钮后展示"];
    self.configLabel.frame = CGRectMake(left, CGRectGetMaxY(self.stateLabel.frame) + 8, width, 86);
    [self.view addSubview:self.configLabel];
    
    self.resultLabel = [self labelWithText:@"触发结果：等待动作触发"];
    self.resultLabel.frame = CGRectMake(left, CGRectGetMaxY(self.configLabel.frame) + 12, width, 128);
    self.resultLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.resultLabel.layer.borderWidth = 1.0;
    self.resultLabel.layer.cornerRadius = 6.0;
    self.resultLabel.layer.masksToBounds = YES;
    [self.view addSubview:self.resultLabel];
}

#pragma mark - Demo Entrances

- (void)startShakeDemo {
    PBShakeTwoMotionConfig *config = [[PBShakeTwoMotionConfig alloc] init];
    config.type = PBShakeTwoMotionTypeShake;
    config.directionMode = PBShakeTwoDirectionModeSingle;
    config.conditionMode = PBShakeTwoConditionModeOr;
    config.accelerationThreshold = 11.0;
    config.angleThreshold = 30.0;
    config.durationThreshold = 0.2;
    
    [self startMotionUpdatesWithConfig:config];
}

- (void)startTwistDemo {
    PBShakeTwoMotionConfig *config = [[PBShakeTwoMotionConfig alloc] init];
    config.type = PBShakeTwoMotionTypeTwist;
    config.directionMode = PBShakeTwoDirectionModeSingle;
    config.conditionMode = PBShakeTwoConditionModeAnd;
    config.accelerationThreshold = 0;
    config.angleThreshold = 35.0;
    config.durationThreshold = 0.2;
    
    [self startMotionUpdatesWithConfig:config];
}

#pragma mark - Motion Lifecycle

- (void)startMotionUpdatesWithConfig:(PBShakeTwoMotionConfig *)config {
    if (!self.motionManager.isDeviceMotionAvailable) {
        self.stateLabel.text = @"状态：当前设备不支持 DeviceMotion";
        return;
    }
    
    [self stopMotionUpdates];
    
    self.currentConfig = config;
    [self resetAllGestureStates];
    [self updateConfigTextWithConfig:config];
    
    self.stateLabel.text = config.type == PBShakeTwoMotionTypeShake ? @"状态：正在检测摇一摇" : @"状态：正在检测扭一扭";
    self.resultLabel.text = @"触发结果：检测中...";
    
    __weak typeof(self) weakSelf = self;
    [self.motionManager startDeviceMotionUpdatesToQueue:self.motionQueue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || !motion || error) {
            return;
        }
        
        [strongSelf handleDeviceMotion:motion atTime:[NSDate date]];
    }];
}

- (void)stopMotionUpdates {
    [self.motionManager stopDeviceMotionUpdates];
    [self resetAllGestureStates];
    self.currentConfig = nil;
    self.stateLabel.text = @"状态：已停止";
}

- (void)handleDeviceMotion:(CMDeviceMotion *)motion atTime:(NSDate *)now {
    if (self.currentConfig.type == PBShakeTwoMotionTypeShake) {
        [self checkShakeWithMotion:motion atTime:now];
    } else {
        [self checkTwistWithMotion:motion atTime:now];
    }
}

#pragma mark - Shake

- (void)checkShakeWithMotion:(CMDeviceMotion *)motion atTime:(NSDate *)now {
    PBShakeTwoMotionConfig *config = self.currentConfig;
    if (![self prepareGestureIfNeededWithMotion:motion atTime:now]) {
        return;
    }
    
    CMAttitude *deltaAttitude = [self deltaAttitudeWithMotion:motion];
    double dx = PBRadiansToDegrees(deltaAttitude.pitch);
    double dy = PBRadiansToDegrees(deltaAttitude.roll);
    double dz = PBRadiansToDegrees(deltaAttitude.yaw);
    
    if (![self refreshActiveTimeIfGestureIsMovingWithDx:dx dy:dy dz:dz now:now config:config]) {
        return;
    }
    
    BOOL accelerationMet = [self checkAccelerationWithMotion:motion config:config];
    BOOL angleMet = [self checkAnyAxisAngleWithDx:dx dy:dy dz:dz config:config];
    BOOL durationMet = [self checkDurationWithNow:now config:config];
    
    BOOL allMet = NO;
    if (config.conditionMode == PBShakeTwoConditionModeAnd) {
        allMet = accelerationMet && angleMet && durationMet;
    } else {
        allMet = (accelerationMet || angleMet) && durationMet;
    }
    
    if (allMet) {
        [self triggerMotionWithTitle:@"摇一摇触发"];
    }
}

#pragma mark - Twist

- (void)checkTwistWithMotion:(CMDeviceMotion *)motion atTime:(NSDate *)now {
    PBShakeTwoMotionConfig *config = self.currentConfig;
    if (![self prepareGestureIfNeededWithMotion:motion atTime:now]) {
        return;
    }
    
    CMAttitude *deltaAttitude = [self deltaAttitudeWithMotion:motion];
    double dx = PBRadiansToDegrees(deltaAttitude.pitch);
    double dy = PBRadiansToDegrees(deltaAttitude.roll);
    double dz = PBRadiansToDegrees(deltaAttitude.yaw);
    
    if (![self refreshActiveTimeIfGestureIsMovingWithDx:dx dy:dy dz:dz now:now config:config]) {
        return;
    }
    
    // 这里贴近 MVlionMotionManager 的写法：扭一扭主要观察 roll，也就是 Y 轴方向的相对角度变化。
    BOOL angleMet = [self checkYAxisAngleWithDy:dy config:config];
    BOOL durationMet = [self checkDurationWithNow:now config:config];
    
    if (angleMet && durationMet) {
        [self triggerMotionWithTitle:@"扭一扭触发"];
    }
}

#pragma mark - Common Detection Steps

- (BOOL)prepareGestureIfNeededWithMotion:(CMDeviceMotion *)motion atTime:(NSDate *)now {
    if (self.startAttitude) {
        return YES;
    }
    
    // 第一帧只做“基准姿态”记录。后面的角度都相对于这帧计算，而不是直接使用手机的绝对姿态。
    self.startAttitude = [motion.attitude copy];
    self.startActiveTime = now;
    self.lastActiveTime = now;
    [self resetDirectionStates];
    return NO;
}

- (CMAttitude *)deltaAttitudeWithMotion:(CMDeviceMotion *)motion {
    // multiplyByInverseOfAttitude: 可以把当前姿态换算成“相对于起始姿态变化了多少”。
    CMAttitude *deltaAttitude = [motion.attitude copy];
    [deltaAttitude multiplyByInverseOfAttitude:self.startAttitude];
    return deltaAttitude;
}

- (BOOL)refreshActiveTimeIfGestureIsMovingWithDx:(double)dx
                                             dy:(double)dy
                                             dz:(double)dz
                                            now:(NSDate *)now
                                         config:(PBShakeTwoMotionConfig *)config {
    BOOL isMoving = fabs(dx) > config.miniSwingAngle || fabs(dy) > config.miniSwingAngle || fabs(dz) > config.miniSwingAngle;
    BOOL isIdleTooLong = self.lastActiveTime && [now timeIntervalSinceDate:self.lastActiveTime] > config.idleTimeout;
    if (!isMoving || isIdleTooLong) {
        [self resetAllGestureStates];
        return NO;
    }
    
    self.lastActiveTime = now;
    return YES;
}

- (BOOL)checkAccelerationWithMotion:(CMDeviceMotion *)motion config:(PBShakeTwoMotionConfig *)config {
    if (config.accelerationThreshold <= 0) {
        return YES;
    }
    
    // userAcceleration 已经去掉重力分量，单位是 G；乘以 9.80665 后换算成 m/s^2，便于和业务阈值对齐。
    CMAcceleration acceleration = motion.userAcceleration;
    double totalG = sqrt(acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z * acceleration.z);
    self.triggerAcceleration = totalG * kPBShakeTwoGravityStandard;
    return self.triggerAcceleration >= config.accelerationThreshold;
}

- (BOOL)checkAnyAxisAngleWithDx:(double)dx dy:(double)dy dz:(double)dz config:(PBShakeTwoMotionConfig *)config {
    if (config.angleThreshold <= 0) {
        return YES;
    }
    
    BOOL xMet = [self updateXAxisWithDx:dx config:config];
    BOOL yMet = [self updateYAxisWithDy:dy config:config];
    BOOL zMet = [self updateZAxisWithDz:dz config:config];
    
    if (xMet) {
        self.triggerAngle = self.unwrapDx;
    } else if (yMet) {
        self.triggerAngle = self.unwrapDy;
    } else if (zMet) {
        self.triggerAngle = self.unwrapDz;
    }
    
    self.triggerX = self.unwrapDx;
    self.triggerY = self.unwrapDy;
    self.triggerZ = self.unwrapDz;
    
    return xMet || yMet || zMet;
}

- (BOOL)checkYAxisAngleWithDy:(double)dy config:(PBShakeTwoMotionConfig *)config {
    if (config.angleThreshold <= 0) {
        return YES;
    }
    
    BOOL yMet = [self updateYAxisWithDy:dy config:config];
    self.triggerAngle = self.unwrapDy;
    self.triggerY = self.unwrapDy;
    return yMet;
}

- (BOOL)updateXAxisWithDx:(double)dx config:(PBShakeTwoMotionConfig *)config {
    self.unwrapDx += [self normalizedAngleDeltaFrom:dx to:self.lastDx];
    self.lastDx = dx;
    
    double threshold = config.angleThreshold;
    if (self.unwrapDx >= threshold) self.hasXPos = YES;
    if (self.unwrapDx <= -threshold) self.hasXNeg = YES;
    if (self.hasXPos && self.unwrapDx < 0) self.hasXPosToCenter = YES;
    if (self.hasXNeg && self.unwrapDx > 0) self.hasXNegToCenter = YES;
    
    return [self isAxisMetWithPositive:self.hasXPos
                              negative:self.hasXNeg
                      positiveToCenter:self.hasXPosToCenter
                      negativeToCenter:self.hasXNegToCenter
                                config:config];
}

- (BOOL)updateYAxisWithDy:(double)dy config:(PBShakeTwoMotionConfig *)config {
    self.unwrapDy += [self normalizedAngleDeltaFrom:dy to:self.lastDy];
    self.lastDy = dy;
    
    double threshold = config.angleThreshold;
    if (self.unwrapDy >= threshold) self.hasYPos = YES;
    if (self.unwrapDy <= -threshold) self.hasYNeg = YES;
    if (self.hasYPos && self.unwrapDy < 0) self.hasYPosToCenter = YES;
    if (self.hasYNeg && self.unwrapDy > 0) self.hasYNegToCenter = YES;
    
    return [self isAxisMetWithPositive:self.hasYPos
                              negative:self.hasYNeg
                      positiveToCenter:self.hasYPosToCenter
                      negativeToCenter:self.hasYNegToCenter
                                config:config];
}

- (BOOL)updateZAxisWithDz:(double)dz config:(PBShakeTwoMotionConfig *)config {
    self.unwrapDz += [self normalizedAngleDeltaFrom:dz to:self.lastDz];
    self.lastDz = dz;
    
    double threshold = config.angleThreshold;
    if (self.unwrapDz >= threshold) self.hasZPos = YES;
    if (self.unwrapDz <= -threshold) self.hasZNeg = YES;
    if (self.hasZPos && self.unwrapDz < 0) self.hasZPosToCenter = YES;
    if (self.hasZNeg && self.unwrapDz > 0) self.hasZNegToCenter = YES;
    
    return [self isAxisMetWithPositive:self.hasZPos
                              negative:self.hasZNeg
                      positiveToCenter:self.hasZPosToCenter
                      negativeToCenter:self.hasZNegToCenter
                                config:config];
}

- (BOOL)isAxisMetWithPositive:(BOOL)positive
                     negative:(BOOL)negative
             positiveToCenter:(BOOL)positiveToCenter
             negativeToCenter:(BOOL)negativeToCenter
                       config:(PBShakeTwoMotionConfig *)config {
    if (config.directionMode == PBShakeTwoDirectionModeDouble) {
        // 双向：正向超过阈值并回到中心、负向超过阈值并回到中心，才算一次完整往复。
        return positive && positiveToCenter && negative && negativeToCenter;
    }
    
    // 单向：任意方向超过阈值即可，适合灵敏但误触略多的场景。
    return positive || negative;
}

- (BOOL)checkDurationWithNow:(NSDate *)now config:(PBShakeTwoMotionConfig *)config {
    if (config.durationThreshold <= 0) {
        return YES;
    }
    
    return self.startActiveTime && [now timeIntervalSinceDate:self.startActiveTime] >= config.durationThreshold;
}

#pragma mark - Trigger

- (void)triggerMotionWithTitle:(NSString *)title {
    NSString *resultText = [NSString stringWithFormat:@"%@\nacc: %.2f m/s^2\nx: %.2f, y: %.2f, z: %.2f\nangle: %.2f\n%@",
                            title,
                            self.triggerAcceleration,
                            fabs(self.triggerX),
                            fabs(self.triggerY),
                            fabs(self.triggerZ),
                            fabs(self.triggerAngle),
                            [NSDate date]];
    
    // 生产环境通常触发后立即 stop，避免同一轮动作重复回调。
    [self.motionManager stopDeviceMotionUpdates];
    [self resetAllGestureStates];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.stateLabel.text = @"状态：已触发并停止";
        self.resultLabel.text = resultText;
    });
}

#pragma mark - Helpers

- (double)normalizedAngleDeltaFrom:(double)current to:(double)last {
    // 姿态角范围是 -180 到 180。直接相减会在边界出现 359 度跳变，所以这里做“解环”。
    double delta = current - last;
    if (delta > 180) {
        delta -= 360;
    } else if (delta < -180) {
        delta += 360;
    }
    return delta;
}

- (void)resetAllGestureStates {
    self.startAttitude = nil;
    self.startActiveTime = nil;
    self.lastActiveTime = nil;
    [self resetDirectionStates];
}

- (void)resetDirectionStates {
    self.lastDx = self.lastDy = self.lastDz = 0;
    self.unwrapDx = self.unwrapDy = self.unwrapDz = 0;
    
    self.hasXPos = self.hasXNeg = self.hasXPosToCenter = self.hasXNegToCenter = NO;
    self.hasYPos = self.hasYNeg = self.hasYPosToCenter = self.hasYNegToCenter = NO;
    self.hasZPos = self.hasZNeg = self.hasZPosToCenter = self.hasZNegToCenter = NO;
    
    self.triggerAcceleration = 0;
    self.triggerAngle = 0;
    self.triggerX = 0;
    self.triggerY = 0;
    self.triggerZ = 0;
}

- (void)updateConfigTextWithConfig:(PBShakeTwoMotionConfig *)config {
    NSString *typeText = config.type == PBShakeTwoMotionTypeShake ? @"摇一摇" : @"扭一扭";
    NSString *directionText = config.directionMode == PBShakeTwoDirectionModeDouble ? @"双向往复" : @"单向";
    NSString *conditionText = config.conditionMode == PBShakeTwoConditionModeAnd ? @"AND" : @"OR";
    self.configLabel.text = [NSString stringWithFormat:@"配置：%@\n角度 %.1f 度，加速度 %.1f m/s^2，持续 %.1fs\n方向：%@，条件：%@",
                             typeText,
                             config.angleThreshold,
                             config.accelerationThreshold,
                             config.durationThreshold,
                             directionText,
                             conditionText];
}

- (UILabel *)labelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor darkTextColor];
    label.font = [UIFont systemFontOfSize:14];
    label.numberOfLines = 0;
    return label;
}

- (UIButton *)buttonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.backgroundColor = [UIColor colorWithRed:0.18 green:0.45 blue:0.88 alpha:1.0];
    button.layer.cornerRadius = 6;
    button.layer.masksToBounds = YES;
    return button;
}

@end
