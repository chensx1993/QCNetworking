//
//  QCAPIBaseManager.h
//  QCNetworkTool
//
//  Created by chensx on 2017/9/13.
//  Copyright © 2017年 chensx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCAPIBaseManagerProtocol.h"

// 在调用成功之后的params字典里面，用这个key可以取出requestID
static NSString * const kCTAPIBaseManagerRequestID = @"kCTAPIBaseManagerRequestID";

@interface QCAPIBaseManager : NSObject


@property (nonatomic, weak) NSObject<QCAPIManager> *child;

/**
 验证参数或者返回数据是否正确代理
 */
@property (nonatomic, weak) id<QCAPIManagerValidator> validator;
/**
 拦截器代理
 */
@property (nonatomic, weak) id<QCAPIManagerInterceptor> interceptor;

/**
 网络请求状态
 */
@property (nonatomic, readonly) QCAPIManagerErrorType errorType;

/**
 返回数据
 */
@property (nonatomic, strong) QCURLResponse *response;

/**
 是否正在下载
 */
@property (nonatomic, assign, readonly) BOOL isLoading;

- (NSInteger)callWithMethodName:(NSString *)methodName params:(NSDictionary *)params  success:(void(^)(QCURLResponse *response))success fail:(void(^)(QCURLResponse *response))fail;

//取消网络请求方法
- (void)cancelAllRequests;
- (void)cancelRequestWithRequestId:(NSInteger)requestID;

// 拦截器方法，继承之后需要调用一下super
- (BOOL)beforePerformSuccessWithResponse:(QCURLResponse *)response;
- (void)afterPerformSuccessWithResponse:(QCURLResponse *)response;

- (BOOL)beforePerformFailWithResponse:(QCURLResponse *)response;
- (void)afterPerformFailWithResponse:(QCURLResponse *)response;

- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params;
- (void)afterCallingAPIWithParams:(NSDictionary *)params;

@end
