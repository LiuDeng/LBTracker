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
#import "LBSenserRecord.h"
#import "LBLocationRecord.h"
#import "LBRecordStack.h"


#define kLocationRecordCountMAX  100
#define kSensorRecordCountMAX  1000

@interface LBDataCenter ()

@property (nonatomic, strong) LBRecordStack *locationRecords;
@property (nonatomic, strong) LBRecordStack *sensorRecords;

@property (nonatomic, strong) LBRecordStack *pendingLocations;
@property (nonatomic, strong) LBRecordStack *pendingSensors;

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSTimer *uploadTimer;
@property (nonatomic, strong) NSTimer *sensorTimer;



@end

@implementation LBDataCenter



#pragma mark - Init 


IMP_SINGLETON;

+ (void)initializeDataCenter
{
    [[LBLocationCenter sharedLocationCenter] prepare];
}

- (void)startDataColletionWithTimeInterval:(NSTimeInterval)time
{
    if (self.uploadTimer) {
        [self.uploadTimer invalidate];
        self.uploadTimer = nil;
    }
    
    [[LBLocationCenter sharedLocationCenter] startForegroundUpdating];
    [[LBDeviceInfoManager sharedInstance] startCoreMotionMonitorClearData:YES];
    // Fire data collection every 10min.
    self.uploadTimer = [NSTimer scheduledTimerWithTimeInterval:time
                                                        target:self
                                                      selector:@selector(fireDataCollection)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void)stopDataCollection
{
    [self.uploadTimer invalidate];
    [self.sensorTimer invalidate];
}

- (instancetype) init
{
    if (self = [super init]) {
        [self loadDataToMemory];
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
    }
    
    return self;
}

- (void)saveDataToDisk
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)loadDataToMemory
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)fireDataCollection
{
    if (self.sensorTimer) {
        [self.sensorTimer invalidate];
        self.sensorTimer = nil;
    }
    [[LBDeviceInfoManager sharedInstance] startCoreMotionMonitorClearData:YES];
    self.sensorTimer  = [NSTimer scheduledTimerWithTimeInterval:10
                                                         target:self
                                                       selector:@selector(fireDataUpload)
                                                       userInfo:nil
                                                        repeats:NO];
    
}



#pragma mark - Location records 

- (void)pushLocationRecord:(LBLocationRecord *)record
{
    [self.locationRecords pushRecord:record];
}

- (LBLocationRecord *)popLocationRecord
{
    return [self.locationRecords pop];
}

- (NSArray *)avaliableLocationRecords;
{
    return  [[self.locationRecords allRecords] copy];
}


- (void)pushPendingLocationRecord:(LBLocationRecord *)record
{
    [self.pendingLocations pushRecord:record];
}

- (LBLocationRecord *)popPendingLocationRecord
{
    return [self.pendingLocations pop];
}

- (NSArray *)pendingLocationRecords
{
    return [[self.pendingLocations allRecords] copy];
}


#pragma mark - Sensor records

- (void)pushSensorRecord:(LBSenserRecord *)record;
{
    [self.sensorRecords pushRecord:record];
}

- (LBSenserRecord *)popSensorRecord
{
    return [self.sensorRecords pop];
}

- (NSArray *)popSensorRecordsForCount:(NSUInteger)count
{
    return [self.sensorRecords popForCount:count];
}

- (NSArray *)avaliableSensorRecords;
{
    return  [[self.sensorRecords allRecords] copy];;
}


- (void)pushPendingSensorRecord:(LBSenserRecord *)record
{
    [self.pendingSensors pushRecord:record];
}

- (LBSenserRecord *)popPendingSensorRecord
{
    return [self.pendingSensors pop];
}

- (NSArray *)popPendingSensorRecordsForCount:(NSUInteger)count
{
    return [self.pendingSensors popForCount:count];
}

- (NSArray *)pendingSensorRecords
{
    return [[self.pendingSensors allRecords] copy];
}

#pragma mark - Notification

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
    [[LBDataCenter sharedInstance] saveDataToDisk];
}



#pragma mark - Getter

- (LBRecordStack *)locationRecords
{
    if (!_locationRecords) {
        _locationRecords = [[LBRecordStack alloc] initWithCapacity:kLocationRecordCountMAX];
    }
    return _locationRecords;
}

- (LBRecordStack *)sensorRecords
{
    if (!_sensorRecords) {
        _sensorRecords = [[LBRecordStack alloc] initWithCapacity:kSensorRecordCountMAX];
    }
    
    return _sensorRecords;
}


- (LBRecordStack *)pendingLocations
{
    if (!_pendingLocations) {
        _pendingLocations = [[LBRecordStack alloc] initWithCapacity:kLocationRecordCountMAX];
    }
    return _pendingLocations;
}


- (LBRecordStack *)pendingSensors
{
    if (!_pendingSensors) {
        _pendingSensors = [[LBRecordStack alloc] initWithCapacity:kSensorRecordCountMAX];
    }
    return _pendingSensors;
}






@end
