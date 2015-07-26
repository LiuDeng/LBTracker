//
//  DataViewController.m
//  BgTracker
//
//  Created by Gong Zhang on 2015/6/18.
//  Copyright © 2015年 Gong Zhang. All rights reserved.
//

#import "DataViewController.h"
#import "LBLocationCenter.h"
#import "LBHTTPClient.h"
#import "LBDeviceInfoManager.h"
#import "LBTrackerInterface.h"

@interface DataViewController () <LBLocationCenterDelegate,NSURLConnectionDelegate,LBTrackerDelegate>
@property (strong) LBLocationCenter *locationCenter;
@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [LBTrackerInterface initalizeTrackerWithDelegate:self];
    
    // Do any additional setup after loading the view.
    self.locationCenter = [LBLocationCenter sharedLocationCenter];
    [self.locationCenter addDelegate:self];
}

- (void)trackerDidInitialized
{
    
}

- (void)trackerDidFaileToInitializeWithError:(NSError *)error
{
    NSLog(@"error: %@", error);
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.locationCenter.isReady == NO) {
        return 0;
    } else {
        return self.locationCenter.locationRecords.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LBLocationRecord *record = self.locationCenter.locationRecords[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"location_cell"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *labelData = [dateFormatter stringFromDate:record.timestamp];
    
    cell.textLabel.text = labelData;
    cell.detailTextLabel.text = record.locationDescription;
    
    return cell;
}

- (BOOL)tableView:( UITableView *)tableView canEditRowAtIndexPath:( NSIndexPath *)indexPath {
    return YES;
}

- ( NSArray *)tableView:( UITableView *)tableView editActionsForRowAtIndexPath:( NSIndexPath *)indexPath {
    __weak DataViewController *weakSelf = self;
    
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Monitor Here" handler:^(UITableViewRowAction *  action, NSIndexPath *  indexPath) {
        
        LBLocationRecord *record = weakSelf.locationCenter.locationRecords[indexPath.row];
        [weakSelf.locationCenter resetRegionMonitorToLocation:record];
        
        [weakSelf.tableView setEditing:NO animated:YES];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Region Monitoring"
                                                                            message:@"This location is being monitoring."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *  action) {}]];
        
        [self presentViewController:controller animated:YES completion:^{}];
    }];
    action.backgroundColor = [UIColor purpleColor];
    
    return @[ action ];
}

#pragma mark - Location Delegate

- (void)locationCenter:(LBLocationRecord*)locationCenter didInsertRecordAtIndex:(NSUInteger)index {
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)locationCenterDidClearAllData:(LBLocationRecord *)locationCenter {
    [self.tableView reloadData];
}

#pragma mark - UI Delegate
- (IBAction)getInstallationID:(id)sender {
    
    LBHTTPClient *client = [LBHTTPClient sharedClient];
    
    
    NSDictionary *param =   @{@"timestamp":@(14020304000),
                              @"type":@"sensor",
                              @"value":@{ @"events":@[
                                  @{@"timestamp":@(2874573193298),
                                      @"accuracy": @(2),
                                      @"sensorName": @"acc",
                                      @"values": @[@(-7.8747406005859375),
                                                   @(5.423065185546875),
                                                   @(2.5889434814453125)]}]}};
    
    
    [client POST:@"/1.1/classes/Log" parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response Objct : %@", responseObject);
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Upload OK" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }) ;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error : %@", error);
    }];
    
}

- (IBAction)clearItemAction:(id)sender {
    
}



@end
