//
//  AppDelegate.m
//  HybridPageKit-Demo
//
//  Created by deqzhu on 2019/3/3.
//  Copyright © 2019 dequanzhu. All rights reserved.
//

#import "AppDelegate.h"
#import "ListViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController *navigationcontroller = [[UINavigationController alloc] initWithRootViewController:[[ListViewController alloc]init]];
    self.window.rootViewController = navigationcontroller;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}


- (void)applicationWillTerminate:(UIApplication *)application {
}


@end
