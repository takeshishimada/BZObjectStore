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

#import "BZObjectStoreMigration.h"
#import "BZObjectStoreConditionModel.h"
#import "BZObjectStoreMigration.h"

@class FMDatabaseQueue;
@class FMDatabase;

@interface BZObjectStore : BZObjectStoreMigration

+ (instancetype)openWithPath:(NSString*)path error:(NSError**)error;

- (void)inTransaction:(void(^)(BZObjectStore *os,BOOL *rollback))block;

- (BOOL)saveObject:(NSObject*)object error:(NSError**)error;
- (BOOL)saveObjects:(NSArray*)objects error:(NSError**)error;

- (BOOL)deleteObject:(NSObject*)object error:(NSError**)error;
- (BOOL)deleteObjects:(NSArray *)objects error:(NSError**)error;
- (BOOL)deleteObjects:(Class)clazz condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;

- (id)refreshObject:(NSObject*)object error:(NSError**)error;
- (NSMutableArray*)fetchObjects:(Class)clazz condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
- (NSMutableArray*)fetchReferencingObjectsTo:(NSObject*)object error:(NSError**)error;

- (NSNumber*)count:(Class)clazz condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
- (NSNumber*)referencedCount:(NSObject*)object error:(NSError**)error;
- (NSNumber*)existsObject:(NSObject*)object error:(NSError**)error;

- (NSNumber*)max:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
- (NSNumber*)min:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
- (NSNumber*)sum:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
- (NSNumber*)total:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;
- (NSNumber*)avg:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error;

- (BOOL)registerClass:(Class)clazz error:(NSError**)error;
- (BOOL)unRegisterClass:(Class)clazz error:(NSError**)error;

- (BOOL)migrate:(NSError**)error;

- (void)close;

@end

@interface BZObjectStore (Additional)
@property (nonatomic,readonly) FMDatabaseQueue *dbQueue;
- (void)transactionDidBegin:(FMDatabase*)db;
- (void)transactionDidEnd:(FMDatabase*)db;
- (NSMutableArray*)fetchObjects:(Class)clazz where:(NSString*)where parameters:(NSArray*)parameters orderBy:(NSString*)orderBy error:(NSError**)error;
- (NSMutableArray*)fetchObjects:(Class)clazz where:(NSString*)where parameters:(NSArray*)parameters orderBy:(NSString*)orderBy offset:(NSNumber*)offset limit:(NSNumber*)limit error:(NSError**)error;
- (BOOL)deleteObjects:(Class)clazz where:(NSString*)where parameters:(NSArray*)parameters error:(NSError**)error;
@end

