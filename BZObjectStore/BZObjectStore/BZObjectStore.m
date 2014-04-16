//
// The MIT License (MIT)
//
// Copyright (c) 2014 BONZOO LLC
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

#import "BZObjectStore.h"
#import "BZObjectStoreModelInterface.h"
#import "BZObjectStoreRelationshipModel.h"
#import "BZObjectStoreAttributeModel.h"
#import "BZObjectStoreConditionModel.h"
#import "BZObjectStoreRuntime.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreNameBuilder.h"
#import "BZObjectStoreError.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabase+TemporaryTable.h"
#import "NSObject+BZObjectStore.h"

@interface BZObjectStoreRuntimeMapper (Protected)
- (BZObjectStoreRuntime*)runtime:(Class)clazz;
- (BOOL)registerAllRuntimes:(FMDatabase*)db;
- (void)registedRuntime:(BZObjectStoreRuntime*)runtime;
- (BOOL)registerRuntime:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db;
@end

@interface BZObjectStoreReferenceMapper (Protected)
- (NSNumber*)existsObject:(NSObject*)object db:(FMDatabase*)db error:(NSError**)error;
- (NSNumber*)max:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error;
- (NSNumber*)min:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error;
- (NSNumber*)avg:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error;
- (NSNumber*)total:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error;
- (NSNumber*)sum:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error;
- (NSNumber*)count:(Class)clazz condition:(BZObjectStoreConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error;
- (NSNumber*)referencedCount:(NSObject*)object db:(FMDatabase*)db error:(NSError**)error;
- (NSMutableArray*)fetchReferencingObjectsWithToObject:(NSObject*)object db:(FMDatabase*)db error:(NSError**)error;
- (NSArray*)refreshObject:(NSObject*)object db:(FMDatabase*)db error:(NSError**)error;
- (NSMutableArray*)fetchObjects:(Class)clazz condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db error:(NSError**)error;
- (BOOL)saveObjects:(NSArray*)objects db:(FMDatabase*)db error:(NSError**)error;
- (BOOL)removeObjects:(NSArray*)objects db:(FMDatabase*)db error:(NSError**)error;
- (BOOL)removeObjects:(Class)clazz condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db error:(NSError**)error;
@end


@interface BZObjectStore ()
@property (nonatomic,strong) FMDatabaseQueue *dbQueue;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,assign) BOOL rollback;
@end

@implementation BZObjectStore

#pragma mark constractor method

+ (instancetype)openWithPath:(NSString*)path error:(NSError**)error
{
    if (path) {
        if ([path isEqualToString:[path lastPathComponent]]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
            NSString *dir = [paths objectAtIndex:0];
            dir = [dir stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
            path = [dir stringByAppendingPathComponent:path];
        }
    }
    
    FMDatabaseQueue *dbQueue = [self dbQueueWithPath:path];
    if (!dbQueue) {
        return nil;
    }
    
    BZObjectStore *os = [[self alloc]init];
    os.dbQueue = dbQueue;
    os.db = nil;
    
    NSError *err = nil;
    BOOL ret = NO;
    ret = [os registerClazz:[BZObjectStoreRelationshipModel class] error:&err];
    if (!ret) {
        return nil;
    }
    ret = [os registerClazz:[BZObjectStoreAttributeModel class] error:&err];
    if (!ret) {
        return nil;
    }
    if (error) {
        *error = err;
    }
    return os;
}

+ (FMDatabaseQueue*)dbQueueWithPath:(NSString*)path
{
    if (path) {
        FMDatabase *db = [FMDatabase databaseWithPath:path];
        [db open];
        [db close];
    }
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    return dbQueue;
}

#pragma mark inDatabase,inTransaction

- (FMDatabaseQueue*)FMDBQueue
{
    return self.dbQueue;
}

- (void)inTransactionWithBlock:(void(^)(FMDatabase *db,BOOL *rollback))block
{
    if (self.db) {
        if (block) {
            block(self.db,&_rollback);
        }
    } else {
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [db setShouldCacheStatements:YES];
            block(db,rollback);
        }];
    }
}

- (void)inDatabaseWithBlock:(void(^)(FMDatabase *db))block
{
    if (self.db) {
        if (block) {
            block(self.db);
        }
    } else {
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            [db setShouldCacheStatements:YES];
            if (block) {
                block(db);
            }
        }];
    }
}

