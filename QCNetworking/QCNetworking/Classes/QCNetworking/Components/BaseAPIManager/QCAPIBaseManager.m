//
//  QCAPIBaseManager.m
//  QCNetworkTool
//
//  Created by chensx on 2017/9/13.
//  Copyright © 2017年 chensx. All rights reserved.
//

#import "QCAPIBaseManager.h"
#import "QCNetworkingConfigurationManager.h"
#import "QCURLResponse.h"
#import "QCApiProxy.h"

#import "QCService.h"
#import "QCServiceFactory.h"


#define QCCallAPI(REQUEST_METHOD, REQUEST_ID)                                                   \
{                                                                                               \
    __weak typeof(self) weakSelf = self;                                                        \
    REQUEST_ID = [[QCApiProxy sharedInstance] call##REQUEST_METHOD##WithParams:params serviceIdentifier:self.child.serviceType methodName:methodName success:^(QCURLResponse *response) {                                         \
        __strong typeof(weakSelf) strongSelf = weakSelf;                                        \
        [strongSelf successedOnCallingAPI:response];                                            \
    } fail:^(QCURLResponse *response) {                                                         \
        __strong typeof(weakSelf) strongSelf = weakSelf;                                        \
        [strongSelf failedOnCallingAPI:response withErrorType:QCAPIManagerErrorTypeDefault];    \
    }];                                                                                         \
    [self.requestIdList addObject:@(REQUEST_ID)];                                               \
}


@interface QCAPIBaseManager ()

@property (nonatomic, strong, readwrite) id fetchedRawData;
@property (nonatomic, assign, readwrite) BOOL isLoading;
@property (nonatomic, assign) BOOL isNativeDataEmpty;

@property (nonatomic, copy, readwrite) NSString *errorMessage;
@property (nonatomic, readwrite) QCAPIManagerErrorType errorType;
@property (nonatomic, strong) NSMutableArray *requestIdList;

@property (nonatomic, copy) void(^success)(QCURLResponse *);
@property (nonatomic, copy) void(^fail)(QCURLResponse *);

@end

@implementation QCAPIBaseManager

#pragma mark - life cycle
- (instancetype)init {
    if (self = [super init]) {
        
        if ([self conformsToProtocol:@protocol(QCAPIManager)]) {
            self.child = (id <QCAPIManager>)self;
        } else {
            self.child = (id <QCAPIManager>)self;
            NSException *exception = [[NSException alloc] initWithName:@"QCAPIBaseManager提示" reason:[NSString stringWithFormat:@"%@没有遵循QCAPIManager协议",self.child] userInfo:nil];
            @throw exception;
        }
    }
    return self;
}


- (void)dealloc {
    [self cancelAllRequests];
    self.requestIdList = nil;
}

#pragma mark - public methods
- (void)cancelAllRequests {
    [[QCApiProxy sharedInstance] cancelRequestWithRequestIDList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}

- (void)cancelRequestWithRequestId:(NSInteger)requestID {
    [self removeRequestIdWithRequestID:requestID];
    [[QCApiProxy sharedInstance] cancelRequestWithRequestID:@(requestID)];
}

#pragma mark - calling api
- (NSInteger)callWithMethodName:(NSString *)methodName params:(NSDictionary *)params success:(void (^)(QCURLResponse *))success fail:(void (^)(QCURLResponse *))fail {
    
    self.success = success;
    self.fail = fail;
    
    NSInteger requestId = 0;
    if ([self shouldCallAPIWithParams:params]) {
        
        //实际网络请求
        if ([self isReachable]) {
            self.isLoading = YES;
            switch (self.child.requestType)
            {
                case QCAPIManagerRequestTypeGet:
                    QCCallAPI(GET, requestId);
                    break;
                case QCAPIManagerRequestTypePost:{
                    __weak typeof(self) weakSelf = self;
                    requestId = [[QCApiProxy sharedInstance] callPOSTWithParams:params serviceIdentifier:self.child.serviceType methodName:methodName success:^(QCURLResponse *response) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        [strongSelf successedOnCallingAPI:response];
                    } fail:^(QCURLResponse *response) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        [strongSelf failedOnCallingAPI:response withErrorType:QCAPIManagerErrorTypeDefault];
                    }];
                    [self.requestIdList addObject:@(requestId)];
                    break;
                }
                case QCAPIManagerRequestTypePut:
                    QCCallAPI(PUT, requestId);
                    break;
                case QCAPIManagerRequestTypeDelete:
                    QCCallAPI(DELETE, requestId);
                    break;
                default:
                    break;
            }
            
            NSMutableDictionary *afterParams = [params mutableCopy];
            afterParams[kCTAPIBaseManagerRequestID] = @(requestId);
            [self afterCallingAPIWithParams:afterParams];
            return requestId;
            
        }else {
            [self failedOnCallingAPI:nil withErrorType:QCAPIManagerErrorTypeNoNetWork];
            return requestId;
        }
        
    } else {
        [self failedOnCallingAPI:nil withErrorType:QCAPIManagerErrorTypeParamsError];
        return requestId;
    }
    
    return requestId;
}

