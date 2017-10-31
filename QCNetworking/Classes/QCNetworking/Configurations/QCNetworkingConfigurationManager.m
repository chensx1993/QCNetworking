//
//  QCNetworkingConfigurationManager.m
//  QCNetworkTool
//
//  Created by chensx on 2017/9/13.
//  Copyright © 2017年 chensx. All rights reserved.
//

#import "QCNetworkingConfigurationManager.h"
#import "AFNetworking.h"

@implementation QCNetworkingConfigurationManager

+ (instancetype)sharedInstance {
    static QCNetworkingConfigurationManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[QCNetworkingConfigurationManager alloc] init];
        sharedInstance.shouldCache = YES;
        sharedInstance.apiNetworkingTimeoutSeconds = 20.0f;
        sharedInstance.cacheOutdateTimeSeconds = 300;
        sharedInstance.cacheCountLimit = 1000;
        sharedInstance.shouldSetParamsInHTTPBodyButGET = NO;
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    });
    return sharedInstance;
}

- (BOOL)isReachable {
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

@end
