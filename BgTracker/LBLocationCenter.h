//
//  LBLocationCenter.h
//  BgTracker
//
//  Created by Jason on 15/7/25.
//  Copyright (c) 2015年 Gong Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBLocationRecord.h"


@class LBLocationCenter;

@protocol LBLocationCenterDelegate <NSObject>
@optional
- (void)locationCenter:(LBLocationCenter*)locationCenter didInsertRecordAtIndex:(NSUInteger)index;
- (void)locationCenterDidClearAllData:(LBLocationCenter*)locationCenter;
@end

@interface LBLocationCenter : NSObject

+ (LBLocationCenter*)sharedLocationCenter;

- (void)prepare;
- (void)startForegroundUpdating;
- (void)stopForegroundUpdating;
- (void)startBackgroundUpdating;
- (void)stopBackgroundUpdating;

- (void)clearAllData;
- (void)saveData;

- (void)addDelegate:(id <LBLocationCenterDelegate>)delegate;
- (void)removeDelegate:(id <LBLocationCenterDelegate>)delegate;

- (void)resetRegionMonitorToLocation:(LBLocationRecord*)loc;
- (BOOL)clearRegionMonitor;

@property (readonly) BOOL isReady;
@property (readonly) BOOL isDataDirty;

@property (readonly) LBMonitoringType monitoringType;

@property (readonly) NSArray *locationRecords;
@property (readonly) CLRegion *currentMonitoredRegion;

@end
