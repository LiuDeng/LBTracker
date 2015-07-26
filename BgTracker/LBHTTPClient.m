//
//  LBHTTPClient.m
//  LBTracker
//
//  Created by Jason on 15/7/25.
//  Copyright (c) 2015年 LB. All rights reserved.
//

#import "LBHTTPClient.h"
#import "LBRequstSerializer.h"
#import "LBInstallation.h"
#import "LBLocationRecord.h"
#import "LBSenserRecord.h"

static NSString *const kLBSenzLeancloudHostURlString  = @"https://api.leancloud.cn";


typedef void(^LBHTTPClientUploadSuccessBlock)(id reponseObject, NSDictionary *info);
typedef void(^LBHTTPClientFailureBlock)(id reponseObject, NSDictionary *info);


@interface LBHTTPClient ()

@property (nonatomic, copy) LBHTTPClientUploadSuccessBlock lusBlock;
@property (nonatomic, copy) LBHTTPClientFailureBlock lufBlock;
@property (nonatomic, copy) LBHTTPClientUploadSuccessBlock susBlock;
@property (nonatomic, copy) LBHTTPClientFailureBlock sufBlock;

@end


@implementation LBHTTPClient

+ (LBHTTPClient *)sharedClient
{
    if (![LBInstallation installationAvaliable]) {
        return nil;
    }
    return [self leancloudClientWithInstallation:[LBInstallation sharedInstance]];
}

+ (LBHTTPClient *)leancloudClientWithInstallation:(LBInstallation *)installation;
{
    static LBHTTPClient *__sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:kLBSenzLeancloudHostURlString]];
        __sharedManager.requestSerializer = [LBLeancloudRequestSerializer leancloudSerializerWithInstallation:installation];
        
    });
    return __sharedManager;
}


#pragma mark - Upload 


+ (void)uploadLocationRecord:(LBLocationRecord *)locationRecord
                   onSuccess:(void (^)(id responseObject, NSDictionary *info))successBlock
                   onFailure:(void (^)(NSError *error, NSDictionary *info))failedBlock;

{
    [[self sharedClient] uploadLocationRecord:locationRecord onSuccess:successBlock onFailure:failedBlock];
}

/*
 
 curl -X POST \
 -H "X-AVOSCloud-Application-Id: 9ra69chz8rbbl77mlplnl4l2pxyaclm612khhytztl8b1f9o" \
 -H "X-AVOSCloud-Application-Key: 1zohz2ihxp9dhqamhfpeaer8nh1ewqd9uephe9ztvkka544b" \
 -H "Content-Type: application/json" \
 -d '{"timestamp":14020304000,"installation": {"__type":"Pointer","className":"_Installation",
 "objectId":"l68QQ3Ownwra3HYgWvDJLDW7Hfje7MBh"},"type":"location","source": "baidu.location_sdk",
 "locationRadius": 60.479766845703125,"location":{"__type":"GeoPoint","latitude":1,"longitude":2}}'  \
 https://api.leancloud.cn/1.1/classes/Log

 
 */
- (void)uploadLocationRecord:(LBLocationRecord *)locationRecord
                   onSuccess:(void (^)(id responseObject, NSDictionary *info))successBlock
                   onFailure:(void (^)(NSError *error, NSDictionary *info))failedBlock;

{
    self.lusBlock = successBlock;
    self.lufBlock = failedBlock;
    
    NSDictionary *param = @{@"timestamp":@([locationRecord.timestamp timeIntervalSince1970]),
                            @"type":@"location",
                            @"source":@"internal",
                            @"locationRadius":@(locationRecord.horizontalAccuracy),
                            @"location":[locationRecord JSONRepresentation]};
    
    [self POST:@"1.1/classes/Log"
    parameters:param
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"success ");
    }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"fail");
    }];
    
}



+ (void)uploadSensorRecords:(NSArray *)sensorRecords
                  onSuccess:(void (^)(id responseObject, NSDictionary *info))successBlock
                  onFailure:(void (^)(NSError *error, NSDictionary *info))failedBlock;
{
    [[self sharedClient] uploadSensorRecords:sensorRecords
                                   onSuccess:successBlock
                                   onFailure:failedBlock];

}


/*
 
 curl -X POST   -H "X-AVOSCloud-Application-Id: 9ra69chz8rbbl77mlplnl4l2pxyaclm612khhytztl8b1f9o"   -H "X-AVOSCloud-Application-Key: 1zohz2ihxp9dhqamhfpeaer8nh1ewqd9uephe9ztvkka544b"   -H "Content-Type: application/json"   -d '{"timestamp":14020304000,"installation":{"__type":"Pointer",
 "className":"_Installation",
 "objectId":"l68QQ3Ownwra3HYgWvDJLDW7Hfje7MBh"} ,"type":"sensor","value":{ "events": [{"timestamp":2874573193298,"accuracy": 2,"sensorName": "acc","values": [-7.8747406005859375,5.423065185546875,2.5889434814453125]}]}}'    https://api.leancloud.cn/1.1/classes/Log
 
 */
- (void)uploadSensorRecords:(NSArray *)sensorRecords
                  onSuccess:(void (^)(id responseObject, NSDictionary *info))successBlock
                  onFailure:(void (^)(NSError *error, NSDictionary *info))failedBlock;
{
    self.susBlock = successBlock;
    self.sufBlock = failedBlock;
    
    NSMutableArray *JSONArray = [NSMutableArray arrayWithCapacity:[sensorRecords count]];
    [sensorRecords enumerateObjectsUsingBlock:^(LBSenserRecord* obj, NSUInteger idx, BOOL *stop) {
        [JSONArray addObject:[obj JSONRepresentation]];
    }];
    
    NSDictionary *param = @{@"timestamp":@([[NSDate date] timeIntervalSince1970]),
                            @"type":@"sensor",
                            @"value":@{
                                    @"events":JSONArray
                                    }};
    [self POST:@"1.1/classes/Log"
    parameters:param
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"success ");
       }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"fail");
       }];

}








@end
