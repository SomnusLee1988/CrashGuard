//
//  NSObject+CrashGuard.m
//  Pods
//
//  Created by Hui Li on 2017/7/9.
//
//

#import "NSObject+CrashGuard.h"
#import <objc/runtime.h>
#import "CrashGuard.h"

@implementation NSObject (CrashGuard)

+ (void)startGuard {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //forwardingTargetForSelector
        [self exchangeInstanceMethod:[self class] method1Sel:@selector(forwardingTargetForSelector:) method2Sel:@selector(guardCrashForwardingTargetForSelector:)];
        
    });
    
}

- (id)guardCrashForwardingTargetForSelector:(SEL)aSelector
{
    
    NSString *selectorStr = NSStringFromSelector(aSelector);
    // 做一次类的判断，只对 UIResponder 和 NSNull 有效
    if ([[self class] isSubclassOfClass: NSClassFromString(@"UIResponder")] ||
        [self isKindOfClass: [NSNull class]])
    {
        CrashGuardLog(@"CrashGuard: -[%@ %@]", [self class], selectorStr);
        CrashGuardLog(@"CrashGuard: unrecognized selector \"%@\" sent to instance: %p", selectorStr, self);
        // 查看调用栈
        CrashGuardLog(@"CrashGuard: call stack: %@", [NSThread callStackSymbols]);
        
        // 对保护器插入该方法的实现
        Class protectorCls = NSClassFromString(@"UnrecognizedSELGuarder");
        if (!protectorCls)
        {
            protectorCls = objc_allocateClassPair([NSObject class], "UnrecognizedSELGuarder", 0);
            objc_registerClassPair(protectorCls);
        }
        
        class_addMethod(protectorCls, aSelector, [self safeImplementation:aSelector],
                        [selectorStr UTF8String]);
        
        Class Protector = [protectorCls class];
        id instance = [[Protector alloc] init];
        
        return instance;
    }
    else
    {
        return nil;
    }
}

- (IMP)safeImplementation:(SEL)aSelector
{
    
    IMP imp = imp_implementationWithBlock(^() {
        CrashGuardLog(@"CrashGuard: %@ Done", NSStringFromSelector(aSelector));
    });
    
    return imp;
}

/**
 *  类方法的交换
 *
 *  @param anClass    哪个类
 *  @param method1Sel 方法1
 *  @param method2Sel 方法2
 */
+ (void)exchangeClassMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel {
    Method method1 = class_getClassMethod(anClass, method1Sel);
    Method method2 = class_getClassMethod(anClass, method2Sel);
    method_exchangeImplementations(method1, method2);
}


/**
 *  对象方法的交换
 *
 *  @param anClass    哪个类
 *  @param method1Sel 方法1(原本的方法)
 *  @param method2Sel 方法2(要替换成的方法)
 */
+ (void)exchangeInstanceMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel {
    
    
    Method originalMethod = class_getInstanceMethod(anClass, method1Sel);
    Method swizzledMethod = class_getInstanceMethod(anClass, method2Sel);
    
    BOOL didAddMethod =
    class_addMethod(anClass,
                    method1Sel,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(anClass,
                            method2Sel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
}

@end
