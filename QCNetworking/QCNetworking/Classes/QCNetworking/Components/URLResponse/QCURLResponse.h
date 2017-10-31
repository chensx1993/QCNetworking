//
//  QCURLResponse.h
//  QCNetworkTool
//
//  Created by chensx on 2017/9/13.
//  Copyright © 2017年 chensx. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QCURLResponseStatus) {
    QCURLResponseStatusSuccess,
    QCURLResponseStatusErrorTimeout,
    QCURLResponseStatusErrorNoNetwork
};

@interface QCURLResponse : NSObject

/**
 网络请求数据状态
 */
@property (nonatomic, assign, readonly) QCURLResponseStatus status;

/**
 返回数据：字符串
 */
@property (nonatomic, copy, readonly) NSString *contentString;
/**
 返回数据: data
 */
@property (nonatomic, copy, readonly) NSData *responseData;
/**
 返回数据: json
 */
@property (nonatomic, copy, readonly) id content;

@property (nonatomic, copy) NSDictionary *requestParams;
@property (nonatomic, copy, readonly) NSString *requestString;
@property (nonatomic, copy, readonly) NSURLRequest *request;
@property (nonatomic, assign, readonly) NSInteger requestId;
@property (nonatomic, strong, readonly) NSError *error;

@property (nonatomic, assign, readonly) BOOL isCache;

- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData status:(QCURLResponseStatus)status;
- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData error:(NSError *)error;

// 使用initWithData的response，它的isCache是YES，上面两个函数生成的response的isCache是NO
- (instancetype)initWithData:(NSData *)data;

@end
