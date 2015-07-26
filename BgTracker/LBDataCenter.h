//
//  LBDataCenter.h
//  LBTracker
//
//  Created by Jason on 15/7/25.
//  Copyright (c) 2015年 LB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBSingleton.h"
@class LBLocationRecord;
@class LBSenserRecord;

//TODO: 
@interface LBDataCenter : NSObject

DEF_SINGLETON;

- (void)saveDataToDisk;

- (void)loadDataToMemory;

// Location data stack
- (void)pushLocationRecord:(LBLocationRecord *)record;
- (LBLocationRecord *)popLocationRecord;
- (NSArray *)avaliableLocationRecords;

- (void)pushPendingLocationRecord:(LBLocationRecord *)record;
- (LBLocationRecord *)popPendingLocationRecord;
- (NSArray *)pendingLocationRecords;


// Sensor data stack
- (void)pushSensorRecord:(LBSenserRecord *)record;
- (LBSenserRecord *)popSensorRecord;
- (NSArray *)popSensorRecordsForCount:(NSUInteger)count;
- (NSArray *)avaliableSensorRecords;

- (void)pushPendingSensorRecord:(LBSenserRecord *)record;
- (LBSenserRecord *)popPendingSensorRecord;
- (NSArray *)popPendingSensorRecordsForCount:(NSUInteger)count;
- (NSArray *)pendingSensorRecords;


@end
