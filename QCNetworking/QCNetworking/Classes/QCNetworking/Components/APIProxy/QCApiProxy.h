//
//  QCApiProxy.h
//  QCNetworkTool
//
//  Created by chensx on 2017/9/13.
//  Copyright © 2017年 chensx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCURLResponse.h"

typedef void(^QCCallback)(QCURLResponse *response);

@interface QCApiProxy : NSObject

+ (instancetype)sharedInstance;

- (NSInteger)callGETWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)servieIdentifier methodName:(NSString *)methodName success:(QCCallback)success fail:(QCCallback)fail;
- (NSInteger)callPOSTWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)servieIdentifier methodName:(NSString *)methodName success:(QCCallback)success fail:(QCCallback)fail;
- (NSInteger)callPUTWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)servieIdentifier methodName:(NSString *)methodName success:(QCCallback)success fail:(QCCallback)fail;
- (NSInteger)callDELETEWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)servieIdentifier methodName:(NSString *)methodName success:(QCCallback)success fail:(QCCallback)fail;


- (NSNumber *)callApiWithRequest:(NSURLRequest *)request success:(QCCallback)success fail:(QCCallback)fail;
- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

@end
