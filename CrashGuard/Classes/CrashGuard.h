//
//  CrashGuard.h
//  Pods
//
//  Created by Hui Li on 2017/7/9.
//
//

#import <Foundation/Foundation.h>

#ifdef DEBUG

#define  CrashGuardLog(...) NSLog(@"%@",[NSString stringWithFormat:__VA_ARGS__])

#else

#define CrashGuardLog(...)
#endif

@interface CrashGuard : NSObject

+ (void)startGuard;

@end
