//
//  PBPAGController.m
//  TestOC
//
//  Created by zhushanbo on 2026/6/29.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBPAGController.h"
#import <Lottie/LOTAnimationView.h>
#import <objc/message.h>

static NSString * const kPBGalaceanLocalSceneName = @"pb_galacean_scene";
static NSString * const kPBGalaceanRemoteSceneURL = @"";
static NSString * const kPBPAGLocalFileName = @"pb_pag_demo";
static NSString * const kPBLottieLocalFileName = @"bubble_voicesearch_lottie";

@interface NSObject (PBPAGDemoPerform)

- (void)pb_performSelectorIfExists:(SEL)selector withObject:(id)object;

@end

@interface PBPAGController ()

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *galaceanPlayer;
@property (nonatomic, strong) UIView *pagAnimationView;
@property (nonatomic, strong) LOTAnimationView *lottieAnimationView;

@end

@implementation PBPAGController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PAG";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupScrollView];
    [self addGalaceanEffectsDemo];
    [self addPAGDemo];
    [self addLottieDemo];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.galaceanPlayer pb_performSelectorIfExists:NSSelectorFromString(@"stop") withObject:nil];
    [self.galaceanPlayer pb_performSelectorIfExists:NSSelectorFromString(@"destroy") withObject:nil];
    self.galaceanPlayer = nil;
    
    [self.pagAnimationView pb_performSelectorIfExists:NSSelectorFromString(@"stop") withObject:nil];
    [self.lottieAnimationView stop];
}

#pragma mark - Layout

- (void)setupScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, APPLICATION_NAVIGATIONBAR_HEIGHT, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT - APPLICATION_NAVIGATIONBAR_HEIGHT)];
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    scrollView.alwaysBounceVertical = YES;
    scrollView.contentSize = CGSizeMake(APPLICATION_FRAME_WIDTH, 720);
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (UIView *)demoContainerWithTitle:(NSString *)title frame:(CGRect)frame {
    UIView *container = [[UIView alloc] initWithFrame:frame];
    [self.scrollView addSubview:container];
    container.backgroundColor = [UIColor bba_RGBColorFromHexString:@"#F6F7F9" alpha:1.0];
    container.layer.cornerRadius = 8;
    container.layer.masksToBounds = YES;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, frame.size.width - 32, 24)];
    [container addSubview:titleLabel];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textColor = [UIColor bba_RGBColorFromHexString:@"#1F2329" alpha:1.0];
    titleLabel.text = title;
    
    return container;
}

- (UILabel *)tipLabelWithText:(NSString *)text frame:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor bba_RGBColorFromHexString:@"#646A73" alpha:1.0];
    label.numberOfLines = 0;
    label.text = text;
    return label;
}

#pragma mark - Galacean Effects

