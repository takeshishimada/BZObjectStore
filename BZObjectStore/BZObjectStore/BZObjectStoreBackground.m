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

#import "BZObjectStoreBackground.h"

@implementation BZObjectStore (Background)

- (void)saveObjectInBackground:(NSObject*)object completionBlock:(void(^)(NSError *error))completionBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        [self saveObject:object error:&error];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            completionBlock(error);
        }];
    }];
}

- (void)saveObjectsInBackground:(NSArray*)objects completionBlock:(void(^)(NSError *error))completionBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        [self saveObjects:objects error:&error];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            completionBlock(error);
        }];
    }];
}

- (void)removeObjectInBackground:(NSObject*)object completionBlock:(void(^)(NSError *error))completionBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        [self removeObject:object error:&error];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            completionBlock(error);
        }];
    }];
}

- (void)removeObjectsInBackground:(NSArray*)objects completionBlock:(void(^)(NSError *error))completionBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        [self removeObjects:objects error:&error];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            completionBlock(error);
        }];
    }];
}

- (void)removeObjectsInBackground:(Class)clazz condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSError *error))completionBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        [self removeObjects:clazz condition:condition error:&error];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            completionBlock(error);
        }];
    }];
}

- (void)refreshObjectInBackground:(NSObject*)object completionBlock:(void(^)(NSObject *object,NSError *error))completionBlock;
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        NSObject *refreshedObject = [self refreshObject:object error:&error];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            completionBlock(refreshedObject,error);
        }];
    }];
}

- (void)fetchObjectsInBackground:(Class)clazz condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSArray *objects,NSError *error))completionBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        NSArray *objects = [self fetchObjects:clazz condition:condition error:&error];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            completionBlock(objects,error);
        }];
    }];
}

- (void)fetchReferencingFromObjectsInBackground:(NSObject*)object completionBlock:(void(^)(NSArray *objects,NSError *error))completionBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        NSArray *objects = [self fetchReferencingFromObjects:object error:&error];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            completionBlock(objects,error);
        }];
    }];
}

- (void)referencedCountInBackground:(NSObject*)object completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        NSNumber *value = [self referencedCount:object error:&error];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            completionBlock(value,error);
        }];
    }];
}

- (void)countInBackground:(Class)clazz condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        NSNumber *value = [self count:clazz condition:condition error:&error];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            completionBlock(value,error);
        }];
    }];
}

- (void)maxInBackground:(NSString*)attributeName clazz:(Class)clazz condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        NSNumber *value = [self max:attributeName class:clazz condition:condition error:&error];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            completionBlock(value,error);
        }];
    }];
}

- (void)minInBackground:(NSString*)attributeName clazz:(Class)clazz condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        NSNumber *value = [self min:attributeName class:clazz condition:condition error:&error];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            completionBlock(value,error);
        }];
    }];
}

- (void)sumInBackground:(NSString*)attributeName clazz:(Class)clazz condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        NSNumber *value = [self sum:attributeName class:clazz condition:condition error:&error];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            completionBlock(value,error);
        }];
    }];
}

- (void)totalInBackground:(NSString*)attributeName clazz:(Class)clazz condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        NSNumber *value = [self total:attributeName class:clazz condition:condition error:&error];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            completionBlock(value,error);
        }];
    }];
}

- (void)avgInBackground:(NSString*)attributeName clazz:(Class)clazz condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        NSNumber *value = [self avg:attributeName class:clazz condition:condition error:&error];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            completionBlock(value,error);
        }];
    }];
}

@end
