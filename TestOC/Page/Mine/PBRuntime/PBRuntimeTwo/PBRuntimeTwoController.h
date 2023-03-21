//
//  PBRuntimeTwoController.h
//  TestOC
//
//  Created by shanbo on 2023/3/20.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBBaseController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PBRuntimeTwoControllerProtocol <NSObject>

- (void)run1;
+ (void)run2;

@optional
- (void)run3;
+ (void)run4;

@end

@interface PBRuntimeTwoController : PBBaseController <PBRuntimeTwoControllerProtocol> {
    NSString *_age;
}

@property (nonatomic, strong) NSString *name;

@end

NS_ASSUME_NONNULL_END
