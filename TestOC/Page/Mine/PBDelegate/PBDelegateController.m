//
//  PBDelegateController.m
//  TestOC
//
//  Created by shanbo on 2024/5/23.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBDelegateController.h"

@interface PBDelegateController ()

@end

/**
 novel依赖novelcore
 novel依赖growth
 novelcore比growth还底层

 问：novelcore需要调用growth，如何处理？
 答：novelcore利用delegate反向调用novel，novel调用growth。

 PS：
 利用delegate或block反向调用，只能调用行为，行为传系统类型或底层类型，无法传顶层类型。因为底层不依赖顶层，所以无法使用顶层类型。
 反向调用：传入delegate或block给底层，底层调用，顶层实现。泛型遵守协议，协议下沉。

 问：novelcore需要使用growth中的类型，如何处理？
 答：novelcore利用delegate反向调用novel，novel调用growth。在novel中将growth的类型转换为novelcore的类型后返回。相当于novelcore使用growth中的类型。

 PS：
 若底层非要使用顶层类型且不好将顶层类型下沉，可以调用行为传底层类型后，在顶层将顶层类型类型转换为底层类型后返回。
 */

@implementation PBDelegateController

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
