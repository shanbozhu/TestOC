//
//  GHConsole.m
//  GHConsole
//
//  Created by liaoWorking on 22/11/2017.
//  Copyright © 2017 廖光辉. All rights reserved.
//  https://github.com/Liaoworking/GHConsole for lastest version
//

#import "GHConsole.h"
#import <unistd.h>
#import <sys/uio.h>
#import <pthread/pthread.h>

#define KIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size)||CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size)||CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size)) : NO)



@interface GHConsoleRootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
@public
    UITableView *_tableView;
    UIButton *_minimize;
    UIImageView *_imgV;
}
@property (nonatomic) BOOL scrollEnable;
@property (nonatomic, strong) void(^minimizeActionBlock)(void);
@property (nonatomic, copy) NSArray *dataSource;

@end

@implementation GHConsoleRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self configTextField];
    [self configMinimizeBtn];
    [self createImgV];
}

- (void)configTextField {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.frame = CGRectMake(0, 88, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44);
    _tableView.tableFooterView = [UIView new];
    _tableView.separatorColor = [UIColor whiteColor];
    _tableView.estimatedRowHeight = 44;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor blackColor];
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)configMinimizeBtn {
    _minimize = [[UIButton alloc] initWithFrame:CGRectMake(20, 44, 80, 44)];
    [self.view addSubview:_minimize];
    [_minimize addTarget:self action:@selector(minimizeAction:) forControlEvents:UIControlEventTouchUpInside];
    [_minimize setTitle:@"最小化" forState:UIControlStateNormal];
    [_minimize setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    _minimize.layer.borderWidth = 1;
    _minimize.layer.borderColor = [[UIColor cyanColor] CGColor];
}

- (void)createImgV {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GHConsole.bundle" ofType:nil];
    path = [path stringByAppendingPathComponent:@"icon.png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    _imgV = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:_imgV];
    _imgV.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    _imgV.userInteractionEnabled = YES;
    _imgV.layer.shadowOpacity = 0.5;
    _imgV.layer.shadowOffset = CGSizeZero;
}

- (void)minimizeAction:(UIButton *)sender {
    if(_minimizeActionBlock){
        _minimizeActionBlock();
    }
}

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = [dataSource copy];
    [_tableView reloadData];
}

- (void)setScrollEnable:(BOOL)scrollEnable {
    _tableView.scrollEnabled = scrollEnable;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Cell = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Cell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsZero;
        
        UITextView *textView = [[UITextView alloc] init];
        [cell.contentView addSubview:textView];
        textView.scrollEnabled = NO;
        textView.textContainer.lineFragmentPadding = 0;
        textView.textContainerInset = UIEdgeInsetsZero;
        textView.backgroundColor = [UIColor blackColor];
        textView.textColor = [UIColor whiteColor];
        textView.font = [UIFont systemFontOfSize:13];
        textView.tag = 100;
        textView.userInteractionEnabled = NO;
    }
    NSString *str = self.dataSource[indexPath.row];
    UITextView *textView = [cell.contentView viewWithTag:100];
    textView.frame = CGRectMake(0, 0, tableView.frame.size.width, [self heigthForContent:str]);
    textView.text = str;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str = self.dataSource[indexPath.row];
    return [self heigthForContent:str];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"复制选中的log" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *str = self.dataSource[indexPath.row];
        [UIPasteboard generalPasteboard].string = str;
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:action1];
    [alertVC addAction:action3];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (CGFloat)heigthForContent:(NSString *)content {
    CGRect rect = [content boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
    return ceil(rect.size.height);
}

@end


#pragma mark- GHConsoleWindow
@interface GHConsoleWindow : UIWindow

+ (instancetype)consoleWindow;

- (void)maxmize;

- (void)minimize;

@property (nonatomic, assign) CGPoint axisXY;

@property (nonatomic, strong) GHConsoleRootViewController *consoleRootViewController;

@end

@implementation GHConsoleWindow

+ (instancetype)consoleWindow {
    GHConsoleWindow *window = [[self alloc] init];
    window.windowLevel = UIWindowLevelStatusBar + 100;
    window.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 50, 120, 50, 50);
    window.clipsToBounds = YES;
    return window;
}

