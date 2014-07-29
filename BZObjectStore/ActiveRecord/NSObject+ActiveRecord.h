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
#import "BZObjectStore.h"
#import "BZObjectStoreBackground.h"
#import "BZObjectStoreModelInterface.h"
#import "BZObjectStoreConditionModel.h"
#import "BZObjectStoreNotificationCenter.h"
#import "NSObject+BZObjectStore.h"

@interface NSObject (ActiveRecord)

- (BOOL)save;
- (BOOL)save:(NSError**)error;
- (BOOL)delete;
- (BOOL)delete:(NSError**)error;
- (id)refresh;
- (id)refresh:(NSError**)error;
- (NSNumber*)exists;
- (NSNumber*)exists:(NSError**)error;
- (NSNumber*)referencedCount;
- (NSNumber*)referencedCount:(NSError**)error;
+ (BOOL)deleteAll:(BZObjectStoreConditionModel*)condition;
+ (BOOL)deleteAll:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
+ (NSMutableArray*)fetch:(BZObjectStoreConditionModel*)condition;
+ (NSMutableArray*)fetch:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
+ (NSNumber*)count:(BZObjectStoreConditionModel*)condition;
+ (NSNumber*)count:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
+ (NSNumber*)max:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition;
+ (NSNumber*)max:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
+ (NSNumber*)min:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition;
+ (NSNumber*)min:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
+ (NSNumber*)sum:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition;
+ (NSNumber*)sum:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
+ (NSNumber*)total:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition;
+ (NSNumber*)total:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
+ (NSNumber*)avg:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition;
+ (NSNumber*)avg:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
+ (void)inTransaction:(void(^)(BZObjectStore *os,BOOL *rollback))block;
+ (BOOL)registClass;
+ (BOOL)registClass:(NSError**)error;
+ (BOOL)unRegisterClass;
+ (BOOL)unRegisterClass:(NSError**)error;

- (void)saveInBackground:(void(^)(NSError *error))completionBlock;
- (void)deleteInBackground:(void(^)(NSError *error))completionBlock;
- (void)referencedCountInBackground:(void(^)(NSNumber *value,NSError *error))completionBlock;
+ (void)fetchInBackground:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSArray *objects,NSError *error))completionBlock;
+ (void)deleteAllInBackground:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSError *error))completionBlock;
- (void)refreshInBackground:(void(^)(NSObject *object, NSError *error))completionBlock;
+ (void)countInBackground:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock;
+ (void)maxInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock;
+ (void)minInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock;
+ (void)sumInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock;
+ (void)totalInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock;
+ (void)avgInBackground:(NSString*)attributeName condition:(BZObjectStoreConditionModel*)condition completionBlock:(void(^)(NSNumber *value,NSError *error))completionBlock;
+ (void)inTransactionInBackground:(void(^)(BZObjectStore *os,BOOL *rollback))block;
+ (void)registerClassInBackground:(Class)clazz completionBlock:(void(^)(NSError *error))completionBlock;
+ (void)unRegisterClassInBackground:(Class)clazz completionBlock:(void(^)(NSError *error))completionBlock;

@end
