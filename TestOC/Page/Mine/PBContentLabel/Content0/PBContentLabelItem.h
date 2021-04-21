//
//  PBContentLabelItem.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/14.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBContentLabelItem : NSObject

@property (nonatomic, strong, readonly) NSTextStorage *textStroage;

@property (nonatomic, strong, readonly) NSLayoutManager *layoutManager;

@property (nonatomic, strong, readonly) NSTextContainer *textContainer;

@property (nonatomic, assign, readonly) CGSize size;

- (instancetype)initWithWidth:(CGFloat)width maximumNumberOfLines:(NSInteger)maximumNumberOfLines attributedString:(NSAttributedString *)attributedString;

@end

NS_ASSUME_NONNULL_END
