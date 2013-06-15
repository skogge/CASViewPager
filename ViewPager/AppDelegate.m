//
//  CASAppDelegate.m
//  ViewPager
//
//  Created by Christian Skogsberg on 14/06/13.
//  Copyright (c) 2013 Christian Skogsberg. All rights reserved.
//

#import "AppDelegate.h"
#import "CASViewPagerController.h"
#import "ExampleViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[CASViewPagerController alloc] init];
    ExampleViewController* controller1 = [[ExampleViewController alloc] init];
    controller1.title = @"TEST 1";
    ExampleViewController* controller2 = [[ExampleViewController alloc] init];
    controller2.title = @"TEST 2";
    ExampleViewController* controller3 = [[ExampleViewController alloc] init];
    controller3.title = @"TEST 3";
    NSArray* viewControllers = [NSArray arrayWithObjects:controller1, controller2, controller3, nil];
    self.viewController.viewControllers = viewControllers;
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [controller1 setTextTitle:@"Test 1"];
    [controller2 setTextTitle:@"Test 2"];
    [controller3 setTextTitle:@"Test 3"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
