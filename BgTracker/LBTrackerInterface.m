//
//  LBTrackerInterface.m
//  BgTracker
//
//  Created by Jason on 15/7/25.
//  Copyright (c) 2015年 Gong Zhang. All rights reserved.
//

#import "LBTrackerInterface.h"
#import "LBHTTPClient.h"
#import "LBDeviceInfoManager.h"
#import "LBInstallation.h"
#import "LBDataCenter.h"
#import "LBLocationCenter.h"

static NSString *const kLBSenzAuthIDString = @"5548eb2ade57fc001b000001938f317f306f4fc254cdc7becb73821a";

@interface LBTrackerInterface ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSTimer *uploadTimer;
@property (nonatomic, strong) NSTimer *sensorTimer;

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


- (instancetype)init
{
    if (self = [super init]) {
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
    
    [[LBLocationCenter sharedLocationCenter] prepare];
    
    self.delegate = delegate;
    if ([LBInstallation installationAvaliable]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate trackerDidInitialized];
        });
        return;
    }
    
    NSString *hardwareId = [[LBDeviceInfoManager sharedInstance] hardwareID];
    NSString *appid = [[LBDeviceInfoManager sharedInstance] appID];
    NSString *deviceType = @"ios";
    
    NSDictionary *param =   @{
                              @"hardwareId":hardwareId,
                              @"appid":appid,
                              @"deviceType":deviceType
                              };
    
    [self queryInstallationWithDevitionInfo:param];

}

+ (void)initalizeTrackerWithDelegate:(id<LBTrackerDelegate>)delegate retryCount:(NSUInteger)count
{
    // TODO :
}


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
    if (self.uploadTimer) {
        [self.uploadTimer invalidate];
        self.uploadTimer = nil;
    }

    [[LBLocationCenter sharedLocationCenter] startForegroundUpdating];
    
    // Fire data collection every 10min.
    self.uploadTimer = [NSTimer scheduledTimerWithTimeInterval:time
                                                        target:self
                                                      selector:@selector(fireDataCollection)
                                                      userInfo:nil
                                                       repeats:YES];
    self.started = YES;
    return YES;
    
}


+ (void)stopTracker
{
    [[self sharedInterface] stopTracker];
}

- (void)stopTracker
{
    [self.uploadTimer invalidate];
    [self.sensorTimer invalidate];
}



#pragma mark -
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

- (void)fireDataUpload
{
    LBLocationRecord *location = [[LBDataCenter sharedInstance] popLocationRecord];
    [LBHTTPClient uploadLocationRecord:location
                              onSuccess:^(id responseObject, NSDictionary *info) {
                                  NSLog(@"location upload success.");
                              }
                              onFailure:^(NSError *error, NSDictionary *info) {
                                  [[LBDataCenter sharedInstance] pushLocationRecord:location];
                              }
     ];
    
    NSArray *sensorArray = [[LBDataCenter sharedInstance] popSensorRecordsForCount:100];
    [LBHTTPClient uploadSensorRecords:sensorArray
                              onSuccess:^(id responseObject, NSDictionary *info) {
                                  NSLog(@"sensor upload success");
                              }
                              onFailure:^(NSError *error, NSDictionary *info) {
                                  for (LBSenserRecord *record in sensorArray) {
                                      [[LBDataCenter sharedInstance] pushPendingSensorRecord:record];
                                  }
                              }
     ];
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

#pragma mark - Network

- (void)queryInstallationWithDevitionInfo:(NSDictionary *)param
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.trysenz.com/utils/exchanger/createInstallation"]];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:30.0f];
    [request setValue:kLBSenzAuthIDString forHTTPHeaderField:@"X-senz-Auth"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:NULL];
    [request setHTTPBody:data];
    
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if(!connectionError && [data length] > 0){
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
                LBInstallation *installation = [[LBInstallation alloc] initWithDictionary:dict[@"result"]];
                [installation saveToDisk];
                if (self.delegate && [self.delegate respondsToSelector:@selector(trackerDidInitialized)]) {
                    [self.delegate trackerDidInitialized];
                }
            }else{
                NSLog(@"error : %@",connectionError);
            }
        }
    }];
}




@end
