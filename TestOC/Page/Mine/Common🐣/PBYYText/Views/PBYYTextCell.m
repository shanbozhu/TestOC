//
//  PBYYTextCell.m
//  TestOC
//
//  Created by DaMaiIOS on 17/9/28.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBYYTextCell.h"
#import <YYText/YYText.h>
#import <YYImage/YYImage.h>
#import "PBRegex.h"

@interface PBYYTextCell ()

@property (nonatomic, weak) YYLabel *twoLab;
@property (nonatomic, weak) YYTextView *textView;
@property (nonatomic, weak) UITableView *tableView;

@end

@implementation PBYYTextCell

- (CGSize)sizeThatFits:(CGSize)size {
    if ([self.contentView.subviews containsObject:self.textView]) {
        return CGSizeMake(size.width, CGRectGetMaxY(self.textView.frame)+20);
    }
    return CGSizeMake(size.width, CGRectGetMaxY(self.twoLab.frame)+20);
}

+ (instancetype)testListCellWithTableView:(UITableView *)tableView {
    [tableView registerClass:[self class] forCellReuseIdentifier:@"PBYYTextCell"];
    PBYYTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PBYYTextCell"];
    cell.tableView = tableView;
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

- (void)setTestList:(PBYYText *)testList {
    _testList = testList;
    
    [self fillTestListCell];
}

+ (NSString *)originStr {
    NSString *str = @"我爱北京天安门我爱北京天安门我爱北京高京天｜安｜门我高亮爱北京天天安门（emoji😀）我爱北京天安门高亮点击京天安门我爱北京北京天高亮点击自定义京天安门我爱北京（链接https://www.baidu.com/）我爱北京天安门（话题#爱北京天安#）安门我爱北京天（邮箱shanbo.zsb@alibaba-inc.com）安门我爱北京天安门我爱北京天（手机号0176001087860）安门我爱北京天安（用户名@门我爱北京天安:）爱北京天安门我爱我爱我爱北（emoticon[调皮][大调皮]）京天安门天安门我爱北";
    return str;
}

- (void)fillTestListCell {
    // 移除自定义视图上的所有子视图
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSString *str = [self.class originStr];
    
    /// oneLab
    YYLabel *oneLab = [[YYLabel alloc]init];
    [self.contentView addSubview:oneLab];
    oneLab.layer.borderColor = [UIColor redColor].CGColor;
    oneLab.layer.borderWidth = 1.1;
    
    // 富文本(属性字符串)
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:str];
    [attStr yy_setFont:[UIFont systemFontOfSize:17] range:NSMakeRange(0, attStr.length)];
    [attStr yy_setLineSpacing:18 range:NSMakeRange(0, attStr.length)];
    [attStr yy_setColor:[UIColor darkGrayColor] range:NSMakeRange(0, attStr.length)];
    
    oneLab.textTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
        self.testList.fold = YES;
        [self.delegate testListCell:self];
    };
    
    // ... 全文
    NSMutableAttributedString *moreStr = [[NSMutableAttributedString alloc]initWithString:@"... 全文"];
    [moreStr yy_setFont:attStr.yy_font range:[moreStr.string rangeOfString:@"..."]];
    [moreStr yy_setColor:attStr.yy_color range:[moreStr.string rangeOfString:@"..."]];
    [moreStr yy_setFont:attStr.yy_font range:[moreStr.string rangeOfString:@"全文"]];
    [moreStr yy_setTextHighlightRange:[moreStr.string rangeOfString:@"全文"] color:[UIColor blueColor] backgroundColor:[UIColor redColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        self.testList.fold = NO;
        [self.delegate testListCell:self];
    }];
    
    YYLabel *moreLab = [[YYLabel alloc]init];
    moreLab.textAlignment = NSTextAlignmentCenter;
    moreLab.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    YYTextLayout *moreTextLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake(200, 200) text:moreStr];
    moreLab.frame = CGRectMake(0, 0, moreTextLayout.textBoundingSize.width, moreTextLayout.textBoundingSize.height);
    moreLab.textLayout = moreTextLayout;
    
    NSMutableAttributedString *moreTruncationTokenStr = [NSMutableAttributedString yy_attachmentStringWithContent:moreLab contentMode:UIViewContentModeCenter attachmentSize:moreLab.frame.size alignToFont:attStr.yy_font alignment:YYTextVerticalAlignmentTop];
    
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-40, 100000)];
    container.truncationToken = moreTruncationTokenStr;
    container.truncationType = YYTextTruncationTypeEnd;
    if (self.testList.fold == YES) {
        container.maximumNumberOfRows = 3;
    } else {
        container.maximumNumberOfRows = 0;
    }
    
    YYTextLayout *threeTextLayout = [YYTextLayout layoutWithContainer:container text:attStr];
    oneLab.frame = CGRectMake(20, 20, threeTextLayout.textBoundingSize.width, threeTextLayout.textBoundingSize.height);
    oneLab.textLayout = threeTextLayout;
    
    
    /// twoLab
    YYLabel *twoLab = [[YYLabel alloc]init];
    self.twoLab = twoLab;
    [self.contentView addSubview:twoLab];
    twoLab.frame = CGRectMake(CGRectGetMinX(oneLab.frame), CGRectGetMaxY(oneLab.frame)+50, [UIScreen mainScreen].bounds.size.width-40, 100000);
    twoLab.numberOfLines = 0;
    twoLab.textAlignment = NSTextAlignmentCenter;
    twoLab.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    //twoLab.displaysAsynchronously = YES;
    twoLab.layer.borderColor = [UIColor redColor].CGColor;
    twoLab.layer.borderWidth = 1.1;
    
    attStr = [[NSMutableAttributedString alloc]initWithString:str];
    [attStr yy_setFont:[UIFont systemFontOfSize:17] range:NSMakeRange(0, attStr.length)];
    [attStr yy_setLineSpacing:18 range:NSMakeRange(0, attStr.length)];
    [attStr yy_setColor:[UIColor darkGrayColor] range:NSMakeRange(0, attStr.length)];
    
    // 给视图添加渐变色层
    UIView *iconView = [[UIView alloc] init];
    iconView.frame = CGRectMake(0, 0, 40, attStr.yy_font.lineHeight);
    UITapGestureRecognizer *zeroTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [iconView addGestureRecognizer:zeroTap];
    zeroTap.view.tag = 0;
    
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = iconView.bounds;
    layer.startPoint = CGPointMake(0, 0.5);
    layer.endPoint = CGPointMake(1, 0.5); // 从左往右
    for (CALayer *sublayer in iconView.layer.sublayers) {
        [sublayer removeFromSuperlayer];
    }
    layer.colors = [NSArray arrayWithObjects:(id)[UIColor redColor].CGColor, (id)[UIColor blueColor].CGColor, nil];
    [iconView.layer insertSublayer:layer atIndex:0];
    
    // 给视图添加部分圆角
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:iconView.bounds
                                                     byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight
                                                           cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = bezierPath.CGPath;
    iconView.layer.mask = maskLayer;
    
    NSMutableAttributedString *attachStrZero = [NSMutableAttributedString yy_attachmentStringWithContent:iconView contentMode:UIViewContentModeCenter attachmentSize:iconView.frame.size alignToFont:attStr.yy_font alignment:YYTextVerticalAlignmentCenter];
    [attachStrZero yy_setLineSpacing:attStr.yy_lineSpacing range:attachStrZero.yy_rangeOfAll];
    [attStr insertAttributedString:attachStrZero atIndex:1];
    
    // 高亮
    NSRegularExpression *regularExpression = [PBRegex regexString:@"高亮"];
    NSArray *result = [regularExpression matchesInString:attStr.string options:kNilOptions range:attStr.yy_rangeOfAll];
    for (NSTextCheckingResult *at in result) {
        if (at.range.location == NSNotFound && at.range.length <= 1) {
            continue;
        }
        [attStr yy_setColor:[UIColor orangeColor] range:at.range];
    }
    
    // 高亮点击
    [attStr yy_setTextHighlightRange:[attStr.string rangeOfString:@"高亮点击"] color:[UIColor blueColor] backgroundColor:[UIColor lightGrayColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        NSLog(@"%@", [attStr.string substringWithRange:range]);
    }];
    
    // 高亮点击_自定义
    NSRange range = [attStr.string rangeOfString:@"高亮点击自定义"];
    UIColor *normalColor = [UIColor blueColor];
    [attStr yy_setColor:normalColor range:range];
    YYTextDecoration *normalDecoration = [YYTextDecoration decorationWithStyle:YYTextLineStyleSingle width:@(1) color:normalColor];
    [attStr yy_setTextUnderline:normalDecoration range:range];
    
    UIColor *highlightColor = [UIColor redColor];
    YYTextDecoration *highlightDecoration = [YYTextDecoration decorationWithStyle:YYTextLineStyleSingle width:@(1) color:highlightColor];
    YYTextHighlight *highlight = [[YYTextHighlight alloc]init];
    [highlight setColor:highlightColor];
    [highlight setUnderline:highlightDecoration];
    
    YYTextBorder *highlightBorder = [[YYTextBorder alloc]init];
    highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
    highlightBorder.cornerRadius = 3;
    highlightBorder.fillColor = [UIColor greenColor];
    [highlight setBackgroundBorder:highlightBorder];
    
    highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
        NSLog(@"%@", [attStr.string substringWithRange:range]);
    };
    [attStr yy_setTextHighlight:highlight range:range];
    
    // 图片表情(png图、gif图)
    [self emoticonWithAttributedString:attStr regularExpression:[PBRegex regexEmoticon]];
    
    // 图片
    UIImageView *twoImageView = [[UIImageView alloc]init];
    twoImageView.frame = CGRectMake(0, 0, CGRectGetWidth(twoLab.frame), 150);
    twoImageView.image = [UIImage imageNamed:@"pbyytext_pic"];
    twoImageView.userInteractionEnabled = YES;
    twoImageView.layer.cornerRadius = 10;
    twoImageView.layer.masksToBounds = YES;
    // 图片点击
    UITapGestureRecognizer *twoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [twoImageView addGestureRecognizer:twoTap];
    twoTap.view.tag = 2;
    // 图片生成富文本
    NSMutableAttributedString *attachStrTwo = [NSMutableAttributedString yy_attachmentStringWithContent:twoImageView contentMode:UIViewContentModeCenter attachmentSize:twoImageView.frame.size alignToFont:attStr.yy_font alignment:YYTextVerticalAlignmentCenter];
    [attachStrTwo yy_setLineSpacing:attStr.yy_lineSpacing range:attachStrTwo.yy_rangeOfAll];
    [attStr appendAttributedString:attachStrTwo];
    
    // 追加文字
    NSMutableAttributedString *attStrFour = [[NSMutableAttributedString alloc]initWithString:@"我爱北京天安门京天安\\n\n门我爱北京天北删除线北京天北京天安门我北京天下划线我北京天北京天."];
    [attStrFour yy_setLineSpacing:attStr.yy_lineSpacing range:NSMakeRange(0, attStrFour.length)];
    [attStrFour yy_setColor:attStr.yy_color range:NSMakeRange(0, attStrFour.length)];
    [attStrFour yy_setFont:attStr.yy_font range:NSMakeRange(0, attStrFour.length)];
    
    // 删除线
    YYTextDecoration *decoration = [YYTextDecoration decorationWithStyle:YYTextLineStyleSingle width:@(2) color:[UIColor blueColor]];
    [attStrFour yy_setTextStrikethrough:decoration range:[attStrFour.string rangeOfString:@"删除线"]];
    
    // 下划线
    [attStrFour yy_setTextUnderline:decoration range:[attStrFour.string rangeOfString:@"下划线"]];
    [attStr appendAttributedString:attStrFour];
    
    // 链接_自动匹配
    [self automaticMatchRegularExpressionWithAttStr:attStr];
    
    // 下面方法均可以计算lab高度
    {
        YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(CGRectGetWidth(twoLab.frame), MAXFLOAT) text:attStr];
        twoLab.frame = CGRectMake(CGRectGetMinX(oneLab.frame), CGRectGetMaxY(oneLab.frame)+50, layout.textBoundingSize.width, layout.textBoundingSize.height);
        twoLab.textLayout = layout;
    }
    
    {
        YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(CGRectGetWidth(twoLab.frame), MAXFLOAT) text:attStr];
        twoLab.frame = CGRectMake(CGRectGetMinX(oneLab.frame), CGRectGetMaxY(oneLab.frame)+50, layout.textBoundingSize.width, layout.textBoundingSize.height);
        twoLab.attributedText = attStr;
    }
    
    {
        twoLab.attributedText = attStr;
        [twoLab sizeToFit];
    }
    
    // textView
    YYTextView *textView = [[YYTextView alloc]init];
    self.textView = textView;
    [self.contentView addSubview:textView];
    textView.textContainerInset = UIEdgeInsetsZero; // YYTextView上下左右间距为0
    //textView.editable = NO;
    textView.frame = CGRectMake(CGRectGetMinX(twoLab.frame), CGRectGetMaxY(twoLab.frame)+50, [UIScreen mainScreen].bounds.size.width-40, 100000);
    textView.attributedText = attStr;
    [textView sizeToFit];
    textView.layer.borderColor = [UIColor redColor].CGColor;
    textView.layer.borderWidth = 1.1;
}

