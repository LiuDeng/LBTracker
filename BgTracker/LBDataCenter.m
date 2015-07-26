//
//  LBDataCenter.m
//  LBTracker
//
//  Created by Jason on 15/7/25.
//  Copyright (c) 2015年 LB. All rights reserved.
//

#import "LBDataCenter.h"
#import "LBLocationCenter.h"
#import "LBDeviceInfoManager.h"
#import "LBDataStore.h"

@interface LBDataCenter ()<LBLocationCenterDelegate>
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSTimer *dataCollectionTimer;
@property (nonatomic, strong) NSTimer *sensorTimer;

@property (nonatomic, strong) LBDataStore *dataStore;

@end

@implementation LBDataCenter

#pragma mark - Init 


IMP_SINGLETON;

+ (void)initializeDataCenter
{
    [[LBLocationCenter sharedLocationCenter] prepare];
    [LBDataCenter sharedInstance];
}


- (instancetype) init
{
    if (self = [super init]) {
//        [self loadDataToMemory];
        _dataStore = [[LBDataStore alloc] init];
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 4;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(locationRecordAvaliable:)
                                                     name:LBLocationCenterNewLocationAvaliableNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorRecordsAvaliable:)
                                                     name:LBDeviceInfoManagerCoreMotionDataReadyNotification
                                                   object:nil];

    }
    
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)startDataColletionWithTimeInterval:(NSTimeInterval)time
{
    if (self.dataCollectionTimer) {
        [self.dataCollectionTimer invalidate];
        self.dataCollectionTimer = nil;
    }
    
    [[LBLocationCenter sharedLocationCenter] startForegroundUpdating];
    [[LBLocationCenter sharedLocationCenter] addDelegate:self];
    [[LBDeviceInfoManager sharedInstance] startCoreMotionMonitorClearData:YES];
    // Fire data collection every 10min.
    self.dataCollectionTimer = [NSTimer scheduledTimerWithTimeInterval:time
                                                        target:self
                                                      selector:@selector(fireDataCollection)
                                                      userInfo:nil
                                                       repeats:YES];
    


    
}

- (void)stopDataCollection
{
    [self.dataCollectionTimer invalidate];
}


- (void)fireDataCollection
{
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        [[LBLocationCenter sharedLocationCenter] startBackgroundUpdating];
    }else {
        [[LBLocationCenter sharedLocationCenter] startForegroundUpdating];
    }
    
    [[LBDeviceInfoManager sharedInstance] startCoreMotionMonitorClearData:YES];
    
    if (self.sensorTimer) {
        [self.sensorTimer invalidate];
    }
    self.sensorTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                        target:self
                                                      selector:@selector(onDataReadyForUpload)
                                                      userInfo:nil
                                                       repeats:YES];
}


#pragma mark - 

- (void)onDataReadyForUpload
{
    NSLog(@"data ready to upload . ");
}


#pragma mark - Notification



- (void)locationRecordAvaliable:(NSNotification *)note
{
    [self.dataStore pushLocationRecord:note.userInfo[LBLocationCenterNewLocationValueKey]];
}

- (void)sensorRecordsAvaliable:(NSNotification *)note
{
    [self.dataStore pushSensorRecords:note.userInfo[LBDeviceInfoManagerSensorValueKey]];
}

- (void)appDidEnterBackground:(NSNotification *)note
{
    if (!([[LBLocationCenter sharedLocationCenter] monitoringType] & LBNotMonitoring)) {
        [[LBLocationCenter sharedLocationCenter] stopForegroundUpdating];
        [[LBLocationCenter sharedLocationCenter] startBackgroundUpdating];
    }
}

- (void)appWillEnterForeground:(NSNotification *)note
{
    if (!([[LBLocationCenter sharedLocationCenter] monitoringType] & LBNotMonitoring)) {
        [[LBLocationCenter sharedLocationCenter] stopBackgroundUpdating];
        [[LBLocationCenter sharedLocationCenter] startForegroundUpdating];
    }
}

- (void)appWillTerminate:(NSNotification *)note
{
    [self.dataStore saveDataToDisk];
}

#pragma mark - LBLocationCenterDelegate
- (void)locationCenter:(LBLocationCenter*)locationCenter didInsertRecordAtIndex:(NSUInteger)index;
{
    [self.dataStore pushLocationRecord:locationCenter.locationRecords[index]];
}
@end
