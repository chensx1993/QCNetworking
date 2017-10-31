//
//  QCAPIBaseManagerProtocol.h
//  QCNetworkTool
//
//  Created by chensx on 2017/9/14.
//  Copyright © 2017年 chensx. All rights reserved.
//


@class QCAPIBaseManager;
@class QCURLResponse;

/*************************************************************************************************/
/*                                     QCAPIManagerValidator                                     */
/*************************************************************************************************/
//验证器，用于验证API的返回或者调用API的参数是否正确

@protocol QCAPIManagerValidator <NSObject>
@required
/*
 所有的callback数据都应该在这个函数里面进行检查，事实上，到了回调delegate的函数里面是不需要再额外验证返回数据是否为空的。
 因为判断逻辑都在这里做掉了。
 而且本来判断返回数据是否正确的逻辑就应该交给manager去做，不要放到回调到controller的delegate方法里面去做。
 */
- (BOOL)manager:(QCAPIBaseManager *)manager isCorrectWithCallBackData:(NSDictionary *)data;

@optional
- (BOOL)manager:(QCAPIBaseManager *)manager isCorrectWithParamsData:(NSDictionary *)data;
@end


/*
 当产品要求返回数据不正确或者为空的时候显示一套UI，请求超时和网络不通的时候显示另一套UI时，使用这个enum来决定使用哪种UI。（安居客PAD就有这样的需求，sigh～）
 你不应该在回调数据验证函数里面设置这些值，事实上，在任何派生的子类里面你都不应该自己设置manager的这个状态，baseManager已经帮你搞定了。
 强行修改manager的这个状态有可能会造成程序流程的改变，容易造成混乱。
 */
typedef NS_ENUM (NSUInteger, QCAPIManagerErrorType){
    QCAPIManagerErrorTypeDefault,       //没有产生过API请求，这个是manager的默认状态。
    QCAPIManagerErrorTypeSuccess,       //API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    QCAPIManagerErrorTypeNoContent,     //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    QCAPIManagerErrorTypeParamsError,   //参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    QCAPIManagerErrorTypeTimeout,       //请求超时。CTAPIProxy设置的是20秒超时，具体超时时间的设置请自己去看CTAPIProxy的相关代码。
    QCAPIManagerErrorTypeNoNetWork      //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
};

typedef NS_ENUM (NSUInteger, QCAPIManagerRequestType){
    QCAPIManagerRequestTypeGet,
    QCAPIManagerRequestTypePost,
    QCAPIManagerRequestTypePut,
    QCAPIManagerRequestTypeDelete
};


/*************************************************************************************************/
/*                                         QCAPIManager                                          */
/*************************************************************************************************/
/*
 QCAPIBaseManager的派生类必须符合这些protocal
 */
@protocol QCAPIManager <NSObject>

@required
- (NSString *)serviceType;
//- (NSString *)methodName;
- (QCAPIManagerRequestType)requestType;
- (BOOL)shouldCache;

// used for pagable API Managers mainly
@optional
- (void)cleanData;
- (NSDictionary *)reformParams:(NSDictionary *)params;
- (NSInteger)loadDataWithParams:(NSDictionary *)params;
- (BOOL)shouldLoadFromNative;

@end

/*************************************************************************************************/
/*                                    QCAPIManagerInterceptor                                    */
/*************************************************************************************************/
/*
 网络请求拦截器协议方法，通过代理实现
 */
@protocol QCAPIManagerInterceptor <NSObject>

@optional
- (BOOL)manager:(QCAPIBaseManager *)manager beforePerformSuccessWithResponse:(QCURLResponse *)response;
- (void)manager:(QCAPIBaseManager *)manager afterPerformSuccessWithResponse:(QCURLResponse *)response;

- (BOOL)manager:(QCAPIBaseManager *)manager beforePerformFailWithResponse:(QCURLResponse *)response;
- (void)manager:(QCAPIBaseManager *)manager afterPerformFailWithResponse:(QCURLResponse *)response;

- (BOOL)manager:(QCAPIBaseManager *)manager shouldCallAPIWithParams:(NSDictionary *)params;
- (void)manager:(QCAPIBaseManager *)manager afterCallingAPIWithParams:(NSDictionary *)params;

@end
