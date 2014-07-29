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

#import "NSObject+ActiveRecordParse.h"

@implementation NSObject (ActiveRecordParse)

- (BOOL)OSSave
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os saveObject:self error:nil];
}

- (BOOL)OSSave:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os saveObject:self error:error];
}

- (BOOL)OSDelete
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os deleteObject:self error:nil];
}

- (BOOL)OSDelete:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os deleteObject:self error:error];
}

- (id)OSRefresh
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os refreshObject:self error:nil];
}

- (id)OSRefresh:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os refreshObject:self error:error];
}

- (NSNumber*)OSExists
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os existsObject:self error:nil];
}

- (NSNumber*)OSExists:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os existsObject:self error:error];
}

- (NSNumber*)OSReferencedCount
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os referencedCount:self error:nil];
}

- (NSNumber*)OSReferencedCount:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os referencedCount:self error:error];
}

+ (NSMutableArray*)OSFetch:(BZObjectStoreConditionModel*)condition
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os fetchObjects:[self class] condition:condition error:nil];
}

+ (NSMutableArray*)OSFetch:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os fetchObjects:[self class] condition:condition error:error];
}

+ (BOOL)OSDeleteAll:(BZObjectStoreConditionModel*)condition
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os deleteObjects:[self class] condition:condition error:nil];
}

+ (BOOL)OSDeleteAll:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os deleteObjects:[self class] condition:condition error:error];
}

+ (NSNumber*)OSCount:(BZObjectStoreConditionModel*)condition
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os count:[self class] condition:condition error:nil];
}

+ (NSNumber*)OSCount:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os count:[self class] condition:condition error:error];
}

+ (NSNumber*)OSMax:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os max:columnName class:[self class] condition:condition error:nil];
}

+ (NSNumber*)OSMax:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os max:columnName class:[self class] condition:condition error:error];
}

+ (NSNumber*)OSMin:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os min:columnName class:[self class] condition:condition error:nil];
}

+ (NSNumber*)OSMin:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os min:columnName class:[self class] condition:condition error:error];
}

+ (NSNumber*)OSSum:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os sum:columnName class:[self class] condition:condition error:nil];
}

+ (NSNumber*)OSSum:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os sum:columnName class:[self class] condition:condition error:error];
}

+ (NSNumber*)OSTotal:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os total:columnName class:[self class] condition:condition error:nil];
}

+ (NSNumber*)OSTotal:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os total:columnName class:[self class] condition:condition error:error];
}

+ (NSNumber*)OSAvg:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os avg:columnName class:[self class] condition:condition error:nil];
}

+ (NSNumber*)OSAvg:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os avg:columnName class:[self class] condition:condition error:error];
}
+ (void)OSInTransaction:(void(^)(BZObjectStore *os,BOOL *rollback))block
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os inTransaction:^(BZObjectStore *os, BOOL *rollback) {
        block(os,rollback);
    }];
}
+ (BOOL)OSRegistClass
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os registerClass:[self class] error:nil];
}

+ (BOOL)OSRegistClass:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os registerClass:[self class] error:error];
}

+ (BOOL)OSUnRegisterClass
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os unRegisterClass:[self class] error:nil];
}

+ (BOOL)OSUnRegisterClass:(NSError**)error
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    return [os unRegisterClass:[self class] error:error];
}




- (void)OSSaveInBackground:(void(^)(NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os saveObjectInBackground:self completionBlock:completionBlock];
}

- (void)OSDeleteInBackground:(void(^)(NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os deleteObjectInBackground:self completionBlock:completionBlock];
}

- (void)OSReferencedCountInBackground:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os referencedCountInBackground:self completionBlock:completionBlock];
}

+ (void)OSFetchInBackground:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSArray *objects,NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os fetchObjectsInBackground:[self class] condition:condition completionBlock:completionBlock];
}

+ (void)OSDeleteAllInBackground:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os deleteObjectsInBackground:[self class] condition:condition completionBlock:completionBlock];
}

+ (void)OSCountInBackground:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os countInBackground:[self class] condition:condition completionBlock:completionBlock];
}

+ (void)OSMaxInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os maxInBackground:attributeName class:[self class] condition:condition completionBlock:completionBlock];
}

+ (void)OSMinInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os minInBackground:attributeName class:[self class] condition:condition completionBlock:completionBlock];
}

+ (void)OSSumInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os sumInBackground:attributeName class:[self class] condition:condition completionBlock:completionBlock];
}

+ (void)OSTotalInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os totalInBackground:attributeName class:[self class] condition:condition completionBlock:completionBlock];
}

+ (void)OSAvgInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os avgInBackground:attributeName class:[self class] condition:condition completionBlock:completionBlock];
}

+ (void)OSInTransactionInBackground:(void(^)(BZObjectStore *os,BOOL *rollback))block
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os inTransactionInBackground:block];
}

+ (void)OSRegisterClassInBackground:(Class)clazz completionBlock:(void(^)(NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os registerClassInBackground:[self class] completionBlock:completionBlock];
}

+ (void)OSUnRegisterClassInBackground:(Class)clazz completionBlock:(void(^)(NSError *error))completionBlock
{
    BZObjectStore *os = [BZActiveRecord objectStore];
    [os unRegisterClassInBackground:[self class] completionBlock:completionBlock];
}


@end