- (void)addGalaceanEffectsDemo {
    UIView *container = [self demoContainerWithTitle:@"Galacean Effects" frame:CGRectMake(16, 16, APPLICATION_FRAME_WIDTH - 32, 190)];
    CGRect playerFrame = CGRectMake(16, 48, 128, 128);
    
    NSString *sceneURLString = [self galaceanSceneURLString];
    Class paramsClass = NSClassFromString(@"GEPlayerParams");
    Class playerClass = NSClassFromString(@"GEPlayer");
    UIView *player = nil;
    if (paramsClass && playerClass) {
        id params = [[paramsClass alloc] init];
        [params setValue:sceneURLString forKey:@"url"];
        [params setValue:[self placeholderImageWithText:@"GE"] forKey:@"downgradeImage"];
        [params setValue:@{@"title": @"Galacean Effects Demo"} forKey:@"variables"];
        [params setValue:@{} forKey:@"variablesBitmap"];
        
        id (*initWithParams)(id, SEL, id) = (id (*)(id, SEL, id))objc_msgSend;
        player = initWithParams([playerClass alloc], NSSelectorFromString(@"initWithParams:"), params);
    } else {
        player = [[UIImageView alloc] initWithImage:[self placeholderImageWithText:@"GE"]];
    }
    
    self.galaceanPlayer = player;
    [container addSubview:player];
    player.frame = playerFrame;
    player.backgroundColor = [UIColor blackColor];
    
    UILabel *tipLabel = [self tipLabelWithText:@"API: GEPlayerParams 设置 url / downgradeImage / variables，GEPlayer loadScene 后 playWithRepeatCount。把 pb_galacean_scene.json 或远程 URL 配好即可播放。" frame:CGRectMake(CGRectGetMaxX(playerFrame) + 16, 52, container.frame.size.width - CGRectGetMaxX(playerFrame) - 32, 96)];
    [container addSubview:tipLabel];
    
    if (!paramsClass || !playerClass) {
        tipLabel.text = @"当前运行环境未加载 GalaceanEffects。真机可使用 pod 'GalaceanEffects'；若跑模拟器，请确认 framework 含对应模拟器架构。";
        return;
    }
    
    if (sceneURLString.length == 0) {
        tipLabel.text = @"未找到 Galacean 资源。请把导出的 pb_galacean_scene.json 放入 main bundle，或填写 kPBGalaceanRemoteSceneURL。";
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    void (^loadCallback)(bool, NSString *) = ^(bool success, NSString *errorMsg) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if (!success) {
            tipLabel.text = [NSString stringWithFormat:@"Galacean loadScene 失败: %@", errorMsg ?: @""];
            return;
        }
        void (^playCallback)(bool, NSString *) = ^(bool playSuccess, NSString *playErrorMsg) {
            if (!playSuccess) {
                tipLabel.text = [NSString stringWithFormat:@"Galacean play 失败: %@", playErrorMsg ?: @""];
            }
        };
        void (*play)(id, SEL, int, id) = (void (*)(id, SEL, int, id))objc_msgSend;
        play(strongSelf.galaceanPlayer, NSSelectorFromString(@"playWithRepeatCount:Callback:"), 0, playCallback);
    };
    void (*loadScene)(id, SEL, id) = (void (*)(id, SEL, id))objc_msgSend;
    loadScene(player, NSSelectorFromString(@"loadScene:"), loadCallback);
}

- (NSString *)galaceanSceneURLString {
    if (kPBGalaceanRemoteSceneURL.length > 0) {
        return kPBGalaceanRemoteSceneURL;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:kPBGalaceanLocalSceneName ofType:@"json"];
    if (path.length == 0) {
        return @"";
    }
    return [NSURL fileURLWithPath:path].absoluteString;
}

#pragma mark - PAG

- (void)addPAGDemo {
    UIView *container = [self demoContainerWithTitle:@"PAG" frame:CGRectMake(16, 222, APPLICATION_FRAME_WIDTH - 32, 190)];
    CGRect animationFrame = CGRectMake(16, 48, 128, 128);
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kPBPAGLocalFileName ofType:@"pag"];
    Class pagImageViewClass = NSClassFromString(@"PAGImageView");
    Class pagViewClass = NSClassFromString(@"PAGView");
    
    UIView *pagView = nil;
    if (pagImageViewClass) {
        pagView = [[pagImageViewClass alloc] initWithFrame:animationFrame];
    } else if (pagViewClass) {
        pagView = [[pagViewClass alloc] initWithFrame:animationFrame];
    } else {
        pagView = [[UIImageView alloc] initWithImage:[self placeholderImageWithText:@"PAG"]];
        pagView.frame = animationFrame;
    }
    self.pagAnimationView = pagView;
    [container addSubview:pagView];
    pagView.backgroundColor = [UIColor bba_RGBColorFromHexString:@"#111827" alpha:1.0];
    
    NSString *tipText = @"API: PAGImageView/PAGView 初始化后 setPath: 传入 .pag 文件路径，再 play。Podfile 加入 libpag 后，这段运行时 Demo 会自动走真实 PAG View。";
    if (!pagImageViewClass && !pagViewClass) {
        tipText = @"当前工程未安装 libpag，无法编译期 import PAG 头文件。接入 pod 'libpag' 并放入 pb_pag_demo.pag 后，将使用 setPath/play 播放。";
    } else if (filePath.length == 0) {
        tipText = @"已检测到 PAG View 类，但未找到 pb_pag_demo.pag。请把 .pag 资源加入 main bundle。";
    } else {
        [pagView pb_performSelectorIfExists:NSSelectorFromString(@"setPath:") withObject:filePath];
        [pagView pb_performSelectorIfExists:NSSelectorFromString(@"play") withObject:nil];
    }
    
    UILabel *tipLabel = [self tipLabelWithText:tipText frame:CGRectMake(CGRectGetMaxX(animationFrame) + 16, 52, container.frame.size.width - CGRectGetMaxX(animationFrame) - 32, 104)];
    [container addSubview:tipLabel];
}

