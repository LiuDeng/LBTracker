//
//  LBDataCenter.m
//  LBTracker
//
//  Created by Jason on 15/7/25.
//  Copyright (c) 2015年 LB. All rights reserved.
//

#import "LBDataCenter.h"
#import "LBLRUMemoryCache.h"
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


@end

@implementation LBDataCenter

IMP_SINGLETON;


- (instancetype) init
{
    if (self = [super init]) {
        [self loadDataToMemory];
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
