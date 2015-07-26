//
//  LBLocationCenter.m
//  BgTracker
//
//  Created by Jason on 15/7/25.
//  Copyright (c) 2015年 Gong Zhang. All rights reserved.
//

#import "LBLocationCenter.h"
#import <CoreLocation/CoreLocation.h>
#import "LBWeakList.h"


NSString *const LBLocationCenterErrorDomain = @"LBLocationCenterErrorDomain";
NSString *const LBLocationCenterNewLocationAvaliableNotification = @"LBLocationCenterNewLocationAvaliableNotification";
NSString *const LBLocationCenterNewLocationValueKey = @"LBLocationCenterNewLocationValueKey";


static LBLocationCenter* sharedInstance = nil;

static NSString* kRegionMonitorID = @"co.gongch.lab.BgTracker.defaultRegion";

@interface LBLocationCenter () <CLLocationManagerDelegate>
- (instancetype)init;
- (NSString*)datafilePath;
@property (strong) CLLocationManager *locationManager;
@property (strong) NSDate *lastUpdateTime;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

@end


@implementation LBLocationCenter {
    LBMonitoringType _monitoringType;
    NSString *_datafilePath;
    NSMutableArray *_locationRecords;
    BOOL _dataDirty;
    LBWeakList *_delegates;
}

+ (LBLocationCenter*)sharedLocationCenter {
    if (sharedInstance == nil) {
        sharedInstance = [[LBLocationCenter alloc] init];
    }
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _monitoringType = LBNotMonitoring;
        _lastUpdateTime = nil;
        _datafilePath = nil;
        _locationRecords = nil;
        _dataDirty = NO;
        _delegates = [[LBWeakList alloc] init];
    }
    return self;
}

#pragma mark - Runloop

+ (void)locationUpdateThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"LBTracker"];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

+ (NSThread *)locationUpdateThread {
    static NSThread *_locationUpdateThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _locationUpdateThread = [[NSThread alloc] initWithTarget:self selector:@selector(locationUpdateThreadEntryPoint:) object:nil];
        [_locationUpdateThread start];
    });
    
    return _locationUpdateThread;
}


#pragma mark - Location Service

- (void)prepareWithDelegate:(id<LBLocationCenterDelegate>)delegate;{
    self.delegate = delegate;
    if (self.isReady) {
        NSLog(@"LocationCenter is already ready :p");
        [self.delegate locationCenter:self didPreparedWithInfo:nil];
        return;
    }
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    [self requestLocationAuthorization];
    
//    if (_locationRecords == nil) {
//        NSMutableArray* array = [NSKeyedUnarchiver unarchiveObjectWithFile:[self datafilePath]];
//        _locationRecords = [[NSMutableArray alloc] init];
//        if (array != nil) {
//            [_locationRecords addObjectsFromArray:array];
//            NSLog(@"LocationCenter loaded %ld records", (unsigned long) array.count);
//        } else {
//            NSLog(@"LocationCenter loaded 0 record");
//        }
//    }
    
    if (self.isReady) {
        NSLog(@"LocationCenter is ready :)");
    }
}

- (BOOL)isReady {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    return status == kCLAuthorizationStatusAuthorizedAlways;
}

- (void)requestLocationAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status != kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager requestAlwaysAuthorization];
        if (self.isReady) {
            NSLog(@"Authorization OK ;)");
        } else {
            NSLog(@"Authorization Failed x_x");
        }
    }
}

- (void)startForegroundUpdating {
    if (self.isReady) {
        if (_monitoringType == LBForegroundMonitoring) {
            return;
        } else if (_monitoringType == LBBackgroundMonitoring) {
            [self stopBackgroundUpdating];
        }
        [self.locationManager startUpdatingLocation];
        _monitoringType = LBForegroundMonitoring;
        NSLog(@"LocationCenter foreground start!");
    }
}

- (void)stopForegroundUpdating {
    if (self.isReady) {
        if (_monitoringType == LBForegroundMonitoring) {
            [self.locationManager stopUpdatingLocation];
            _monitoringType = LBNotMonitoring;
            NSLog(@"LocationCenter foreground stop!");
        }
    }
}

- (void)startBackgroundUpdating {
    if (self.isReady) {
        if (_monitoringType == LBBackgroundMonitoring) {
            return;
        } else if (_monitoringType == LBForegroundMonitoring) {
            [self stopForegroundUpdating];
        }
        [self.locationManager startMonitoringSignificantLocationChanges];
        [self.locationManager startMonitoringVisits];
        _monitoringType = LBBackgroundMonitoring;
        NSLog(@"LocationCenter background start!");
    }
}

- (void)stopBackgroundUpdating {
    if (self.isReady) {
        if (_monitoringType == LBBackgroundMonitoring) {
            [self.locationManager stopMonitoringSignificantLocationChanges];
            [self.locationManager stopMonitoringVisits];
            _monitoringType = LBNotMonitoring;
            NSLog(@"LocationCenter background stop!");
        }
    }
}

- (LBMonitoringType)monitoringType {
    return _monitoringType;
}

- (void)addDelegate:(id <LBLocationCenterDelegate>)delegate {
    [_delegates addObject:delegate];
}

- (void)removeDelegate:(id <LBLocationCenterDelegate>)delegate {
    [_delegates removeObject:delegate];
}

#pragma mark - Region Monitoring

