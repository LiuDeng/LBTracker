//
//  LBHTTPClient.h
//  LBTracker
//
//  Created by Jason on 15/7/25.
//  Copyright (c) 2015年 LB. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>

@class LBLocationRecord;
@class LBHTTPClient;

@protocol LBHTTPClientDelegate <NSObject>

- (void)HTTPClient:(LBHTTPClient *)client
DidInitializedWithInfo:(NSDictionary *)info;

- (void)HTTPClientDidFailToInitializeWithError:(NSError *)error;

@end


@interface LBHTTPClient : AFHTTPRequestOperationManager

@property (nonatomic, weak) id<LBHTTPClientDelegate> delegate;

+ (LBHTTPClient *)sharedClient;

- (void)initializeClientWithDelegate:(id<LBHTTPClientDelegate>)delegate;

+ (void)uploadLocationRecord:(LBLocationRecord *)locationRecord
                    onSuccess:(void (^)(id responseObject, NSDictionary *info))successBlock
                    onFailure:(void (^)(NSError *error, NSDictionary *info))failedBlock;


+ (void)uploadSensorRecords:(NSArray *)sensorRecords
                  onSuccess:(void (^)(id responseObject, NSDictionary *info))successBlock
                  onFailure:(void (^)(NSError *error, NSDictionary *info))failedBlock;


@end
