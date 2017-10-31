//
//  NSObject+QCNetworking.m
//  QCNetworkTool
//
//  Created by chensx on 2017/9/13.
//  Copyright © 2017年 chensx. All rights reserved.
//

#import "NSObject+QCNetworking.h"

@implementation NSObject (QCNetworking)

- (id)QC_defaultValue:(id)defaultData {
    if (![defaultData isKindOfClass:[self class]]) {
        return defaultData;
    }
    
    if ([self QC_isEmptyObject]) {
        return defaultData;
    }
    
    return self;
}

- (BOOL)QC_isEmptyObject {
    if ([self isEqual:[NSNull null]]) {
        return YES;
    }
    
    if ([self isKindOfClass:[NSString class]]) {
        if ([(NSString *)self length] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)self count] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        if ([(NSDictionary *)self count] == 0) {
            return YES;
        }
    }
    
    return NO;
}

@end
