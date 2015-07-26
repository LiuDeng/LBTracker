//
//  LBLocationShareModel.m
//  BgTracker
//
//  Created by Jason on 15/7/27.
//  Copyright (c) 2015年 Gong Zhang. All rights reserved.
//

#import "LBLocationShareModel.h"

@implementation LBLocationShareModel

//Class method to make sure the share model is synch across the app
+ (id)sharedModel
{
    static id sharedMyModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyModel = [[self alloc] init];
    });
    return sharedMyModel;
}


@end