- (CLRegion*)currentMonitoredRegion {
    __block CLRegion *region = nil;
    [self.locationManager.monitoredRegions enumerateObjectsUsingBlock:^( CLRegion *  obj, BOOL *  stop) {
        if ([obj.identifier isEqualToString:kRegionMonitorID]) {
            region = obj;
            *stop = YES;
        }
    }];
    return region;
}

- (void)resetRegionMonitorToLocation:(LBLocationRecord*)loc {
    [self clearRegionMonitor];
    
    CLLocationDistance radius = 100.0; // m
    CLCircularRegion *geoRegion = [[CLCircularRegion alloc]
                                   initWithCenter:loc.coordinate
                                   radius:radius
                                   identifier:kRegionMonitorID];
    geoRegion.notifyOnEntry = NO;
    geoRegion.notifyOnExit = YES;
    
    [self.locationManager startMonitoringForRegion:geoRegion];
    
    NSLog(@"setup region monitor");
}

- (BOOL)clearRegionMonitor {
    CLRegion *region = self.currentMonitoredRegion;
    if (region != nil) {
        [self.locationManager stopMonitoringForRegion:region];
        NSLog(@"clear region monitor");
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - CLLocationManager Delegate

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.delegate locationCenter:self didPreparedWithInfo:nil];
    }else{
        [self.delegate locationCenter:self didFailToPrepareWithError:[NSError errorWithDomain:LBLocationCenterErrorDomain code:-1 userInfo:@{@"reason":@"Authorization Failed"}]];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    
    if (self.lastUpdateTime != nil) {
        if ([location.timestamp timeIntervalSinceDate:self.lastUpdateTime] < 10.0) {
            // just update in 10 sec. ignore this event.
            return;
        }
    }
    
    LBLocationRecord *record = [[LBLocationRecord alloc] initWithCLLocation:location
                                                         monitoringType:self.monitoringType];
    
    self.lastUpdateTime = record.timestamp;
    NSLog(@"%@", record);
    
    [self notifyNewRecordAvaliable:record];
    
    [_locationRecords insertObject:record atIndex:0];
    [self notifyInsertAtIndex:0];
    if (self.monitoringType == LBBackgroundMonitoring) {
        // save data in background
//        [self saveData];
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error : %@", error);
}

- (void)locationManager:( CLLocationManager *)manager didExitRegion:( CLRegion *)region {
    if ([region.identifier isEqualToString:kRegionMonitorID]) {
        CLCircularRegion *circularRegion = (CLCircularRegion *) region;
        LBLocationRecord *record = [[LBLocationRecord alloc] initWithCLCoordinate2D:circularRegion.center
                                                                 monitoringType:LBExitRegion];
        [self notifyNewRecordAvaliable:record];
        
        [_locationRecords insertObject:record atIndex:0];
        [self notifyInsertAtIndex:0];
        
        if (self.monitoringType == LBBackgroundMonitoring) {
            // save data in background
//            [self saveData];
        }

        NSLog(@"exit region!");
        [self clearRegionMonitor];
    }
}

- (void)locationManager:( CLLocationManager *)manager didVisit:( CLVisit *)visit {
    LBLocationRecord *record = [[LBLocationRecord alloc] initWithCLCoordinate2D:visit.coordinate
                                                             monitoringType:LBVisitedLocation];
    [self notifyNewRecordAvaliable:record];
    
    [_locationRecords insertObject:record atIndex:0];
    [self notifyInsertAtIndex:0];
    
    if (self.monitoringType == LBBackgroundMonitoring) {
        // save data in background
//        [self saveData];
    }
    
    NSLog(@"visited: %@", record);
}

#pragma mark - Location Data

- (NSString*)datafilePath {
    if (_datafilePath == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        _datafilePath = [documentsDirectory stringByAppendingPathComponent:@"location_data"];
    }
    return _datafilePath;
}

- (NSArray*)locationRecords {
    return _locationRecords;
}

- (BOOL)isDataDirty {
    return _dataDirty;
}


//FIXME: Will be deleted . _ Jason .
- (void)notifyInsertAtIndex:(NSUInteger)index {
    if (!_dataDirty) {
        _dataDirty = YES;
    }
    
    [_delegates forEach:^(id object) {
        id <LBLocationCenterDelegate> delegate = object;
        if ([delegate respondsToSelector:@selector(locationCenter:didInsertRecordAtIndex:)]) {
            [delegate locationCenter:self didInsertRecordAtIndex:index];
        }
    }];
}

- (void)notifyNewRecordAvaliable:(LBLocationRecord *)record
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LBLocationCenterNewLocationAvaliableNotification object:self userInfo:@{LBLocationCenterNewLocationValueKey:[record copy]}];
}

//
//- (void)clearAllData {
//    if (_locationRecords.count > 0) {
//        [_locationRecords removeAllObjects];
//        _dataDirty = YES;
//        NSLog(@"LocationCenter data clear!");
//        [_delegates forEach:^(id object) {
//            id <LBLocationCenterDelegate> delegate = object;
//            if ([delegate respondsToSelector:@selector(locationCenterDidClearAllData:)]) {
//                [delegate locationCenterDidClearAllData:self];
//            }
//        }];
//    }
//}
//
- (void)saveData {
    if (_dataDirty) {
        [NSKeyedArchiver archiveRootObject:_locationRecords toFile:[self datafilePath]];
        _dataDirty = NO;
        NSLog(@"LocationCenter saved %ld records", (unsigned long) _locationRecords.count);
    } else {
        NSLog(@"LocationCenter no record to save");
    }
}

@end