#pragma mark - Lottie

- (void)addLottieDemo {
    UIView *container = [self demoContainerWithTitle:@"Lottie" frame:CGRectMake(16, 428, APPLICATION_FRAME_WIDTH - 32, 190)];
    CGRect animationFrame = CGRectMake(16, 48, 128, 128);
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kPBLottieLocalFileName ofType:@"json"];
    if (filePath.length == 0) {
        UIImageView *placeholderView = [[UIImageView alloc] initWithImage:[self placeholderImageWithText:@"LOT"]];
        [container addSubview:placeholderView];
        placeholderView.frame = animationFrame;
        UILabel *tipLabel = [self tipLabelWithText:@"未找到 bubble_voicesearch_lottie.json。" frame:CGRectMake(CGRectGetMaxX(animationFrame) + 16, 52, container.frame.size.width - CGRectGetMaxX(animationFrame) - 32, 80)];
        [container addSubview:tipLabel];
        return;
    }
    
    LOTAnimationView *animationView = [LOTAnimationView animationWithFilePath:filePath];
    self.lottieAnimationView = animationView;
    [container addSubview:animationView];
    animationView.frame = animationFrame;
    animationView.contentMode = UIViewContentModeScaleAspectFit;
    animationView.loopAnimation = YES;
    animationView.backgroundColor = [UIColor bba_RGBColorFromHexString:@"#1F1F1F" alpha:0.95];
    [animationView playWithCompletion:^(BOOL animationFinished) {
        if (animationFinished) {
            NSLog(@"Lottie animation finished");
        }
    }];
    
    UILabel *tipLabel = [self tipLabelWithText:@"API: LOTAnimationView animationWithFilePath 加载 JSON，loopAnimation 控制循环，playWithCompletion/play 开始播放。" frame:CGRectMake(CGRectGetMaxX(animationFrame) + 16, 52, container.frame.size.width - CGRectGetMaxX(animationFrame) - 32, 96)];
    [container addSubview:tipLabel];
}

#pragma mark - Helpers

- (UIImage *)placeholderImageWithText:(NSString *)text {
    CGSize size = CGSizeMake(128, 128);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    [[UIColor bba_RGBColorFromHexString:@"#E5E7EB" alpha:1.0] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    
    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont boldSystemFontOfSize:28],
        NSForegroundColorAttributeName: [UIColor bba_RGBColorFromHexString:@"#374151" alpha:1.0]
    };
    CGSize textSize = [text sizeWithAttributes:attributes];
    [text drawAtPoint:CGPointMake((size.width - textSize.width) / 2.0, (size.height - textSize.height) / 2.0) withAttributes:attributes];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@implementation NSObject (PBPAGDemoPerform)

- (void)pb_performSelectorIfExists:(SEL)selector withObject:(id)object {
    if (![self respondsToSelector:selector]) {
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:selector withObject:object];
#pragma clang diagnostic pop
}

@end
