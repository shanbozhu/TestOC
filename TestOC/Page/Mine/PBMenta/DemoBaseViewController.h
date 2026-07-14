#import <UIKit/UIKit.h>

@interface DemoBaseViewController : UIViewController

@property (nullable, nonatomic, copy) NSString *defaultSlotId;
@property (nullable, nonatomic, copy) NSString *currentSlotId;
@property (nonatomic, assign) CGFloat currentY;
@property (nonatomic, assign, readonly) CGFloat maxY;

- (nonnull UITextField *)addTextFieldWithText:(nullable NSString *)text placeholder:(nullable NSString *)placeholder;
- (nonnull UIButton *)addButtonWithTitle:(nullable NSString *)title action:(nonnull SEL)selector;
- (void)addSubview:(nullable UIView *)view;

- (void)appendLog:(nullable NSString *)log;

- (void)showAdInvalidAlertWithContinue:(void (^ __nullable)(void))continueBlock cancel:(void (^ __nullable)(void))cancelBlock;

@end 
