//
//  LBDataCenter.h
//  LBTracker
//
//  Created by Jason on 15/7/25.
//  Copyright (c) 2015年 LB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBSingleton.h"

//TODO: 
@interface LBDataCenter : NSObject

DEF_SINGLETON;


+ (void)initializeDataCenter;

- (void)startDataColletionWithTimeInterval:(NSTimeInterval)time;
- (void)stopDataCollection;

@end
