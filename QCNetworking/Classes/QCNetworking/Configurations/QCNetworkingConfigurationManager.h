//
//  QCNetworkingConfigurationManager.h
//  QCNetworkTool
//
//  Created by chensx on 2017/9/13.
//  Copyright © 2017年 chensx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCNetworkingConfigurationManager : NSObject

+ (instancetype)sharedInstance;

/**
 网络是否可用
 */
@property (nonatomic, assign, readonly) BOOL isReachable;

/**
 是否缓存
 */
@property (nonatomic, assign) BOOL shouldCache;

/**
 超时时间
 */
@property (nonatomic, assign) NSTimeInterval apiNetworkingTimeoutSeconds;

/**
 多长时间过后清除缓存
 */
@property (nonatomic, assign) NSTimeInterval cacheOutdateTimeSeconds;

/**
 缓存最大条数
 */
@property (nonatomic, assign) NSInteger cacheCountLimit;

//默认值为NO，当值为YES时，HTTP请求除了GET请求，其他的请求都会将参数放到HTTPBody中，如下所示
//request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestParams options:0 error:NULL];
@property (nonatomic, assign) BOOL shouldSetParamsInHTTPBodyButGET;

@end
