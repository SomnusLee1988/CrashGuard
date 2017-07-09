//
//  NSArray+CrashGuard.m
//  Pods
//
//  Created by Hui Li on 2017/7/9.
//
//

#import "NSArray+CrashGuard.h"
#import "NSObject+CrashGuard.h"
#import "CrashGuard.h"

@implementation NSArray (CrashGuard)

+ (void)startGuard {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //instance array method exchange
        [self exchangeClassMethod:[self class] method1Sel:@selector(arrayWithObjects:count:) method2Sel:@selector(guardCrashArrayWithObjects:count:)];
        
        Class __NSArray = NSClassFromString(@"NSArray");
        Class __NSArrayI = NSClassFromString(@"__NSArrayI");
        Class __NSSingleObjectArrayI = NSClassFromString(@"__NSSingleObjectArrayI");
        Class __NSArray0 = NSClassFromString(@"__NSArray0");
        
        
        //objectsAtIndexes:
        [self exchangeInstanceMethod:__NSArray method1Sel:@selector(objectsAtIndexes:) method2Sel:@selector(guardCrashObjectsAtIndexes:)];
        
        
        //objectAtIndex:
        
        [self exchangeInstanceMethod:__NSArrayI method1Sel:@selector(objectAtIndex:) method2Sel:@selector(__NSArrayIGuardCrashObjectAtIndex:)];
        
        [self exchangeInstanceMethod:__NSSingleObjectArrayI method1Sel:@selector(objectAtIndex:) method2Sel:@selector(__NSSingleObjectArrayIGuardCrashObjectAtIndex:)];
        
        [self exchangeInstanceMethod:__NSArray0 method1Sel:@selector(objectAtIndex:) method2Sel:@selector(__NSArray0GuardCrashObjectAtIndex:)];
        
    });
    
}

#pragma mark - instance array


+ (instancetype)guardCrashArrayWithObjects:(const id  _Nonnull __unsafe_unretained *)objects count:(NSUInteger)cnt {
    
    id instance = nil;
    
    @try {
        instance = [self guardCrashArrayWithObjects:objects count:cnt];
    }
    @catch (NSException *exception) {
        
        CrashGuardLog(@"insert nil to array");
        
        //以下是对错误数据的处理，把为nil的数据去掉,然后初始化数组
        NSInteger newObjsIndex = 0;
        id  _Nonnull __unsafe_unretained newObjects[cnt];
        
        for (int i = 0; i < cnt; i++) {
            if (objects[i] != nil) {
                newObjects[newObjsIndex] = objects[i];
                newObjsIndex++;
            }
        }
        instance = [self guardCrashArrayWithObjects:newObjects count:newObjsIndex];
    }
    @finally {
        return instance;
    }
}


//=================================================================
//                       objectsAtIndexes:
//=================================================================
#pragma mark - objectsAtIndexes:

- (NSArray *)guardCrashObjectsAtIndexes:(NSIndexSet *)indexes {
    
    if (indexes.lastIndex > self.count) {
        return nil;
    }
    
    return [self guardCrashObjectsAtIndexes:indexes];
}

#pragma mark - objectAtIndex:

//__NSArrayI  objectAtIndex:
- (id)__NSArrayIGuardCrashObjectAtIndex:(NSUInteger)index {
    
    if (index >= self.count) {
        return nil;
    }
    
    id value = [self __NSArrayIGuardCrashObjectAtIndex:index];
    
    if (value == [NSNull null]) {
        return nil;
    }
    
    return value;
}



//__NSSingleObjectArrayI objectAtIndex:
- (id)__NSSingleObjectArrayIGuardCrashObjectAtIndex:(NSUInteger)index {
    
    if (index >= self.count) {
        return nil;
    }
    
    id value = [self __NSSingleObjectArrayIGuardCrashObjectAtIndex:index];
    
    if (value == [NSNull null]) {
        return nil;
    }
    
    return value;
}

//__NSArray0 objectAtIndex:
- (id)__NSArray0GuardCrashObjectAtIndex:(NSUInteger)index {
    
    if (index >= self.count) {
        return nil;
    }
    
    id value = [self __NSArray0GuardCrashObjectAtIndex:index];
    
    if (value == [NSNull null]) {
        return nil;
    }
    
    return value;
}

@end
