//
//  PBShakeThreeController.m
//  TestOC
//
//  Created by Codex on 2026/9/29.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBShakeThreeController.h"
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, PBHeadingSwingDirection) {
    PBHeadingSwingDirectionUnknown = 0,
    PBHeadingSwingDirectionClockwise,
    PBHeadingSwingDirectionCounterclockwise
};

/// 将识别参数集中到一个对象中，方便线上按设备、场景或实验组动态下发。
@interface PBHeadingShakeConfig : NSObject

/// 小于该值的单帧方向变化视为罗盘噪声，单位：度。
@property (nonatomic, assign) CLLocationDirection noiseThreshold;
/// 同一方向累计达到该角度后，才算一次有效摆动，单位：度。
@property (nonatomic, assign) CLLocationDirection singleSwingThreshold;
/// 触发前至少需要完成多少段交替摆动。
@property (nonatomic, assign) NSInteger requiredSwingCount;
/// 整个动作累计的绝对角度至少达到该值，避免只在阈值附近轻微抖动。
@property (nonatomic, assign) CLLocationDirection totalAngleThreshold;
/// 两次有效采样间隔超过该值，则认为上一轮动作已经中断。
@property (nonatomic, assign) NSTimeInterval idleTimeout;
/// 一轮动作允许的最长时间；太慢的方向变化更像正常转身，而不是摇动。
@property (nonatomic, assign) NSTimeInterval maximumDuration;
/// 航向精度大于该值时忽略样本。CLHeading 的精度单位同样是度。
@property (nonatomic, assign) CLLocationDirection maximumHeadingAccuracy;

@end

@implementation PBHeadingShakeConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.noiseThreshold = 1.5;
        self.singleSwingThreshold = 12.0;
        self.requiredSwingCount = 2;
        self.totalAngleThreshold = 45.0;
        self.idleTimeout = 0.45;
        self.maximumDuration = 1.8;
        self.maximumHeadingAccuracy = 35.0;
    }
    return self;
}

@end

@interface PBShakeThreeController () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) PBHeadingShakeConfig *config;

@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *headingLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UILabel *resultLabel;

@property (nonatomic, assign) BOOL pendingStartAfterAuthorization;
@property (nonatomic, assign) BOOL isDetecting;

/// 上一帧磁北方向。NAN 表示还没有收到有效样本。
@property (nonatomic, assign) CLLocationDirection lastHeading;
/// 当前正在累计的摆动方向。
@property (nonatomic, assign) PBHeadingSwingDirection currentDirection;
/// 当前方向已经累计的有符号角度。
@property (nonatomic, assign) CLLocationDirection currentSegmentAngle;
/// 已经完成且达到阈值的摆动段数。
@property (nonatomic, assign) NSInteger completedSwingCount;
/// 本轮动作累计的绝对角度。
@property (nonatomic, assign) CLLocationDirection totalAngle;
@property (nonatomic, assign) NSTimeInterval gestureStartTime;
@property (nonatomic, assign) NSTimeInterval lastActiveTime;

@end

@implementation PBShakeThreeController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Shake Three";
    self.view.backgroundColor = [UIColor whiteColor];

    [self setupHeadingManager];
    [self setupUI];
    [self resetGestureState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self stopHeadingDetection];
}

#pragma mark - Setup

- (void)setupHeadingManager {
    self.config = [[PBHeadingShakeConfig alloc] init];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    // headingFilter 是系统回调的最小角度变化。这里设为 1 度，既保留响应速度，
    // 又避免 kCLHeadingFilterNone 带来过多无意义回调。
    self.locationManager.headingFilter = 1.0;

    // 本示例固定按竖屏解释设备顶部指向。若业务支持横屏，需要跟随界面方向更新它。
    self.locationManager.headingOrientation = CLDeviceOrientationPortrait;
}

