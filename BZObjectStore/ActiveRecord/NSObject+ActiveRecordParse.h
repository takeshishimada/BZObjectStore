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

#import <Foundation/Foundation.h>
#import "BZActiveRecord.h"
#import "BZObjectStore.h"
#import "BZObjectStoreBackground.h"
#import "BZObjectStoreModelInterface.h"
#import "BZObjectStoreConditionModel.h"

@interface NSObject (ActiveRecordParse)

- (BOOL)OSSave;
- (BOOL)OSSave:(NSError**)error;
- (BOOL)OSDelete;
- (BOOL)OSDelete:(NSError**)error;
- (id)OSRefresh;
- (id)OSRefresh:(NSError**)error;
- (NSNumber*)OSExists;
- (NSNumber*)OSExists:(NSError**)error;
- (NSNumber*)OSReferencedCount;
- (NSNumber*)OSReferencedCount:(NSError**)error;
+ (BOOL)OSDeleteAll:(BZObjectStoreConditionModel*)condition;
+ (BOOL)OSDeleteAll:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
+ (NSMutableArray*)OSFetch:(BZObjectStoreConditionModel*)condition;
+ (NSMutableArray*)OSFetch:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
+ (NSNumber*)OSCount:(BZObjectStoreConditionModel*)condition;
+ (NSNumber*)OSCount:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
+ (NSNumber*)OSMax:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition;
+ (NSNumber*)OSMax:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
+ (NSNumber*)OSMin:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition;
+ (NSNumber*)OSMin:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
+ (NSNumber*)OSSum:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition;
+ (NSNumber*)OSSum:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
+ (NSNumber*)OSTotal:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition;
+ (NSNumber*)OSTotal:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
+ (NSNumber*)OSAvg:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition;
+ (NSNumber*)OSAvg:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
+ (void)OSInTransaction:(void(^)(BZObjectStore *os,BOOL *rollback))block;
+ (BOOL)OSRegistClass;
+ (BOOL)OSRegistClass:(NSError**)error;
+ (BOOL)OSUnRegisterClass;
+ (BOOL)OSUnRegisterClass:(NSError**)error;

- (void)OSSaveInBackground:(void(^)(NSError *error))completionBlock;
- (void)OSDeleteInBackground:(void(^)(NSError *error))completionBlock;
- (void)OSReferencedCountInBackground:(void(^)(NSNumber *value,NSError *error))completionBlock;
+ (void)OSFetchInBackground:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSArray *objects,NSError *error))completionBlock;
+ (void)OSDeleteAllInBackground:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSError *error))completionBlock;
+ (void)OSCountInBackground:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock;
+ (void)OSMaxInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock;
+ (void)OSMinInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock;
+ (void)OSSumInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock;
+ (void)OSTotalInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock;
+ (void)OSAvgInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock;
+ (void)OSInTransactionInBackground:(void(^)(BZObjectStore *os,BOOL *rollback))block;
+ (void)OSRegisterClassInBackground:(Class)clazz completionBlock:(void(^)(NSError *error))completionBlock;
+ (void)OSUnRegisterClassInBackground:(Class)clazz completionBlock:(void(^)(NSError *error))completionBlock;

@end
