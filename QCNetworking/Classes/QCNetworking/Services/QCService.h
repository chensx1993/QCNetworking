//
//  QCService.h
//  QCNetworkTool
//
//  Created by chensx on 2017/9/13.
//  Copyright © 2017年 chensx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCURLResponse.h"

@protocol QCServiceProtocol <NSObject>

@property (nonatomic, readonly) NSString *apiBaseUrl;

@property (nonatomic, readonly) NSString *apiVersion;

@property (nonatomic, readonly) NSString *publicKey;

@property (nonatomic, readonly) NSString *privateKey;

@optional

//为某些Service需要拼凑额外字段到URL处
- (NSDictionary *)extraParmas;

//参数加密方法, 移到外面，方便单独生成静态库
- (NSDictionary *)handleAllParmas:(NSDictionary *)params;

//为某些Service需要拼凑额外的HTTPToken，如accessToken
- (NSDictionary *)extraHttpHeadParmasWithMethodName:(NSString *)method;

//url拼接规则
- (NSString *)urlGeneratingRuleByMethodName:(NSString *)method;

//请求成功拦截器：集中处理请求成功后需要的操作
- (void)successedOnCallingAPI:(QCURLResponse *)response;

//请求失败拦截器：集中处理Service错误问题，比如token失效要抛通知等
- (BOOL)shouldCallBackByFailedOnCallingAPI:(QCURLResponse *)response;

@end

#pragma mark - QCService
@interface QCService : NSObject


@property (nonatomic, strong, readonly) NSString *publicKey;
@property (nonatomic, strong, readonly) NSString *privateKey;
@property (nonatomic, strong, readonly) NSString *apiBaseUrl;
@property (nonatomic, strong, readonly) NSString *apiVersion;

@property (nonatomic, weak, readonly) id<QCServiceProtocol> child;

/*
 * 因为考虑到每家公司的拼凑逻辑都有或多或少不同，
 * 如有的公司为http://abc.com/v2/api/login或者http://v2.abc.com/api/login
 * 所以将默认的方式，有versioin时，则为http://abc.com/v2/api/login
 * 否则，则为http://abc.com/v2/api/login
 */
- (NSString *)urlGeneratingRuleByMethodName:(NSString *)method;

@end
