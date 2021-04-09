//
//  AppDelegate.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "AppDelegate.h"
#import "PBHomeController.h"
#import "PBMineController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor whiteColor];
    
//    //Controller
//    PBHomeController *vc0 = [[PBHomeController alloc]init];
//    vc0.view.backgroundColor = [UIColor whiteColor];
//    vc0.title = @"首页";
//
//    PBMineController *vc1 = [[PBMineController alloc]init];
//    vc1.view.backgroundColor = [UIColor whiteColor];
//    vc1.title = @"我的";
//
//    UITabBarController *tab = [[UITabBarController alloc]init];
//    tab.viewControllers = @[vc0, vc1];
//
//    PBNavigationController *nav = [[PBNavigationController alloc]initWithRootViewController:tab];
//    nav.navigationBar.barTintColor = [UIColor redColor];
//
//    //window.rootViewController
//    self.window.rootViewController = nav;
    

    //Controller
    PBHomeController *vc1 = [[PBHomeController alloc]init];
    UINavigationController *nav1 = [[PBNavigationController alloc]initWithRootViewController:vc1];
    vc1.view.backgroundColor = [UIColor whiteColor];
    vc1.title = @"首页";
    
    PBMineController *vc2 = [[PBMineController alloc]init];
    UINavigationController *nav2 = [[PBNavigationController alloc]initWithRootViewController:vc2];
    vc2.view.backgroundColor = [UIColor whiteColor];
    vc2.title = @"我的";
    
    PBTabBarController *tab = [[PBTabBarController alloc]init];
    tab.viewControllers = @[nav1, nav2];
    
    //window.rootViewController
    self.window.rootViewController = tab;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
