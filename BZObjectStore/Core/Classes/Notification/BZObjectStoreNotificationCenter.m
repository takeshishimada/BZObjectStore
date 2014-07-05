//
// The MIT License (MIT)
//
// Copyright (c) 2014 BONZOO.LLC
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
#import "BZObjectStoreNotificationObserver.h"
#import "BZObjectStore.h"
#import "NSObject+BZObjectStore.h"

@implementation BZObjectStoreNotificationCenter

+ (void)postNotificateForObject:(NSObject*)object deleted:(BOOL)deleted
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithBool:deleted] forKey:@"deleted"];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSNotification *note = [NSNotification notificationWithName:@"ObjectStoreNotification" object:object userInfo:dic];
    [center postNotification:note];
}

+ (BZObjectStoreNotificationObserver*)observerForObject:(id)object target:(id)target completionBlock:(void(^)(id target,id object))completionBlock immediately:(BOOL)immediately
{
    __weak NSObject * weakTarget = target;
    __weak NSObject *weakObject = object;
    void (^block)(NSNotification *note) = ^(NSNotification *note) {
        NSNumber *deleted = note.userInfo[@"deleted"];
        NSObject *notificatedObject = note.object;
        NSString *notificatedObjectClazzName = NSStringFromClass([notificatedObject class]);
        NSNumber *notificatedObjectRowid = notificatedObject.rowid;
        NSString *observedObjectClazzName = NSStringFromClass([weakObject class]);
        NSNumber *observedObjectRowid = weakObject.rowid;
        if ([notificatedObjectClazzName isEqualToString:observedObjectClazzName]) {
            if (notificatedObjectRowid && observedObjectRowid) {
                if ([notificatedObjectRowid isEqualToNumber:observedObjectRowid]) {
                    if (completionBlock) {
                        if (deleted.boolValue) {
                            notificatedObject = nil;
                        }
                        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                            completionBlock(weakTarget,notificatedObject);
                        }];
                    }
                }
            }
        }
    };
    BZObjectStoreNotificationObserver *osObserver = [BZObjectStoreNotificationObserver observerForName:@"ObjectStoreNotification" usingBlock:block];
    if (immediately) {
        if (completionBlock) {
            completionBlock(weakTarget,weakObject);
        }
    }
    return osObserver;
}



@end