#pragma mark - 图片表情(png图、gif图)

- (void)emoticonWithAttributedString:(NSMutableAttributedString *)attStr regularExpression:(NSRegularExpression *)regularExpression {
    CGFloat emoticonWidth = attStr.yy_font.lineHeight;
    NSArray *result = [regularExpression matchesInString:attStr.string options:kNilOptions range:attStr.yy_rangeOfAll];
    for (NSInteger i = result.count - 1; i >= 0; i--) {
        NSTextCheckingResult *at = [result objectAtIndex:i];
        if (at.range.location == NSNotFound && at.range.length <= 1) {
            continue;
        }
        NSString *rangeString = [attStr.string substringWithRange:at.range];
        
        // 将转义字符替换为对应的图片名称
        NSString *imageName = [self imageNameWithRangeString:rangeString];
        if (!imageName) {
            continue;
        }
        
        // 图片
        UIImageView *threeImageView = [[YYAnimatedImageView alloc]init];
        threeImageView.image = [YYImage imageNamed:imageName];
        threeImageView.frame = CGRectMake(0, 0, emoticonWidth, emoticonWidth);
        threeImageView.userInteractionEnabled = YES;
        // 图片点击
        UITapGestureRecognizer *threeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
        [threeImageView addGestureRecognizer:threeTap];
        threeTap.view.tag = 3;
        // 图片生成富文本
        NSMutableAttributedString *attachStrThree = [NSMutableAttributedString yy_attachmentStringWithContent:threeImageView contentMode:UIViewContentModeCenter attachmentSize:threeImageView.frame.size alignToFont:attStr.yy_font alignment:YYTextVerticalAlignmentCenter];
        [attachStrThree yy_setLineSpacing:attStr.yy_lineSpacing range:attachStrThree.yy_rangeOfAll];
        
        // 替换子串后改变了原字符串的长度，会改变其他子串的初始位置，此时替换会越界。从右往左替换则不会出现此问题，因为其他子串的位置不会因为后面子串的改变而改变。
        [attStr replaceCharactersInRange:at.range withAttributedString:attachStrThree];
    }
}

