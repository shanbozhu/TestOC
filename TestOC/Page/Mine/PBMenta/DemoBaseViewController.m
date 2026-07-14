#import "DemoBaseViewController.h"

@interface DemoBaseViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *slotIdTextField;
@property (nonatomic, strong) UITextView *logTextView;

@end


@implementation DemoBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.currentY = 100;
    self.slotIdTextField = [self addTextFieldWithText:self.defaultSlotId placeholder:@"请输入广告位Id"];
    [self setupLogTextView];
}

- (NSString *)defaultSlotId {
    return nil;
}

- (nullable NSString *)currentSlotId {
    return self.slotIdTextField.text ?: self.defaultSlotId;
}

- (CGFloat)maxY {
    return self.view.bounds.size.height - CGRectGetHeight(self.logTextView.frame);
}

- (void)addSubview:(UIView *)view {
    if (!view) {
        return;
    }
    
    CGRect frame = view.frame;
    frame.origin.x = (CGRectGetWidth(self.view.frame) - CGRectGetWidth(view.frame)) * 0.5;
    frame.origin.y = self.currentY;
    view.frame = frame;
    [self.view addSubview:view];
    
    self.currentY += CGRectGetHeight(view.frame);
    self.currentY += 10;
}

- (UITextField *)addTextFieldWithText:(NSString *)text placeholder:(NSString *)placeholder {
    UITextField *textField = [[UITextField alloc] initWithFrame:self.defaultFrame];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = placeholder;
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    textField.text = text;
    textField.font = [UIFont systemFontOfSize:16];
    [self addSubview:textField];
    return textField;
}

- (UIButton *)addButtonWithTitle:(NSString *)title action:(SEL)selector {
    UIButton *button = [[UIButton alloc] initWithFrame:self.defaultFrame];
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blackColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (CGRect)defaultFrame {
    return CGRectMake(0, 0, 200, 40);
}

- (void)setupLogTextView {
    UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat logViewHeight = 200;
    
    self.logTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 
                                                                    self.view.bounds.size.height - safeAreaInsets.bottom - logViewHeight - 10,
                                                                    screenWidth - 20, 
                                                                    logViewHeight)];
    self.logTextView.editable = NO;
    self.logTextView.font = [UIFont systemFontOfSize:14];
    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.logTextView.layer.cornerRadius = 5;
    self.logTextView.layer.borderWidth = 0.5;
    self.logTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:self.logTextView];
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    clearButton.frame = CGRectMake(CGRectGetMaxX(self.logTextView.frame) - 60,
                                  CGRectGetMinY(self.logTextView.frame) - 30,
                                  50,
                                  25);
    [clearButton setTitle:@"清除" forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearLog) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearButton];
}

- (void)appendLog:(NSString *)log {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *timeStamp = [self currentTimeString];
        NSString *logWithTime = [NSString stringWithFormat:@"[%@] %@\n", timeStamp, log];
        self.logTextView.text = [self.logTextView.text stringByAppendingString:logWithTime];
        [self.logTextView scrollRangeToVisible:NSMakeRange(self.logTextView.text.length, 0)];
    });
}

- (void)clearLog {
    self.logTextView.text = @"";
}

- (NSString *)currentTimeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    return [formatter stringFromDate:[NSDate date]];
}

- (void)showAdInvalidAlertWithContinue:(void (^ __nullable)(void))continueBlock cancel:(void (^ __nullable)(void))cancelBlock {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:@"广告无效，无法正常展示"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"继续展示" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (continueBlock) {
            continueBlock();
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (cancelBlock) {
            cancelBlock();
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.slotIdTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

@end 
