//
//  NSDictionary+QCNetworking.h
//  Pods
//
//  Created by chensx on 2017/9/14.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (QCNetworking)

- (NSString *)QC_urlParamsStringSignature:(BOOL)isForSignature;
- (NSString *)QC_jsonString;
- (NSArray *)QC_transformedUrlParamsArraySignature:(BOOL)isForSignature;

@end
