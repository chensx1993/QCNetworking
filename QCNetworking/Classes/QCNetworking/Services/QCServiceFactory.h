//
//  QCServiceFactory.h
//  QCNetworkTool
//
//  Created by chensx on 2017/9/13.
//  Copyright © 2017年 chensx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCService.h"

@protocol QCServiceFactoryDataSource <NSObject>

/*
 * key为service的Identifier
 * value为service的Class的字符串
 */
- (NSDictionary<NSString *,NSString *> *)servicesKindsOfServiceFactory;

@end

@interface QCServiceFactory : NSObject

@property (nonatomic, weak) id<QCServiceFactoryDataSource> dataSource;

+ (instancetype)sharedInstance;
- (QCService<QCServiceProtocol> *)serviceWithIdentifier:(NSString *)identifier;

@end