- (GHConsoleRootViewController *)consoleRootViewController {
    return (GHConsoleRootViewController *)self.rootViewController;
}

- (void)maxmize {
    self.consoleRootViewController.view.backgroundColor = [UIColor blackColor];
    self.frame = [UIScreen mainScreen].bounds;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    self.consoleRootViewController.scrollEnable = YES;
    self.backgroundColor = [UIColor blackColor];
    self.consoleRootViewController->_imgV.alpha = 0;
    self.consoleRootViewController->_minimize.alpha = 1.0;
    self.consoleRootViewController->_tableView.alpha = 1.0;
}

- (void)minimize {
    self.consoleRootViewController.view.backgroundColor = [UIColor clearColor];
    self.frame = CGRectMake(_axisXY.x, _axisXY.y, 50, 50);
    [self setNeedsLayout];
    [self layoutIfNeeded];
    self.consoleRootViewController.scrollEnable = NO;
    self.consoleRootViewController->_imgV.alpha = 1.0;
    self.consoleRootViewController->_minimize.alpha = 0;
    self.consoleRootViewController->_tableView.alpha = 0;
    self.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].delegate.window.rootViewController setNeedsStatusBarAppearanceUpdate];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.rootViewController.view.frame = self.bounds;
}

@end


#pragma mark- GHConsole
@interface GHConsole () {
    NSDate *_timestamp;
    NSString *_timeString;
}

@property (nonatomic, strong) NSString *string;
@property (nonatomic, assign) BOOL isShowConsole;
@property (nonatomic, strong) NSMutableArray *logStingArray;
@property (nonatomic, copy) NSString *funcString;

@property (nonatomic, assign) NSInteger currentLogCount;
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, strong) UIPanGestureRecognizer *panOutGesture;
@property (nonatomic, strong) GHConsoleWindow *consoleWindow;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, copy) NSString *msgString;
@property (nonatomic, strong) NSDate *now;
@property (nonatomic, strong) NSLock *lock;
@end

@implementation GHConsole

+ (instancetype)sharedConsole {
    static GHConsole *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [GHConsole new];
        _instance.isShowConsole = NO;
    });
    return _instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (GHConsoleWindow *)consoleWindow {
    if (!_consoleWindow) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReceiveMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        _consoleWindow = [GHConsoleWindow consoleWindow];
        _consoleWindow.rootViewController = [GHConsoleRootViewController new];
        _consoleWindow.rootViewController.view.backgroundColor = [UIColor clearColor];
        _consoleWindow.axisXY = _consoleWindow.frame.origin;
        __weak __typeof__(self) weakSelf = self;
        
        
        UITapGestureRecognizer *tappGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageView:)];
        
        [_consoleWindow.rootViewController.view addGestureRecognizer:self.panOutGesture];
        [_consoleWindow.consoleRootViewController->_imgV addGestureRecognizer:tappGest];
        _consoleWindow.consoleRootViewController.minimizeActionBlock = ^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf minimizeAnimation];
        };
        _consoleWindow.backgroundColor = [UIColor clearColor];
        self.consoleWindow.consoleRootViewController->_imgV.alpha = 1.0;
        self.consoleWindow.consoleRootViewController->_minimize.alpha = 0;
        self.consoleWindow.consoleRootViewController->_tableView.alpha = 0;
    }
    return _consoleWindow;
}

- (void)startPrintLog {
    _isFullScreen = NO;
    _isShowConsole = YES;
    self.consoleWindow.hidden = NO;
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    _lock = [NSLock new];
    GGLog(@"GHConsole start working!");
    
#ifndef DEBUG
    [self stopPrinting];
#endif
}

- (void)stopPrinting {
    self.consoleWindow.hidden = YES;
    _isShowConsole = NO;
}

- (void)function:(const char *)function
            line:(NSUInteger)line
          format:(NSString *)format, ... NS_FORMAT_FUNCTION(3,4) {
    va_list args;
    
    if (format) {
        va_start(args, format);
        
        _msgString = [[NSString alloc] initWithFormat:format arguments:args];
        // showing log in UI
        [_lock lock];
        [self printMSG:_msgString andFunc:function andLine:line];
        [_lock unlock];
    }
}

