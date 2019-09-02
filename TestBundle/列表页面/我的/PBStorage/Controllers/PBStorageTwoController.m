//
//  PBStorageTwoController.m
//  TestBundle
//
//  Created by Zhu,Shanbo on 2019/9/2.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBStorageTwoController.h"
#import "PBSandBox.h"

@interface PBStorageTwoController ()

@end

@implementation PBStorageTwoController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"SandBox";
    self.title = @"SandBox";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSLog(@"[PBSandBox path4Home] = %@", [PBSandBox path4Home]);
//    NSLog(@"[PBSandBox path4Home] = %@", [PBSandBox path4Library]);
//    NSLog(@"[PBSandBox path4Home] = %@", [PBSandBox path4LibraryCaches]);
//    NSLog(@"[PBSandBox path4Home] = %@", [PBSandBox path4Documents]);
//    NSLog(@"[PBSandBox path4Home] = %@", [PBSandBox path4Tmp]);
    
//    // 获取指定路径下的所有文件路径,包括子目录中的文件路径
//    for (NSString *filePath in [[NSFileManager defaultManager] enumeratorAtPath:[PBSandBox path4Home]]) {
//        NSLog(@"filePath = %@", filePath);
//    }
    
    // 获取指定路径下的所有文件路径
    for (NSString *fileName in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[PBSandBox path4Home] error:nil]) {
        NSString *filePath = [[PBSandBox path4Home] stringByAppendingPathComponent:fileName];
        NSLog(@"fileName = %@", [PBSandBox fileInfosAtPath:filePath]);
    }
}

@end