#pragma mark exists, count, min, max methods

- (NSNumber*)existsObject:(NSObject*)object error:(NSError**)error
{
    __block NSError *err = nil;
    __block NSNumber *exists = nil;
    [self inDatabaseWithBlock:^(FMDatabase *db) {
        exists = [self existsObject:object db:db error:&err];
        if ([db hadError]) {
            err = [db lastError];
        }
    }];
    if (error) {
        *error = err;
    }
    return exists;
}

- (NSNumber*)count:(Class)clazz condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    __block NSError *err = nil;
    __block NSNumber *value = nil;
    [self inDatabaseWithBlock:^(FMDatabase *db) {
        value = [self count:clazz condition:condition db:db error:&err];
        if ([db hadError]) {
            err = [db lastError];
        }
    }];
    if (error) {
        *error = err;
    }
    return value;
}

- (NSNumber*)max:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    __block NSError *err = nil;
    __block id value = nil;
    [self inDatabaseWithBlock:^(FMDatabase *db) {
        value = [self max:columnName class:clazz condition:condition db:db error:&err];
        if ([db hadError]) {
            err = [db lastError];
        }
    }];
    if (error) {
        *error = err;
    }
    return value;
}

- (NSNumber*)min:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    __block NSError *err = nil;
    __block id value = nil;
    [self inDatabaseWithBlock:^(FMDatabase *db) {
        value = [self min:columnName class:clazz condition:condition db:db error:&err];
        if ([db hadError]) {
            err = [db lastError];
        }
    }];
    if (error) {
        *error = err;
    }
    return value;
}

- (NSNumber*)total:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    __block NSError *err = nil;
    __block id value = nil;
    [self inDatabaseWithBlock:^(FMDatabase *db) {
        value = [self total:columnName class:clazz condition:condition db:db error:&err];
        if ([db hadError]) {
            err = [db lastError];
        }
    }];
    if (error) {
        *error = err;
    }
    return value;
}

- (NSNumber*)sum:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    __block NSError *err = nil;
    __block id value = nil;
    [self inDatabaseWithBlock:^(FMDatabase *db) {
        value = [self sum:columnName class:clazz condition:condition db:db error:&err];
        if ([db hadError]) {
            err = [db lastError];
        }
    }];
    if (error) {
        *error = err;
    }
    return value;
}

- (NSNumber*)avg:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    __block NSError *err = nil;
    __block id value = nil;
    [self inDatabaseWithBlock:^(FMDatabase *db) {
        value = [self avg:columnName class:clazz condition:condition db:db error:&err];
        if ([db hadError]) {
            err = [db lastError];
        }
    }];
    if (error) {
        *error = err;
    }
    return value;
}


#pragma mark fetch count methods

- (NSNumber*)referencedCount:(NSObject*)object error:(NSError**)error
{
    __block NSError *err = nil;
    __block NSNumber *value = nil;
    [self inDatabaseWithBlock:^(FMDatabase *db) {
        value = [self referencedCount:object db:db error:&err];
        if ([db hadError]) {
            err = [db lastError];
        }
    }];
    if (error) {
        *error = err;
    }
    return value;
}

- (NSMutableArray*)fetchReferencingFromObjectsWithObject:(NSObject*)object error:(NSError**)error
{
    __block NSError *err = nil;
    __block NSMutableArray *list = nil;
    [self inDatabaseWithBlock:^(FMDatabase *db) {
        list = [self fetchReferencingObjectsWithToObject:object db:db error:&err];
        if ([db hadError]) {
            err = [db lastError];
        }
    }];
    if (error) {
        *error = err;
    }
    return list;
}


#pragma mark fetch methods

- (NSMutableArray*)fetchObjects:(Class)clazz condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    __block NSError *err = nil;
    __block NSMutableArray *value = nil;
    [self inDatabaseWithBlock:^(FMDatabase *db) {
        value = [self fetchObjects:clazz condition:condition db:db error:&err];
        if ([db hadError]) {
            err = [db lastError];
        }
    }];
    if (error) {
        *error = err;
    }
    return value;
}

