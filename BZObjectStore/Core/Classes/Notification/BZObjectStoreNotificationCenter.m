//
// The MIT License (MIT)
//
// Copyright (c) 2014 BZObjectStore
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "BZObjectStoreNotificationCenter.h"
#import "BZObjectStore.h"
#import "NSObject+BZObjectStore.h"
#import "NSObject+BZObjectStoreObserver.h"

@implementation BZObjectStoreNotificationCenter

- (void)postOSNotification:(NSObject*)object notificationType:(BZObjectStoreNotificationType)notificationType
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:object forKey:@"object"];
    NSString *name = [self nameWithObject:object notificationType:notificationType];
    NSNotification *notification = [NSNotification notificationWithName:name object:nil userInfo:dic];
    [self postNotification:notification];
}

- (void)addOSObserver:(id)target selector:(SEL)selector object:(NSObject*)object notificationType:(BZObjectStoreNotificationType)notificationType
{
    if (!object) {
        return;
    }
    BZObjectStoreObserver *observer = [[BZObjectStoreObserver alloc]init];
    observer.object = object;
    observer.target = target;
    observer.selector = selector;
    observer.notificationType = notificationType;
    
    NSString *name = [self nameWithObject:object notificationType:notificationType];
    [self addObserver:observer selector:@selector(received:) name:name object:nil];
    
    NSObject *targetObject = target;
    if (!targetObject.OSObservers) {
        targetObject.OSObservers = [NSMutableArray array];
    }
    [targetObject.OSObservers addObject:observer];
}

- (NSString*)nameWithObject:(NSObject*)object notificationType:(BZObjectStoreNotificationType)notificationType
{
    NSString *name = [NSString stringWithFormat:@"ObjectStoreNotification_%@_%ld",NSStringFromClass([object class]),(long)notificationType];
    return name;
}

@end