- (NSString *)imageNameWithRangeString:(NSString *)rangeString {
    if ([rangeString isEqualToString:@"[调皮]"]) {
        return @"001";
    } else if ([rangeString isEqualToString:@"[大调皮]"]) {
        return @"0001";
    }
    return nil;
}

- (void)tapClick:(UITapGestureRecognizer *)tap {
    NSLog(@"点击了图片%ld", tap.view.tag);
}

#pragma mark - 链接_自动匹配

- (void)automaticMatchRegularExpressionWithAttStr:(NSMutableAttributedString *)attStr {
    // 链接_自动匹配
    [self highlightWithAttributedString:attStr regularExpression:[PBRegex regexUrl]];
    
    // 话题_自动匹配
    [self highlightWithAttributedString:attStr regularExpression:[PBRegex regexTopic]];
    
    // 邮箱_自动匹配
    [self highlightWithAttributedString:attStr regularExpression:[PBRegex regexEmail]];
    
    // 手机号_自动匹配
    [self highlightWithAttributedString:attStr regularExpression:[PBRegex regexPhone]];
    
    // 用户名_自动匹配
    [self highlightWithAttributedString:attStr regularExpression:[PBRegex regexAt]];
}

- (void)highlightWithAttributedString:(NSMutableAttributedString *)attStr regularExpression:(NSRegularExpression *)regularExpression {
    NSArray *result = [regularExpression matchesInString:attStr.string options:kNilOptions range:attStr.yy_rangeOfAll];
    for (NSTextCheckingResult *at in result) {
        if (at.range.location == NSNotFound && at.range.length <= 1) {
            continue;
        }
        
        if (![attStr yy_attribute:YYTextHighlightAttributeName atIndex:at.range.location]) {
            [attStr yy_setColor:[UIColor blueColor] range:at.range];
            
            YYTextHighlight *highlight = [[YYTextHighlight alloc]init];
            
            YYTextBorder *highlightBorder = [[YYTextBorder alloc]init];
            highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
            highlightBorder.cornerRadius = 3;
            highlightBorder.fillColor = [UIColor greenColor];
            [highlight setBackgroundBorder:highlightBorder];
            
            __weak typeof(highlight) weakHighlight = highlight;
            highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                NSLog(@"%@, highlight = %@, yy_attribute = %@", [attStr.string substringWithRange:at.range], weakHighlight, [attStr yy_attribute:YYTextHighlightAttributeName atIndex:at.range.location]);
            };
            [attStr yy_setTextHighlight:highlight range:at.range];
        }
    }
}

@end
