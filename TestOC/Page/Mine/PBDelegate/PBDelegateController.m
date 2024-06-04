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
 答：novelcore利用代理反向调用novel，novel调用growth。

 PS：
 利用代理或block反向调用，只能调用行为，行为传系统类型或底层类型，无法传上层类型。因为底层不依赖上层，所以无法使用上层类型。
 代理或block之所以能反向调用，本质还是头文件与源文件分离在不同仓库，还是上层对底层的依赖，只不过将头文件分离后进行下沉。协议相当于头文件，位于下层，实现相当于源文件，位于上层。
 接口与实现分离，接口在下，实现在上。

 问：novelcore需要使用growth中的类型，如何处理？
 答：novelcore利用代理反向调用novel，novel调用growth。在novel中将growth的类型转换为novelcore的类型后返回。相当于novelcore使用growth中的类型。

 PS：
 若底层非要使用上层类型且不好将上层类型下沉，可以调用行为传底层类型后，在上层将上层类型类型转换为底层类型后返回。
 */

@implementation PBDelegateController

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
