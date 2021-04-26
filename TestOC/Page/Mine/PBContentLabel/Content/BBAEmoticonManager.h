//
//  BBAEmoticonManager.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/26.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BBAEmoticonTextAttachment : NSTextAttachment

+ (instancetype)emoticonTextAttachmentWithImage:(NSString *)imageName font:(UIFont *)font;

@end

@interface BBAEmoticonManager : NSObject

- (void)translateAllPlainTextToEmoticonWithAttributedString:(NSMutableAttributedString *)attStr;

@end

NS_ASSUME_NONNULL_END
