//
//  NSObject+CrashGuard.h
//  Pods
//
//  Created by Hui Li on 2017/7/9.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (CrashGuard)

+ (void)startGuard;

+ (void)exchangeClassMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel;

+ (void)exchangeInstanceMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel;

@end