- (void)setupUI {
    CGFloat left = 24.0;
    CGFloat width = CGRectGetWidth(self.view.bounds) - left * 2.0;

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];

    UILabel *titleLabel = [self labelWithText:@"方向替代方案：CLLocationManager + CLHeading"];
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.frame = CGRectMake(left, 110.0, width, 28.0);
    [scrollView addSubview:titleLabel];

    UILabel *descriptionLabel = [self labelWithText:@"这里的“位置方向”是电子罗盘航向，不是 GPS 坐标。它通过短时间内多次左右反向旋转来模拟摇一摇，适合作为受限场景的降级方案，但不能识别纯平移晃动。"];
    descriptionLabel.frame = CGRectMake(left, CGRectGetMaxY(titleLabel.frame) + 8.0, width, 88.0);
    [scrollView addSubview:descriptionLabel];

    UIButton *startButton = [self buttonWithTitle:@"启动方向摇一摇识别"];
    startButton.frame = CGRectMake(left, CGRectGetMaxY(descriptionLabel.frame) + 16.0, width, 44.0);
    [startButton addTarget:self action:@selector(startHeadingDetection) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:startButton];

    UIButton *stopButton = [self buttonWithTitle:@"停止检测"];
    stopButton.frame = CGRectMake(left, CGRectGetMaxY(startButton.frame) + 10.0, width, 44.0);
    [stopButton addTarget:self action:@selector(stopHeadingDetection) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:stopButton];

    self.stateLabel = [self labelWithText:@"状态：未启动"];
    self.stateLabel.frame = CGRectMake(left, CGRectGetMaxY(stopButton.frame) + 18.0, width, 24.0);
    [scrollView addSubview:self.stateLabel];

    self.headingLabel = [self labelWithText:@"航向：等待有效数据"];
    self.headingLabel.frame = CGRectMake(left, CGRectGetMaxY(self.stateLabel.frame) + 8.0, width, 44.0);
    [scrollView addSubview:self.headingLabel];

    self.progressLabel = [self labelWithText:@"识别进度：等待动作"];
    self.progressLabel.frame = CGRectMake(left, CGRectGetMaxY(self.headingLabel.frame) + 8.0, width, 72.0);
    [scrollView addSubview:self.progressLabel];

    self.resultLabel = [self labelWithText:@"触发结果：等待动作触发"];
    self.resultLabel.frame = CGRectMake(left, CGRectGetMaxY(self.progressLabel.frame) + 12.0, width, 100.0);
    self.resultLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.resultLabel.layer.borderWidth = 1.0;
    self.resultLabel.layer.cornerRadius = 6.0;
    self.resultLabel.layer.masksToBounds = YES;
    [scrollView addSubview:self.resultLabel];

    UILabel *configLabel = [self labelWithText:[NSString stringWithFormat:@"当前参数\n单段摆动 >= %.1f 度，完成段数 >= %ld\n累计角度 >= %.1f 度，最长时间 %.1fs，空闲超时 %.2fs",
                                                self.config.singleSwingThreshold,
                                                (long)self.config.requiredSwingCount,
                                                self.config.totalAngleThreshold,
                                                self.config.maximumDuration,
                                                self.config.idleTimeout]];
    configLabel.frame = CGRectMake(left, CGRectGetMaxY(self.resultLabel.frame) + 18.0, width, 96.0);
    [scrollView addSubview:configLabel];

    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetMaxY(configLabel.frame) + 28.0);
}

#pragma mark - Authorization And Lifecycle

- (void)startHeadingDetection {
    if (![CLLocationManager headingAvailable]) {
        self.stateLabel.text = @"状态：当前设备不支持电子罗盘";
        return;
    }

    CLAuthorizationStatus status = [self currentAuthorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        self.pendingStartAfterAuthorization = YES;
        self.stateLabel.text = @"状态：等待定位权限";
        [self.locationManager requestWhenInUseAuthorization];
        return;
    }

    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        self.stateLabel.text = @"状态：定位权限不可用，请在系统设置中允许";
        return;
    }

    [self beginHeadingUpdates];
}