- (id)refreshObject:(NSObject*)object error:(NSError**)error
{
    __block NSError *err = nil;
    __block NSObject *latestObject = nil;
    [self inDatabaseWithBlock:^(FMDatabase *db) {
        latestObject = [self refreshObject:object db:db error:&err];
        if ([db hadError]) {
            err = [db lastError];
        }
    }];
    if (error) {
        *error = err;
    }
    return latestObject;
}



#pragma mark save methods

- (BOOL)saveObjects:(NSArray*)objects error:(NSError**)error
{
    if (![[objects class] isSubclassOfClass:[NSArray class]]) {
        NSString *message = @"Object must be NSArray subclassing";
        if (error) {
            *error = [BZObjectStoreError errorInvalidObject:message];;
        }
        return NO;
    }
    __block NSError *err = nil;
    __block BOOL ret = NO;
    [self inTransactionWithBlock:^(FMDatabase *db, BOOL *rollback) {
        [self saveObjects:objects db:db error:&err];
        if ([db hadError]) {
            err = [db lastError];
        }
        if (err) {
            *rollback = YES;
        }
        return;
    }];
    if (error) {
        *error = err;
    }
    return ret;
}

- (BOOL)saveObject:(NSObject*)object error:(NSError**)error
{
    __block NSError *err = nil;
    __block BOOL ret = NO;
    [self inTransactionWithBlock:^(FMDatabase *db, BOOL *rollback) {
        ret = [self saveObjects:@[object] db:db error:&err];
        if ([db hadError]) {
            err = [db lastError];
        }
        if (err) {
            *rollback = YES;
        }
    }];
    if (error) {
        *error = err;
    }
    return ret;
}

#pragma mark remove methods

- (BOOL)removeObjects:(Class)clazz condition:(BZObjectStoreConditionModel*)condition error:(NSError**)error
{
    __block NSError *err = nil;
    __block BOOL ret = NO;
    [self inTransactionWithBlock:^(FMDatabase *db, BOOL *rollback) {
        [db setShouldCacheStatements:YES];
        ret = [self removeObjects:clazz condition:condition db:db error:&err];
        if ([db hadError]) {
            err = [db lastError];
        }
        if (err) {
            *rollback = YES;
        }
        return;
    }];
    if (error) {
        *error = err;
    }
    return ret;
}

- (BOOL)removeObject:(NSObject*)object error:(NSError**)error
{
    __block NSError *err = nil;
    __block BOOL ret = NO;
    [self inTransactionWithBlock:^(FMDatabase *db, BOOL *rollback) {
        ret = [self removeObjects:@[object] db:db error:&err];
        if ([db hadError]) {
            err = [db lastError];
        }
        if (err) {
            *rollback = YES;
        }
        return;
    }];
    if (error) {
        *error = err;
    }
    return ret;
}

- (BOOL)removeObjects:(NSArray *)objects error:(NSError**)error
{
    if (![[objects class] isSubclassOfClass:[NSArray class]]) {
        NSString *message = @"Object must be NSArray subclassing";
        if (error) {
            *error = [BZObjectStoreError errorInvalidObject:message];;
        }
        return NO;
    }
    __block NSError *err = nil;
    __block BOOL ret = NO;
    [self inTransactionWithBlock:^(FMDatabase *db, BOOL *rollback) {
        ret = [self removeObjects:objects db:db error:&err];
        if ([db hadError]) {
            err = [db lastError];
        }
        if (err) {
            *rollback = YES;
        }
    }];
    if (error) {
        *error = err;
    }
    return ret;
}

#pragma register methods

- (BOOL)registerClazz:(Class)clazz error:(NSError**)error
{
    __block NSError *err = nil;
    __block BOOL ret = NO;
    [self inTransactionWithBlock:^(FMDatabase *db, BOOL *rollback) {
        BZObjectStoreRuntime *runtime = [self runtime:clazz];
        ret = [self registerRuntime:runtime db:db];
        if ([db hadError]) {
            err = [db lastError];
        }
        if (err) {
            *rollback = YES;
        }
        [self registedRuntime:runtime];
        return;
    }];
    if (error) {
        *error = err;
    }
    return ret;
}

- (void)close
{
    [self.dbQueue close];
    self.dbQueue = nil;
    self.db = nil;
}

@end
