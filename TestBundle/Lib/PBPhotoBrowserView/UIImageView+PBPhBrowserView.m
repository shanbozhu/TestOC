//
//  UIImageView+PBPhBrowserView.m
//  陪伴Ta
//
//  Created by DaMaiIOS on 16/7/26.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import "UIImageView+PBPhBrowserView.h"


@implementation UIImageView (PBPhBrowserView)

//getter
-(NSInteger)pbTag {
    return [objc_getAssociatedObject(self, @selector(pbTag)) integerValue];
}
//setter
-(void)setPbTag:(NSInteger)pbTag {
    objc_setAssociatedObject(self, @selector(pbTag), @(pbTag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
