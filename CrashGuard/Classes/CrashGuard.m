//
//  CrashGuard.m
//  Pods
//
//  Created by Hui Li on 2017/7/9.
//
//

#import "CrashGuard.h"
#import "NSArray+CrashGuard.h"
#import "NSObject+CrashGuard.h"

@implementation CrashGuard

+ (void)startGuard {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [NSObject startGuard];
        [NSArray startGuard];
    });
    
}

@end
