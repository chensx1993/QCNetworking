//
//  QCURLResponse.m
//  QCNetworkTool
//
//  Created by chensx on 2017/9/13.
//  Copyright © 2017年 chensx. All rights reserved.
//

#import "QCURLResponse.h"
#import "NSURLRequest+QCNetworking.h"
#import "NSObject+QCNetworking.h"
#import "NSDictionary+QCNetworking.h"

@interface QCURLResponse ()

@property (nonatomic, assign, readwrite) QCURLResponseStatus status;
@property (nonatomic, copy, readwrite) NSString *contentString;
@property (nonatomic, copy, readwrite) id content;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, copy, readwrite) NSString *requestString;
@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, assign, readwrite) BOOL isCache;
@property (nonatomic, strong, readwrite) NSError *error;

@end

@implementation QCURLResponse

#pragma mark - life cycle
- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData status:(QCURLResponseStatus)status {
    self = [super init];
    if (self) {
        self.contentString = responseString;
        self.content = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        self.status = status;
        self.requestId = [requestId integerValue];
        self.request = request;
        self.responseData = responseData;
        self.requestParams = request.requestParams;
        self.requestString = [NSString stringWithFormat:@"%@?%@",request.URL.absoluteString, [request.requestParams QC_urlParamsStringSignature:YES]];
        self.isCache = NO;
        self.error = nil;
    }
    return self;
}

- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData error:(NSError *)error {
    self = [super init];
    if (self) {
        self.contentString = [responseString QC_defaultValue:@""];
        self.status = [self responseStatusWithError:error];
        self.requestId = [requestId integerValue];
        self.request = request;
        self.responseData = responseData;
        self.requestParams = request.requestParams;
        self.requestString = [NSString stringWithFormat:@"%@?%@",request.URL.absoluteString, [request.requestParams QC_urlParamsStringSignature:YES]];
        self.isCache = NO;
        self.error = error;
        if (responseData) {
            self.content = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        } else {
            self.content = nil;
        }
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        self.contentString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.status = [self responseStatusWithError:nil];
        self.requestId = 0;
        self.request = nil;
        self.responseData = [data copy];
        self.content = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
        self.isCache = YES;
    }
    return self;
}

#pragma mark - private methods
- (QCURLResponseStatus)responseStatusWithError:(NSError *)error {
    if (error) {
        QCURLResponseStatus result = QCURLResponseStatusErrorNoNetwork;
        
        // 除了超时以外，所有错误都当成是无网络
        if (error.code == NSURLErrorTimedOut) {
            result = QCURLResponseStatusErrorTimeout;
        }
        return result;
    } else {
        return QCURLResponseStatusSuccess;
    }
}

@end
