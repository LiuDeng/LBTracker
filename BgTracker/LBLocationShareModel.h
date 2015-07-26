//
//  LBLocationShareModel.h
//  BgTracker
//
//  Created by Jason on 15/7/27.
//  Copyright (c) 2015年 Gong Zhang. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "LBBackgroundTaskManager.h"
#import <CoreLocation/CoreLocation.h>

@interface LBLocationShareModel : NSObject

@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSTimer * delay10Seconds;
@property (nonatomic) LBBackgroundTaskManager * bgTask;
@property (nonatomic) NSMutableArray *myLocationArray;

+(id)sharedModel;

@end
