//
//  AppDelegate.m
//  BgTracker
//
//  Created by Gong Zhang on 2015/6/18.
//  Copyright © 2015年 Gong Zhang. All rights reserved.
//

#import "AppDelegate.h"
#import "LBLocationCenter.h"
#import "SettingsKeys.h"


//SDK import
#import "LBTrackerInterface.h"

@interface AppDelegate ()<LBTrackerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:( UIApplication *)application
willFinishLaunchingWithOptions:( NSDictionary *)launchOptions {
    // init user defaults
    NSMutableDictionary *defaultsDictionary = [[NSMutableDictionary alloc] init];
    [defaultsDictionary setObject:@NO forKey:kTrackingInForeground];
    [defaultsDictionary setObject:@YES forKey:kTrackingInBackground];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDictionary];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    LBLocationCenter *lc = [LBLocationCenter sharedLocationCenter];
    [lc prepare];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey] != nil) {
        // start from background
        if ([[def objectForKey:kTrackingInBackground] boolValue] == YES) {
            [lc startBackgroundUpdating];
        }
    } else {
        if ([[def objectForKey:kTrackingInForeground] boolValue] == YES) {
            [lc startForegroundUpdating];
        }
    }
    
    
    // SDK Usage
    [LBTrackerInterface initalizeTrackerWithDelegate:self];
    
    return YES;
}

#pragma mark  - LBTrackerDelegate
// SDK Usage
- (void)trackerDidInitialized
{
    [LBTrackerInterface startTracker];
}

- (void)trackerDidFaileToInitializeWithError:(NSError *)error
{
    NSLog(@"error : %@",error);
}



#pragma mark - 


- (void)applicationDidEnterBackground:(UIApplication *)application {
    LBLocationCenter *lc = [LBLocationCenter sharedLocationCenter];
    [lc stopForegroundUpdating];
//    [lc saveData];

    // go to background
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if ([[def objectForKey:kTrackingInBackground] boolValue] == YES) {
        [lc startBackgroundUpdating];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    LBLocationCenter *lc = [LBLocationCenter sharedLocationCenter];
    [lc stopBackgroundUpdating];
//    [lc saveData];
    
    // go to foreground
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if ([[def objectForKey:kTrackingInForeground] boolValue] == YES) {
        [lc startForegroundUpdating];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    LBLocationCenter *lc = [LBLocationCenter sharedLocationCenter];
//    [lc saveData];
}





@end
