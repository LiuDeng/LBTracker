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

@interface AppDelegate ()

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
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    LBLocationCenter *lc = [LBLocationCenter sharedLocationCenter];
    [lc stopForegroundUpdating];
    [lc saveData];

    // go to background
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if ([[def objectForKey:kTrackingInBackground] boolValue] == YES) {
        [lc startBackgroundUpdating];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    LBLocationCenter *lc = [LBLocationCenter sharedLocationCenter];
    [lc stopBackgroundUpdating];
    [lc saveData];
    
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
    [lc saveData];
}

@end
