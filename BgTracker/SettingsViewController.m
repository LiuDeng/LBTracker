//
//  SettingsViewController.m
//  BgTracker
//
//  Created by Gong Zhang on 2015/6/19.
//  Copyright © 2015年 Gong Zhang. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsKeys.h"
//#import "LBLocationCenter.h"

NSString * const kTrackingInForeground  = @"TrackingInForeground";
NSString * const kTrackingInBackground  = @"TrackingInBackground";

@interface SettingsViewController ()
//@property (strong) LBLocationCenter *locationCenter;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.locationCenter = [LBLocationCenter sharedLocationCenter];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 2;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 0) {
//        return 2;
//    } else if (section == 1) {
//        return 1;
//    } else {
//        return 0;
//    }
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//    
//    if (indexPath.section == 0 && indexPath.row == 0) {
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tracking_in_fg_switch"];
//        UISwitch *sw = (UISwitch *) [cell viewWithTag:1];
//        sw.on = [[def objectForKey:kTrackingInForeground] boolValue];
//        return cell;
//    } else if (indexPath.section == 0 && indexPath.row == 1) {
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tracking_in_bg_switch"];
//        UISwitch *sw = (UISwitch *) [cell viewWithTag:1];
//        sw.on = [[def objectForKey:kTrackingInBackground] boolValue];
//        return cell;
//    } else if (indexPath.section == 1 && indexPath.row == 0) {
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clear_region_monitor_button"];
//        return cell;
//    } else {
//        return nil;
//    }
//}
//
//- (void)tableView:( UITableView *)tableView didSelectRowAtIndexPath:( NSIndexPath *)indexPath {
//    if (indexPath.section == 1 && indexPath.row == 0) {
//        // clear current region
//        NSString *message = nil;
//        if ([self.locationCenter clearRegionMonitor]) {
//            message = @"The region is cleared.";
//        } else {
//            message = @"There is no region under monitoring currently.";
//        }
//        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Region Monitoring"
//                                                                            message:message
//                                                                     preferredStyle:UIAlertControllerStyleAlert];
//        
//        [controller addAction:[UIAlertAction actionWithTitle:@"OK"
//                                                       style:UIAlertActionStyleDefault
//                                                     handler:^(UIAlertAction *  action) {}]];
//        
//        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//        [self presentViewController:controller animated:YES completion:^{}];
//    }
//}
//
//- ( NSString *)tableView:( UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    switch (section) {
//        case 0:
//            return @"Location Service";
//        case 1:
//            return @"Region Monitoring";
//        default:
//            return nil;
//    }
//}
//
//- (IBAction)trackingInForegroundSwitchAction:(id)sender {
//    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//    UISwitch *sw = sender;
//    [def setObject:@(sw.on) forKey:kTrackingInForeground];
//    if (sw.on) {
//        [self.locationCenter startForegroundUpdating];
//    } else {
//        [self.locationCenter stopForegroundUpdating];
//    }
//}
//
//- (IBAction)trackingInBackgroundSwitchAction:(id)sender {
//    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//    UISwitch *sw = sender;
//    [def setObject:@(sw.on) forKey:kTrackingInBackground];
//}

@end
