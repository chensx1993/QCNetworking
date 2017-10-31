//
//  QCRequestGenerator.m
//  QCNetworkTool
//
//  Created by chensx on 2017/9/13.
//  Copyright © 2017年 chensx. All rights reserved.
//

#import "QCRequestGenerator.h"
#import "QCSignatureGenerator.h"
#import "QCNetworkingConfigurationManager.h"
#import "NSURLRequest+QCNetworking.h"
//Service
#import "QCService.h"
#import "QCServiceFactory.h"

//there part
#import "AFNetworking.h"

@interface QCRequestGenerator()

@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;

@end

@implementation QCRequestGenerator

#pragma mark - public methods
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static QCRequestGenerator *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[QCRequestGenerator alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    
    self = [super init];
    [self initialRequestGenerator];
    return self;
}

- (void)initialRequestGenerator {
    
    _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
    _httpRequestSerializer.timeoutInterval = [QCNetworkingConfigurationManager sharedInstance].apiNetworkingTimeoutSeconds;
    _httpRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    
}

- (NSURLRequest *)generateGETRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName
{
    return [self generateRequestWithServiceIdentifier:serviceIdentifier requestParams:requestParams methodName:methodName requestWithMethod:@"GET"];
}

- (NSURLRequest *)generatePOSTRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName
{
    return [self generateRequestWithServiceIdentifier:serviceIdentifier requestParams:requestParams methodName:methodName requestWithMethod:@"POST"];
}

- (NSURLRequest *)generatePutRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName
{
    return [self generateRequestWithServiceIdentifier:serviceIdentifier requestParams:requestParams methodName:methodName requestWithMethod:@"PUT"];
}

- (NSURLRequest *)generateDeleteRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName
{
    return [self generateRequestWithServiceIdentifier:serviceIdentifier requestParams:requestParams methodName:methodName requestWithMethod:@"DELETE"];
}

- (NSURLRequest *)generateRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName requestWithMethod:(NSString *)method {
    QCService *service = [[QCServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [service urlGeneratingRuleByMethodName:methodName];
    
    NSDictionary *totalRequestParams = [self totalRequestParamsByService:service requestParams:requestParams];
    
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:method URLString:urlString parameters:totalRequestParams error:NULL];
    
    if (![method isEqualToString:@"GET"] && [QCNetworkingConfigurationManager sharedInstance].shouldSetParamsInHTTPBodyButGET) {
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestParams options:0 error:NULL];
    }
    
    if ([service.child respondsToSelector:@selector(extraHttpHeadParmasWithMethodName:)]) {
        NSDictionary *dict = [service.child extraHttpHeadParmasWithMethodName:methodName];
        if (dict) {
            [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [request setValue:obj forHTTPHeaderField:key];
            }];
        }
    }
    
    request.requestParams = totalRequestParams;
    return request;
}


#pragma mark - private method
//根据Service拼接额外参数
- (NSDictionary *)totalRequestParamsByService:(QCService *)service requestParams:(NSDictionary *)requestParams {
    NSMutableDictionary *totalRequestParams = [NSMutableDictionary dictionaryWithDictionary:requestParams];
    
    if ([service.child respondsToSelector:@selector(extraParmas)]) {
        if ([service.child extraParmas]) {
            [[service.child extraParmas] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [totalRequestParams setObject:obj forKey:key];
            }];
        }
    }
    if ([service.child respondsToSelector:@selector(handleAllParmas:)]) {
        totalRequestParams = [[service.child handleAllParmas:totalRequestParams] mutableCopy];
    }
    return [totalRequestParams copy];
}

@end
