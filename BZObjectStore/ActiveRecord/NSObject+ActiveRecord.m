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

#import "NSObject+ActiveRecord.h"
#import "BZActiveRecord.h"

@implementation NSObject (ActiveRecord)

- (BOOL)save
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os saveObject:self error:nil];
}

- (BOOL)save:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os saveObject:self error:error];
}

- (BOOL)delete
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os deleteObject:self error:nil];
}

- (BOOL)delete:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os deleteObject:self error:error];
}

- (id)refresh
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os refreshObject:self error:nil];
}

- (id)refresh:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os refreshObject:self error:error];
}

- (NSNumber*)exists
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os existsObject:self error:nil];
}

- (NSNumber*)exists:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os existsObject:self error:error];
}

- (NSNumber*)referencedCount
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os referencedCount:self error:nil];
}

- (NSNumber*)referencedCount:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os referencedCount:self error:error];
}

+ (NSMutableArray*)fetch:(BZObjectStoreConditionModel*)condition
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os fetchObjects:[self class] condition:condition error:nil];
}

+ (NSMutableArray*)fetch:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os fetchObjects:[self class] condition:condition error:error];
}

+ (BOOL)deleteAll:(BZObjectStoreConditionModel*)condition
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os deleteObjects:[self class] condition:condition error:nil];
}

+ (BOOL)deleteAll:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os deleteObjects:[self class] condition:condition error:error];
}

+ (NSNumber*)count:(BZObjectStoreConditionModel*)condition
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os count:[self class] condition:condition error:nil];
}

+ (NSNumber*)count:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os count:[self class] condition:condition error:error];
}

+ (NSNumber*)max:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os max:columnName class:[self class] condition:condition error:nil];
}

+ (NSNumber*)max:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os max:columnName class:[self class] condition:condition error:error];
}

+ (NSNumber*)min:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os min:columnName class:[self class] condition:condition error:nil];
}

+ (NSNumber*)min:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os min:columnName class:[self class] condition:condition error:error];
}

+ (NSNumber*)sum:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os sum:columnName class:[self class] condition:condition error:nil];
}

+ (NSNumber*)sum:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os sum:columnName class:[self class] condition:condition error:error];
}

+ (NSNumber*)total:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os total:columnName class:[self class] condition:condition error:nil];
}

+ (NSNumber*)total:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os total:columnName class:[self class] condition:condition error:error];
}

+ (NSNumber*)avg:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os avg:columnName class:[self class] condition:condition error:nil];
}

+ (NSNumber*)avg:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os avg:columnName class:[self class] condition:condition error:error];
}
+ (void)inTransaction:(void(^)(BZObjectStore *os,BOOL *rollback))block
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os inTransaction:^(BZObjectStore *os, BOOL *rollback) {
        block(os,rollback);
    }];
}
+ (BOOL)registClass
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os registerClass:[self class] error:nil];
}

+ (BOOL)registClass:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os registerClass:[self class] error:error];
}

+ (BOOL)unRegisterClass
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os unRegisterClass:[self class] error:nil];
}

+ (BOOL)unRegisterClass:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os unRegisterClass:[self class] error:error];
}




- (void)saveInBackground:(void(^)(NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os saveObjectInBackground:self completionBlock:completionBlock];
}

- (void)deleteInBackground:(void(^)(NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os deleteObjectInBackground:self completionBlock:completionBlock];
}

- (void)referencedCountInBackground:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os referencedCountInBackground:self completionBlock:completionBlock];
}

+ (void)fetchInBackground:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSArray *objects,NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os fetchObjectsInBackground:[self class] condition:condition completionBlock:completionBlock];
}

+ (void)deleteAllInBackground:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os deleteObjectsInBackground:[self class] condition:condition completionBlock:completionBlock];
}

- (void)refreshInBackground:(void(^)(NSObject *object, NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os refreshObjectInBackground:self completionBlock:^(NSObject *object, NSError *error) {
        completionBlock(object,error);
    }];
}

+ (void)countInBackground:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os countInBackground:[self class] condition:condition completionBlock:completionBlock];
}

+ (void)maxInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os maxInBackground:attributeName class:[self class] condition:condition completionBlock:completionBlock];
}

+ (void)minInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os minInBackground:attributeName class:[self class] condition:condition completionBlock:completionBlock];
}

+ (void)sumInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os sumInBackground:attributeName class:[self class] condition:condition completionBlock:completionBlock];
}

+ (void)totalInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os totalInBackground:attributeName class:[self class] condition:condition completionBlock:completionBlock];
}

+ (void)avgInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os avgInBackground:attributeName class:[self class] condition:condition completionBlock:completionBlock];
}

+ (void)inTransactionInBackground:(void(^)(BZObjectStore *os,BOOL *rollback))block
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os inTransactionInBackground:block];
}

+ (void)registerClassInBackground:(Class)clazz completionBlock:(void(^)(NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os registerClassInBackground:[self class] completionBlock:completionBlock];
}

+ (void)unRegisterClassInBackground:(Class)clazz completionBlock:(void(^)(NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os unRegisterClassInBackground:[self class] completionBlock:completionBlock];
}

@end