- (void)beginHeadingUpdates {
    [self.locationManager stopUpdatingHeading];
    [self resetGestureState];

    self.isDetecting = YES;
    self.pendingStartAfterAuthorization = NO;
    self.stateLabel.text = @"状态：正在检测方向往复变化";
    self.headingLabel.text = @"航向：等待有效数据";
    self.progressLabel.text = @"识别进度：等待动作";
    self.resultLabel.text = @"触发结果：检测中...";

    [self.locationManager startUpdatingHeading];
}

- (void)stopHeadingDetection {
    [self.locationManager stopUpdatingHeading];
    self.isDetecting = NO;
    self.pendingStartAfterAuthorization = NO;
    [self resetGestureState];

    if (self.isViewLoaded) {
        self.stateLabel.text = @"状态：已停止";
    }
}

- (CLAuthorizationStatus)currentAuthorizationStatus {
    if (@available(iOS 14.0, *)) {
        return self.locationManager.authorizationStatus;
    }
    return [CLLocationManager authorizationStatus];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager API_AVAILABLE(ios(14.0)) {
    [self handleAuthorizationChange:[self currentAuthorizationStatus]];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self handleAuthorizationChange:status];
}

- (void)handleAuthorizationChange:(CLAuthorizationStatus)status {
    if ((status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) &&
        self.pendingStartAfterAuthorization) {
        [self beginHeadingUpdates];
    } else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        self.pendingStartAfterAuthorization = NO;
        self.stateLabel.text = @"状态：定位权限不可用，请在系统设置中允许";
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    // headingAccuracy < 0 表示航向无效；精度过差的数据也容易制造误触。
    if (newHeading.headingAccuracy < 0 || newHeading.headingAccuracy > self.config.maximumHeadingAccuracy) {
        self.headingLabel.text = [NSString stringWithFormat:@"航向：精度不足（%.1f 度）", newHeading.headingAccuracy];
        return;
    }

    // magneticHeading 只依赖磁北方向，适合比较短时间内的相对变化。
    // trueHeading 依赖地理位置换算真北，本示例不需要，也避免两种 heading 切换造成跳变。
    CLLocationDirection heading = newHeading.magneticHeading;
    self.headingLabel.text = [NSString stringWithFormat:@"航向：%.1f 度，精度：%.1f 度", heading, newHeading.headingAccuracy];

    if (self.isDetecting) {
        [self processHeading:heading atTime:CACurrentMediaTime()];
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    // 系统认为罗盘需要校准时显示校准界面。生产环境也可以根据产品体验决定是否返回 NO。
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    self.stateLabel.text = [NSString stringWithFormat:@"状态：方向服务错误（%@）", error.localizedDescription];
}

#pragma mark - Heading Detection

- (void)processHeading:(CLLocationDirection)heading atTime:(NSTimeInterval)now {
    if (isnan(self.lastHeading)) {
        self.lastHeading = heading;
        return;
    }

    // 航向角范围是 0~360。若直接用 current-last，359 -> 1 会误算为 -358 度。
    // normalizedDeltaFrom:to: 会把差值归一化到 -180~180。
    CLLocationDirection delta = [self normalizedDeltaFrom:self.lastHeading to:heading];
    self.lastHeading = heading;

    if (fabs(delta) < self.config.noiseThreshold) {
        return;
    }

    if (self.gestureStartTime <= 0 ||
        now - self.lastActiveTime > self.config.idleTimeout ||
        now - self.gestureStartTime > self.config.maximumDuration) {
        [self beginNewGestureWithDelta:delta atTime:now];
        [self updateProgressTextAtTime:now];
        return;
    }

    self.lastActiveTime = now;
    self.totalAngle += fabs(delta);

    PBHeadingSwingDirection direction = [self directionForDelta:delta];
    if (direction == self.currentDirection) {
        self.currentSegmentAngle += delta;
    } else {
        // 只有上一段累计超过阈值，方向反转时才把它记为一段有效摆动。
        // 这种“达到幅度 + 发生反向”的判断，是过滤罗盘小抖动的关键。
        if (fabs(self.currentSegmentAngle) >= self.config.singleSwingThreshold) {
            self.completedSwingCount += 1;
        }

        self.currentDirection = direction;
        self.currentSegmentAngle = delta;
    }

    [self updateProgressTextAtTime:now];

    BOOL swingCountMet = self.completedSwingCount >= self.config.requiredSwingCount;
    BOOL totalAngleMet = self.totalAngle >= self.config.totalAngleThreshold;
    if (swingCountMet && totalAngleMet) {
        [self triggerHeadingShakeAtTime:now];
    }
}

- (void)beginNewGestureWithDelta:(CLLocationDirection)delta atTime:(NSTimeInterval)now {
    self.currentDirection = [self directionForDelta:delta];
    self.currentSegmentAngle = delta;
    self.completedSwingCount = 0;
    self.totalAngle = fabs(delta);
    self.gestureStartTime = now;
    self.lastActiveTime = now;
}

- (PBHeadingSwingDirection)directionForDelta:(CLLocationDirection)delta {
    return delta >= 0 ? PBHeadingSwingDirectionClockwise : PBHeadingSwingDirectionCounterclockwise;
}

- (CLLocationDirection)normalizedDeltaFrom:(CLLocationDirection)previous to:(CLLocationDirection)current {
    CLLocationDirection delta = current - previous;
    if (delta > 180.0) {
        delta -= 360.0;
    } else if (delta < -180.0) {
        delta += 360.0;
    }
    return delta;
}

- (void)triggerHeadingShakeAtTime:(NSTimeInterval)now {
    NSTimeInterval duration = now - self.gestureStartTime;
    NSString *result = [NSString stringWithFormat:@"方向摇一摇已触发\n完成摆动：%ld 段，累计角度：%.1f 度\n耗时：%.2fs\n%@",
                        (long)self.completedSwingCount,
                        self.totalAngle,
                        duration,
                        [NSDate date]];

    // 生产环境常在一次成功回调后停止采集，防止同一动作连续触发并减少耗电。
    [self.locationManager stopUpdatingHeading];
    self.isDetecting = NO;
    self.stateLabel.text = @"状态：已触发并停止";
    self.resultLabel.text = result;
    [self resetGestureState];
}

- (void)updateProgressTextAtTime:(NSTimeInterval)now {
    NSTimeInterval duration = self.gestureStartTime > 0 ? now - self.gestureStartTime : 0;
    NSString *direction = self.currentDirection == PBHeadingSwingDirectionClockwise ? @"顺时针" : @"逆时针";
    self.progressLabel.text = [NSString stringWithFormat:@"识别进度：%@，当前段 %.1f 度\n有效摆动 %ld/%ld，累计 %.1f 度，耗时 %.2fs",
                               direction,
                               fabs(self.currentSegmentAngle),
                               (long)self.completedSwingCount,
                               (long)self.config.requiredSwingCount,
                               self.totalAngle,
                               duration];
}

- (void)resetGestureState {
    self.lastHeading = NAN;
    self.currentDirection = PBHeadingSwingDirectionUnknown;
    self.currentSegmentAngle = 0;
    self.completedSwingCount = 0;
    self.totalAngle = 0;
    self.gestureStartTime = 0;
    self.lastActiveTime = 0;
}

#pragma mark - UI Helpers

- (UILabel *)labelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor darkTextColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.numberOfLines = 0;
    return label;
}

- (UIButton *)buttonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15.0];
    button.backgroundColor = [UIColor colorWithRed:0.12 green:0.48 blue:0.38 alpha:1.0];
    button.layer.cornerRadius = 6.0;
    button.layer.masksToBounds = YES;
    return button;
}

@end