#pragma mark - api callbacks
- (void)successedOnCallingAPI:(QCURLResponse *)response {
    
    NSString *serviceIdentifier = self.child.serviceType;
    QCService *service = [[QCServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    
    self.isLoading = NO;
    self.response = response;
    
    if ([service.child respondsToSelector:@selector(successedOnCallingAPI:)]) {
        [service.child successedOnCallingAPI:response];
    }
    
    if (response.content) {
        self.fetchedRawData = [response.content copy];
    } else {
        self.fetchedRawData = [response.responseData copy];
    }
    [self removeRequestIdWithRequestID:response.requestId];
    if ([self.validator manager:self isCorrectWithCallBackData:response.content]) {
        
        if ([self beforePerformSuccessWithResponse:response]) {
            //成功回调
            if (self.success) {
                self.success(response);
            }
        }
        [self afterPerformSuccessWithResponse:response];
    } else {
        [self failedOnCallingAPI:response withErrorType:QCAPIManagerErrorTypeNoContent];
    }
}

- (void)failedOnCallingAPI:(QCURLResponse *)response withErrorType:(QCAPIManagerErrorType)errorType
{
    NSString *serviceIdentifier = self.child.serviceType;
    QCService *service = [[QCServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    
    self.isLoading = NO;
    self.response = response;
    BOOL needCallBack = YES;
    
    if ([service.child respondsToSelector:@selector(shouldCallBackByFailedOnCallingAPI:)]) {
        needCallBack = [service.child shouldCallBackByFailedOnCallingAPI:response];
    }
    
    //由service决定是否结束回调
    if (!needCallBack) {
        return;
    }
    
    //继续错误的处理
    self.errorType = errorType;
    [self removeRequestIdWithRequestID:response.requestId];
    
    if (response.content) {
        self.fetchedRawData = [response.content copy];
    } else {
        self.fetchedRawData = [response.responseData copy];
    }
    
    if ([self beforePerformFailWithResponse:response]) {
        //失败回调
        if (self.fail) {
            self.fail(response);
        }
    }
    [self afterPerformFailWithResponse:response];
}


#pragma mark - method for interceptor

/*
 拦截器的功能可以由子类通过继承实现，也可以由其它对象实现,两种做法可以共存
 当两种情况共存的时候，子类重载的方法一定要调用一下super
 然后它们的调用顺序是BaseManager会先调用子类重载的实现，再调用外部interceptor的实现
 
 notes:
 正常情况下，拦截器是通过代理的方式实现的，因此可以不需要以下这些代码
 但是为了将来拓展方便，如果在调用拦截器之前manager又希望自己能够先做一些事情，所以这些方法还是需要能够被继承重载的
 所有重载的方法，都要调用一下super,这样才能保证外部interceptor能够被调到
 这就是decorate pattern
 */
- (BOOL)beforePerformSuccessWithResponse:(QCURLResponse *)response
{
    BOOL result = YES;
    
    self.errorType = QCAPIManagerErrorTypeSuccess;
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager: beforePerformSuccessWithResponse:)]) {
        result = [self.interceptor manager:self beforePerformSuccessWithResponse:response];
    }
    return result;
}

- (void)afterPerformSuccessWithResponse:(QCURLResponse *)response
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformSuccessWithResponse:)]) {
        [self.interceptor manager:self afterPerformSuccessWithResponse:response];
    }
}

- (BOOL)beforePerformFailWithResponse:(QCURLResponse *)response
{
    BOOL result = YES;
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforePerformFailWithResponse:)]) {
        result = [self.interceptor manager:self beforePerformFailWithResponse:response];
    }
    return result;
}

- (void)afterPerformFailWithResponse:(QCURLResponse *)response
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformFailWithResponse:)]) {
        [self.interceptor manager:self afterPerformFailWithResponse:response];
    }
}

//只有返回YES才会继续调用API
- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:shouldCallAPIWithParams:)]) {
        return [self.interceptor manager:self shouldCallAPIWithParams:params];
    } else {
        return YES;
    }
}

- (void)afterCallingAPIWithParams:(NSDictionary *)params
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterCallingAPIWithParams:)]) {
        [self.interceptor manager:self afterCallingAPIWithParams:params];
    }
}


#pragma mark - method for child
- (void)cleanData {
    self.fetchedRawData = nil;
    self.errorMessage = nil;
    self.errorType = QCAPIManagerErrorTypeDefault;
}

//如果需要在调用API之前额外添加一些参数，比如pageNumber和pageSize之类的就在这里添加
//子类中覆盖这个函数的时候就不需要调用[super reformParams:params]了
- (NSDictionary *)reformParams:(NSDictionary *)params
{
    IMP childIMP = [self.child methodForSelector:@selector(reformParams:)];
    IMP selfIMP = [self methodForSelector:@selector(reformParams:)];
    
    if (childIMP == selfIMP) {
        return params;
    } else {
        // 如果child是继承得来的，那么这里就不会跑到，会直接跑子类中的IMP。
        // 如果child是另一个对象，就会跑到这里
        NSDictionary *result = nil;
        result = [self.child reformParams:params];
        if (result) {
            return result;
        } else {
            return params;
        }
    }
}

- (BOOL)shouldCache {
    return [QCNetworkingConfigurationManager sharedInstance].shouldCache;
}

#pragma mark - private methods
- (void)removeRequestIdWithRequestID:(NSInteger)requestId
{
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedRequestId in self.requestIdList) {
        if ([storedRequestId integerValue] == requestId) {
            requestIDToRemove = storedRequestId;
        }
    }
    if (requestIDToRemove) {
        [self.requestIdList removeObject:requestIDToRemove];
    }
}

#pragma mark - getters and setters
- (NSMutableArray *)requestIdList {
    if (_requestIdList == nil) {
        _requestIdList = [[NSMutableArray alloc] init];
    }
    return _requestIdList;
}


- (BOOL)isReachable {
    BOOL isReachability = [QCNetworkingConfigurationManager sharedInstance].isReachable;
    if (!isReachability) {
        self.errorType = QCAPIManagerErrorTypeNoNetWork;
    }
    return isReachability;
}

- (BOOL)isLoading {
    if (self.requestIdList.count == 0) {
        _isLoading = NO;
    }
    return _isLoading;
}

@end

