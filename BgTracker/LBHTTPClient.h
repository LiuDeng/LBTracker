//
//  LBHTTPClient.h
//  LBTracker
//
//  Created by Jason on 15/7/25.
//  Copyright (c) 2015年 LB. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>

@class LBLocationRecord;

@interface LBHTTPClient : AFHTTPRequestOperationManager

+ (LBHTTPClient *)sharedClient;


+ (void)uploadLocationRecord:(LBLocationRecord *)locationRecord
                    onSuccess:(void (^)(id responseObject, NSDictionary *info))successBlock
                    onFailure:(void (^)(NSError *error, NSDictionary *info))failedBlock;


+ (void)uploadSensorRecords:(NSArray *)sensorRecords
                  onSuccess:(void (^)(id responseObject, NSDictionary *info))successBlock
                  onFailure:(void (^)(NSError *error, NSDictionary *info))failedBlock;



@end
