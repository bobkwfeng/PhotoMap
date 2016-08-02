//
//  AppDelegate.m
//  PhotoMapp
//
//  Created by Bob Feng on 7/19/16.
//  Copyright © 2016 Bob Feng. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SecondViewController.h"
#import "MapViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSThread sleepForTimeInterval:3.0];
    // Override point for customization after application launch.
    
    
    // return YES;
    
    
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    
    // Override point for customization after application launch.
    BOOL shouldPerformAdditionalDelegateHandling = YES;
    
    
    // Check API availiability
    // UIApplicationShortcutItem is available in iOS 9 or later.
    if([[UIApplicationShortcutItem class] respondsToSelector:@selector(new)]){
        
        [self configDynamicShortcutItems];
        
        // If a shortcut was launched, display its information and take the appropriate action
        UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKeyedSubscript:UIApplicationLaunchOptionsShortcutItemKey];
        NSLog(shortcutItem);
        
        if(shortcutItem)
        {
            NSLog(@"eee");
            // When the app launch at first time, this block can not called.
            
            [self handleShortCutItem:shortcutItem];
            
            // This will block "performActionForShortcutItem:completionHandler" from being called.
            shouldPerformAdditionalDelegateHandling = NO;
            
            
        }else{
            // normal app launch process without quick action
            
            [self launchWithoutQuickAction];
            
        }
        
    }else{
        
        // Less than iOS9 or later
        
        [self launchWithoutQuickAction];
        
    }
    
    
    return shouldPerformAdditionalDelegateHandling;

    
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}


// This is for 3d touch

-(void)launchWithoutQuickAction{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    SecondViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"tabView"];
    
    self.window.rootViewController = vc;
    
    [self.window makeKeyAndVisible];
    
}


- (void)configDynamicShortcutItems {
    
    // config image shortcut items
    // if you want to use custom image in app bundles, use iconWithTemplateImageName method
    UIApplicationShortcutIcon *shortcutFavoriteIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeLove];
    
    UIApplicationShortcutItem *shortcutSearch = [[UIApplicationShortcutItem alloc]
                                                 initWithType:@"com.sarangbang.QuickAction.Search"
                                                 localizedTitle:@"Team 15 Enjoy! :)"
                                                 localizedSubtitle:nil
                                                 icon:shortcutFavoriteIcon
                                                 userInfo:nil];
    
    
    
    // add all items to an array
    NSArray *items = @[shortcutSearch];
    
    // add the array to our app
    [UIApplication sharedApplication].shortcutItems = items;
}



- (BOOL)handleShortCutItem : (UIApplicationShortcutItem *)shortcutItem{
    
    BOOL handled = NO;
    
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
    
    NSString *shortcutSearch = [NSString stringWithFormat:@"%@.Search", bundleId];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    
    if ([shortcutItem.type isEqualToString:shortcutSearch]) {
        handled = YES;
        NSLog(@"xdxdxd");
        SecondViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"View"];
        self.window.rootViewController = vc;
        [self.window makeKeyAndVisible];
    }
    return handled;
}


- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
    
    BOOL handledShortCutItem = [self handleShortCutItem:shortcutItem];
    
    completionHandler(handledShortCutItem);
}



@end
