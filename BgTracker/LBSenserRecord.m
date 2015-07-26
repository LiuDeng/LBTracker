//
//  LBSenserRecord.m
//  BgTracker
//
//  Created by Jason on 15/7/26.
//  Copyright (c) 2015年 Gong Zhang. All rights reserved.
//

#import "LBSenserRecord.h"
#import <CoreMotion/CoreMotion.h>

@implementation LBSenserRecord

- (instancetype)init
{
    if (self = [super init]) {
        self.timestamp = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (NSDictionary *)JSONRepresentation
{
    
    return @{@"timestamp":@(self.timestamp),
             @"accuracy":self.accuracy,
             @"sensorName":self.senserName ?: @"sensor",
             @"values":self.values
             };
}

@end


/////////////////////////////////////////////////////////////////////


@implementation LBAccelerateRecord

- (instancetype)initWithDeviceMotion:(CMDeviceMotion *)motion
{
    if (self = [super init]) {
        self.senserName = @"acc";
        self.accuracy   = @(1.0);
        self.values     = [NSArray arrayWithObjects:@(motion.userAcceleration.x),@(motion.userAcceleration.y),@(motion.userAcceleration.z),nil];
    }
    
    return self;
}

@end


/////////////////////////////////////////////////////////////////////


@implementation LBGravityRecord


- (instancetype)initWithDeviceMotion:(CMDeviceMotion *)motion
{
    if (self = [super init]) {
        self.senserName = @"grav";
        self.accuracy   = @(1.0);
        self.values     = [NSArray arrayWithObjects:@(motion.gravity.x),@(motion.gravity.y),@(motion.gravity.z),nil];
    }

    return self;
}


@end


/////////////////////////////////////////////////////////////////////


@implementation LBMagnetometerRecord

- (instancetype)initWithMagnatometerData:(CMMagnetometerData *)data
{
    if (self = [super init]) {
        self.senserName = @"mag";
        self.accuracy   = @(1.0);
        self.values     = [NSArray arrayWithObjects:@(data.magneticField.x),@(data.magneticField.y),@(data.magneticField.z),nil];
    }
    
    return self;
}

@end

