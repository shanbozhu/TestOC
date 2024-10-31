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
 novelcore比growth还下层

 问：novelcore需要调用growth，如何处理？
 答：novelcore利用delegate反向调用novel，novel调用growth。

 PS：
 利用delegate或block反向调用，只能调用行为，行为传系统类型或下层类型，无法传上层类型。因为下层不依赖上层，所以无法使用上层类型。
 调用在下，定义在上。

 问：novelcore需要使用growth中的类型，如何处理？
 答：novelcore利用delegate反向调用novel，novel调用growth。在novel中将growth的类型转换为novelcore的类型后返回。相当于novelcore使用growth中的类型。

 PS：
 若下层非要使用上层类型且不好将上层类型下沉，可以调用行为传下层类型后，在上层将上层类型类型转换为下层类型后返回。
 */

@implementation PBDelegateController

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
