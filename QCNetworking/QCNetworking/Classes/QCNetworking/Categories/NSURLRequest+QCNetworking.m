//
//  NSURLRequest+QCNetworking.m
//  QCNetworkTool
//
//  Created by chensx on 2017/9/13.
//  Copyright © 2017年 chensx. All rights reserved.
//

#import "NSURLRequest+QCNetworking.h"
#import <objc/runtime.h>

static void *QCNetworkingRequestParams;

@implementation NSURLRequest (QCNetworking)

- (void)setRequestParams:(NSDictionary *)requestParams {
    objc_setAssociatedObject(self, &QCNetworkingRequestParams, requestParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)requestParams {
    return objc_getAssociatedObject(self, &QCNetworkingRequestParams);
}

@end
