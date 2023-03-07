//
//  PBServiceProtocol.h
//  TestOC
//
//  Created by shanbo on 2023/3/7.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PBServiceProtocol <NSObject>

@property (nonatomic, copy) NSString *provideData;

- (void)doSomething;

@end

NS_ASSUME_NONNULL_END