- (void)printMSG:(NSString *)msg andFunc:(const char *)function andLine:(NSInteger )Line {
    // convert C function name to OC
    _funcString = [NSString stringWithUTF8String:function];
    
    _now = [NSDate new];
    msg = [NSString stringWithFormat:@"%@ %@ line-%ld\n%@\n",[_formatter stringFromDate:_now],_funcString,(long)Line,msg];
    
    const char *resultCString = NULL;
    if ([msg canBeConvertedToEncoding:NSUTF8StringEncoding]) {
        resultCString = [msg cStringUsingEncoding:NSUTF8StringEncoding];
    }
    // printing at system concole
    printf("%s", resultCString);
    if(msg.length > 0 && [msg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0){
        [self.logStingArray addObject:msg];
    }
    if (_isShowConsole && _isFullScreen) {
        // 如果显示的话手机上的控制台开始显示。
        dispatch_async(dispatch_get_main_queue(), ^{
            self.consoleWindow.consoleRootViewController.dataSource = self.logStingArray;
            [self scrollToBottom];
        });
    }
}





- (NSMutableArray *)logStingArray {
    if (!_logStingArray) {
        _logStingArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _logStingArray;
}

//- (void)handleReceiveMemoryWarningNotification {
//    [self.logStingArray removeAllObjects];
//    [self.logStingArray addObject:@"收到了系统内存警告!所有日志被清空!"];
//    self.consoleWindow.consoleRootViewController.dataSource = self.logStingArray;
//}

#pragma mark- gesture function
- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    if (_isFullScreen == YES) { // do nothing when it fullScreen.
        return;
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:gesture.view];
        CGRect rect = CGRectOffset(self.consoleWindow.frame, translation.x, translation.y);
        self.consoleWindow.frame = rect;
        [gesture setTranslation:CGPointZero inView:gesture.view];
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        CGRect rect = self.consoleWindow.frame;
        if (self.consoleWindow.center.y < rect.size.height/2.0f) {
            rect.origin.y = KIsiPhoneX?44:20;
        } else if (self.consoleWindow.center.y > [UIScreen mainScreen].bounds.size.height-rect.size.height / 2.0f) {
            rect.origin.y = [UIScreen mainScreen].bounds.size.height-rect.size.height;
        } else {
            if (self.consoleWindow.center.x < [UIScreen mainScreen].bounds.size.width/2.0f) {
                rect.origin.x = 0;
            } else {
                rect.origin.x = [UIScreen mainScreen].bounds.size.width - rect.size.width;
            }
        }
        self.consoleWindow.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.consoleWindow.frame = rect;
        } completion:^(BOOL finished) {
            self.consoleWindow.userInteractionEnabled = YES;
        }];
    }
}

// tap
- (void)tapImageView:(UITapGestureRecognizer *)tapGesture {
    [self maximumAnimation];
}

// 全屏
- (void)maximumAnimation {
    if (!_isFullScreen) {
        // becoma full screen
        self.consoleWindow.consoleRootViewController.dataSource = self.logStingArray;
        [UIView animateWithDuration:0.25 animations:^{
            [self.consoleWindow maxmize];
        } completion:^(BOOL finished) {
            self->_isFullScreen = YES;
            if(!finished){
                [self.consoleWindow maxmize];
            }
            [self scrollToBottom];
        }];
    }
}

- (void)minimizeAnimation {
    // 退出全屏
    [UIView animateWithDuration:0.25 animations:^{
        [self.consoleWindow minimize];
    } completion:^(BOOL finished) {
        self->_isFullScreen = NO;
        if(!finished){
            [self.consoleWindow minimize];
        }
    }];
}

- (void)scrollToBottom {
    if(self.logStingArray.count > 0){
        [self.consoleWindow.consoleRootViewController->_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.logStingArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (UIPanGestureRecognizer *)panOutGesture {
    if (!_panOutGesture) {
        _panOutGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
    }
    return _panOutGesture;
}

@end
