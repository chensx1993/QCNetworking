//
//  QCService.m
//  QCNetworkTool
//
//  Created by chensx on 2017/9/13.
//  Copyright © 2017年 chensx. All rights reserved.
//

#import "QCService.h"

@interface QCService()

@property (nonatomic, weak, readwrite) id<QCServiceProtocol> child;

@end

@implementation QCService

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(QCServiceProtocol)]) {
            self.child = (id<QCServiceProtocol>)self;
        }
    }
    return self;
}

- (NSString *)urlGeneratingRuleByMethodName:(NSString *)methodName {
    NSString *urlString = nil;
    if ([methodName containsString:@"http"]) {
        return methodName;
    }
    if (self.apiVersion.length != 0) {
        urlString = [NSString stringWithFormat:@"%@/%@/%@", self.apiBaseUrl, self.apiVersion, methodName];
    } else {
        urlString = [NSString stringWithFormat:@"%@/%@", self.apiBaseUrl, methodName];
    }
    return urlString;
}


#pragma mark - getters and setters
- (NSString *)privateKey
{
    return self.child.privateKey;
}

- (NSString *)publicKey
{
    return self.child.publicKey;
}

- (NSString *)apiBaseUrl
{
    return self.child.apiBaseUrl;
}

- (NSString *)apiVersion
{
    return self.child.apiVersion;
}

@end
