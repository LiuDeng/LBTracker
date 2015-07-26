//
//  LBTrackerInterface.m
//  BgTracker
//
//  Created by Jason on 15/7/25.
//  Copyright (c) 2015年 Gong Zhang. All rights reserved.
//

#import "LBTrackerInterface.h"
#import "LBHTTPClient.h"
#import "LBDataCenter.h"



@interface LBTrackerInterface () <LBHTTPClientDelegate>
@property (nonatomic, assign) BOOL started;
@end


@implementation LBTrackerInterface

+ (LBTrackerInterface *)sharedInterface
{
    static LBTrackerInterface *_sharedTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedTracker = [[LBTrackerInterface alloc] init];
    });
    return _sharedTracker;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


+ (void)initalizeTrackerWithDelegate:(id<LBTrackerDelegate>)delegate;
{
    [[self sharedInterface] initalizeTrackerWithDelegate:delegate];
}


- (void)initalizeTrackerWithDelegate:(id<LBTrackerDelegate>)delegate
{
    [LBDataCenter initializeDataCenter];
    [[LBHTTPClient sharedClient] initializeClientWithDelegate:self];
}


+ (void)initalizeTrackerWithDelegate:(id<LBTrackerDelegate>)delegate retryCount:(NSUInteger)count
{
    // TODO :
}

/*启动Tracker,工作方式:
 1. 开启一次定位数据采集,和传感器数据采集.采集到数据后停掉定位和传感器.等待定时器唤起下一次数据采集.
 2. 每10分钟启动一次定位请求,同时启动一次连续10秒钟的传感器数据采集.
 3. 传感器数据采集时间结束 && 定位数据返回 ＝> 启动数据上传.
 */
+ (BOOL)startTracker
{
    return [self startTrackerWithUploadTimeInterval:10*60];

}

+ (BOOL)startTrackerWithUploadTimeInterval:(NSTimeInterval)time
{
    return [[self sharedInterface] startTrackerWithUploadTimeInterval:time];
}


- (BOOL)startTrackerWithUploadTimeInterval:(NSTimeInterval)time
{
    if (self.started) {
        [self stopTracker];
    }
    
    [[LBDataCenter sharedInstance] startDataColletionWithTimeInterval:time];
    
    self.started = YES;
    return YES;
    
}


+ (void)stopTracker
{
    [[self sharedInterface] stopTracker];
}

- (void)stopTracker
{
    [[LBDataCenter sharedInstance] stopDataCollection];
    self.started = NO;
}



#pragma mark - LBHTTPClientDelegate

- (void)HTTPClientDidInitializedWithInfo:(NSDictionary *)info;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(trackerDidInitialized)]) {
        [self.delegate trackerDidInitialized];
    }
}

- (void)HTTPClientDidFailToInitializeWithError:(NSError *)error;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(trackerDidFaileToInitializeWithError:)]) {
        [self.delegate trackerDidFaileToInitializeWithError:error];
    }
}






@end
