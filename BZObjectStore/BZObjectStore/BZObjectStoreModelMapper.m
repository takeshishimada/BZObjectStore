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

#import "BZObjectStoreModelMapper.h"
#import "BZObjectStoreAttributeInterface.h"
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
+ (NSString*)ignorePrefixName;
+ (NSString*)ignoreSuffixName;
- (BZObjectStoreRuntime*)runtime:(Class)clazz;
- (BOOL)registerAllRuntimes:(FMDatabase*)db;
- (void)registedRuntime:(BZObjectStoreRuntime*)runtime;
- (BOOL)registerRuntime:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db;
@end

@implementation BZObjectStoreModelMapper

- (NSNumber*)avg:(BZObjectStoreRuntimeProperty*)attribute condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSString *sql = [attribute avgStatementWithCondition:condition];
    NSNumber *value = [self groupWithStatement:sql attribute:attribute condition:condition db:db];
    return value;
}

- (NSNumber*)total:(BZObjectStoreRuntimeProperty*)attribute condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSString *sql = [attribute totalStatementWithCondition:condition];
    NSNumber *value = [self groupWithStatement:sql attribute:attribute condition:condition db:db];
    return value;
}

- (NSNumber*)sum:(BZObjectStoreRuntimeProperty*)attribute condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSString *sql = [attribute sumStatementWithCondition:condition];
    NSNumber *value = [self groupWithStatement:sql attribute:attribute condition:condition db:db];
    return value;
}

- (NSNumber*)min:(BZObjectStoreRuntimeProperty*)attribute condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSString *sql = [attribute minStatementWithCondition:condition];
    NSNumber *value = [self groupWithStatement:sql attribute:attribute condition:condition db:db];
    return value;
}

- (NSNumber*)max:(BZObjectStoreRuntimeProperty*)attribute condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSString *sql = [attribute maxStatementWithCondition:condition];
    NSNumber *value = [self groupWithStatement:sql attribute:attribute condition:condition db:db];
    return value;
}

- (NSNumber*)groupWithStatement:(NSString*)statement attribute:(BZObjectStoreRuntimeProperty*)attribute condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSNumber *value = nil;
    FMResultSet *rs = [db executeQuery:statement withArgumentsInArray:condition.parameters];
    if ([self hadError:db]) {
        return value;
    }
    while (rs.next) {
        value = [attribute valueWithResultSet:rs];
    }
    [rs close];
    return value;
}

- (NSNumber*)count:(BZObjectStoreRuntime*)runtime condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSNumber *value = nil;
    NSString *sql = [runtime countStatementWithCondition:condition];
    FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:condition.parameters];
    if ([self hadError:db]) {
        return value;
    }
    while (rs.next) {
        value = [rs objectForColumnIndex:0];
    }
    [rs close];
    return value;
}

- (BOOL)insertOrReplace:(NSObject*)object db:(FMDatabase*)db
{
    if (object.runtime.hasIdentificationAttributes && !object.rowid) {
        NSString *sql = [object.runtime insertOrIgnoreIntoStatement];
        NSMutableArray *parameters = [object.runtime insertOrIgnoreAttributesParameters:object];
        [db executeUpdate:sql withArgumentsInArray:parameters];
        if ([self hadError:db]) {
            return NO;
        }
        sqlite_int64 lastInsertRowid = [db lastInsertRowId];
        if (lastInsertRowid != 0) {
            sqlite_int64 lastInsertRowid = [db lastInsertRowId];
            object.rowid = [NSNumber numberWithLongLong:lastInsertRowid];
            return YES;
        }
        // insertOrReplace statement always change rowid...
        // should use update statement in order to keep it.
        [self updateRowid:object db:db];
    }
    
    if (object.rowid) {
        BZObjectStoreConditionModel *condition = [object.runtime rowidCondition:object];
        NSString *sql = [object.runtime updateStatementWithObject:object condition:condition];
        NSMutableArray *parameters = [NSMutableArray array];
        [parameters addObjectsFromArray:condition.parameters];
        [parameters addObjectsFromArray:[object.runtime updateAttributesParameters:object]];
        [db executeUpdate:sql withArgumentsInArray:parameters];
        if ([self hadError:db]) {
            return NO;
        }
        
    } else if (!object.rowid) {
        NSString *sql = [object.runtime insertIntoStatement];
        NSMutableArray *parameters = [object.runtime insertAttributesParameters:object];
        [db executeUpdate:sql withArgumentsInArray:parameters];
        if ([self hadError:db]) {
            return NO;
        }
        sqlite_int64 lastInsertRowid = [db lastInsertRowId];
        object.rowid = [NSNumber numberWithLongLong:lastInsertRowid];
    }
    return YES;
}




- (BOOL)deleteFrom:(NSObject*)object db:(FMDatabase*)db
{
    if (object.rowid) {
        BZObjectStoreConditionModel *condition = [object.runtime rowidCondition:object];
        NSMutableArray *parameters = [NSMutableArray array];
        [parameters addObjectsFromArray:condition.parameters];
        NSString *sql = [object.runtime deleteFromStatementWithCondition:condition];
        [db executeUpdate:sql withArgumentsInArray:parameters];
        if ([self hadError:db]) {
            return NO;
        }
        return YES;
        
    } else if (object.runtime.hasIdentificationAttributes) {
        BZObjectStoreConditionModel *condition = [object.runtime uniqueCondition:object];
        NSMutableArray *parameters = [NSMutableArray array];
        [parameters addObjectsFromArray:condition.parameters];
        NSString *sql = [object.runtime deleteFromStatementWithCondition:condition];
        [db executeUpdate:sql withArgumentsInArray:parameters];
        if ([self hadError:db]) {
            return NO;
        }
        return YES;
    }
    return YES;
    
}

- (BOOL)deleteFrom:(BZObjectStoreRuntime*)runtime condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSString *sql = [runtime deleteFromStatementWithCondition:condition];
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObjectsFromArray:condition.parameters];
    [db executeUpdate:sql withArgumentsInArray:parameters];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

- (FMResultSet*)resultSet:(BZObjectStoreRuntime*)runtime condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSString *sql = [runtime selectStatementWithCondition:condition];
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObjectsFromArray:condition.parameters];
    FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:condition.parameters];
    return rs;
}

- (void)updateRowid:(NSObject*)object db:(FMDatabase*)db
{
    if (object.rowid) {
        return;
    } else if (!object.runtime.hasIdentificationAttributes) {
        return;
    }
    BZObjectStoreConditionModel *condition = [object.runtime uniqueCondition:object];
    NSString *sql = [object.runtime selectStatementWithCondition:condition];
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObjectsFromArray:condition.parameters];
    FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:condition.parameters];
    while (rs.next) {
        object.rowid = [object.runtime.rowidAttribute valueWithResultSet:rs];
        break;
    }
    return;
}

- (FMResultSet*)resultSet:(NSObject*)object db:(FMDatabase*)db
{
    if (object.rowid) {
        BZObjectStoreConditionModel *condition = [object.runtime rowidCondition:object];
        NSMutableArray *parameters = [NSMutableArray array];
        [parameters addObjectsFromArray:condition.parameters];
        NSString *sql = [object.runtime selectStatementWithCondition:condition];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:condition.parameters];
        return rs;
        
    } else if (object.runtime.hasIdentificationAttributes) {
        BZObjectStoreConditionModel *condition = [object.runtime uniqueCondition:object];
        NSMutableArray *parameters = [NSMutableArray array];
        [parameters addObjectsFromArray:condition.parameters];
        NSString *sql = [object.runtime selectStatementWithCondition:condition];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:condition.parameters];
        return rs;
        
    }
    return nil;
}

- (NSNumber*)referencedCount:(NSObject*)object db:(FMDatabase*)db
{
    [self updateRowid:object db:db];
    if (!object.rowid) {
        return nil;
    }
    if (!object.rowid) {
        return nil;
    }
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.where = @"toTableName = ? and toRowid = ?";
    condition.parameters = @[object.runtime.tableName,object.rowid];
    NSString *sql = [object.runtime referencedCountStatementWithCondition:condition];
    FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:condition.parameters];
    if ([self hadError:db]) {
        return nil;
    }
    NSNumber *value = nil;
    while (rs.next) {
        value = [rs objectForColumnIndex:0];
    }
    [rs close];
    return value;
}



#pragma mark relationship methods

- (NSMutableArray*)relationshipObjectsWithObject:(NSObject*)object attribute:(BZObjectStoreRuntimeProperty*)attribute db:(FMDatabase*)db
{
    NSString *fromClassName = NSStringFromClass([object class]);
    NSString *fromAttributeName = attribute.name;
    NSNumber *fromRowid = object.rowid;
    NSArray *parameters = @[fromClassName,fromAttributeName,fromRowid];
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.where = @"fromClassName = ? and fromAttributeName = ? and fromRowid = ?";
    condition.orderBy = @"attributeLevel desc,attributeSequence asc,attributeParentLevel desc,attributeParentSequence asc";
    condition.parameters = parameters;
    return [self relationshipObjectsWithCondition:condition db:db];
}

- (NSMutableArray*)relationshipObjectsWithToObject:(NSObject*)toObject db:(FMDatabase*)db
{
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.where = @"toClassName = ? and toRowid = ?";
    condition.orderBy = @"toClassName,toRowid";
    condition.parameters = @[NSStringFromClass([toObject class]),toObject.rowid];
    return [self relationshipObjectsWithCondition:condition db:db];
}

- (NSMutableArray*)relationshipObjectsWithCondition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    BZObjectStoreRuntime *runtime = [self runtime:[BZObjectStoreRelationshipModel class]];
    NSMutableArray *list = [NSMutableArray array];
    FMResultSet *rs = [self resultSet:runtime condition:condition db:db];
    if ([self hadError:db]) {
        return NO;
    }
    while (rs.next) {
        BZObjectStoreRelationshipModel *object = [[BZObjectStoreRelationshipModel alloc]init];
        for (BZObjectStoreRuntimeProperty *attribute in runtime.attributes) {
            id value = nil;
            if ([attribute.name isEqualToString:@"attributeValue"]) {
                Class clazz = NSClassFromString([rs stringForColumn:@"toClassName"]);
                BZObjectStoreRuntime *runtime = [super runtime:clazz];
                if (runtime) {
                    value = [runtime valueWithStoreValue:[rs objectForColumnName:@"attributeValue"]];
                }
            } else {
                value = [attribute valueWithResultSet:rs];
            }
            [object setValue:value forKey:attribute.name];
        }
        [list addObject:object];
    }
    [rs close];
    return list;
}

- (BOOL)insertRelationshipObjectsWithRelationshipObjects:(NSArray*)relationshipObjects db:(FMDatabase*)db
{
    for (BZObjectStoreRelationshipModel *relationshipObject in relationshipObjects) {
        relationshipObject.attributeValue = [relationshipObject.attributeValue.runtime storeValueWithValue:relationshipObject.attributeValue];
        [self insertOrReplace:relationshipObject db:db];
        if ([self hadError:db]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)deleteRelationshipObjectsWithObject:(NSObject*)object attribute:(BZObjectStoreRuntimeProperty*)attribute db:(FMDatabase*)db
{
    BZObjectStoreRuntime *runtime = [self runtime:[BZObjectStoreRelationshipModel class]];
    NSString *className = NSStringFromClass([object class]);
    NSString *attributeName = attribute.name;
    NSNumber *rowid = object.rowid;
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.where = @"fromClassName = ? and fromAttributeName = ? and fromRowid = ?";
    condition.parameters = @[className,attributeName,rowid];
    [self deleteFrom:runtime condition:condition db:db];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

- (BOOL)deleteRelationshipObjectsWithRelationshipObject:(BZObjectStoreRelationshipModel*)relationshipObject db:(FMDatabase*)db
{
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.where = @"fromClassName = ? and fromAttributeName = ? and fromRowid = ? and toClassName = ? and toRowid = ?";
    condition.parameters = @[relationshipObject.fromClassName,relationshipObject.fromAttributeName,relationshipObject.fromRowid,relationshipObject.toClassName,relationshipObject.toRowid];
    [self deleteFrom:relationshipObject.runtime condition:condition db:db];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

- (BOOL)deleteRelationshipObjectsWithObject:(NSObject*)object db:(FMDatabase*)db
{
    BZObjectStoreRuntime *runtime = [self runtime:[BZObjectStoreRelationshipModel class]];
    NSString *className = NSStringFromClass([object class]);
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.where = @"fromClassName = ? or toClassName = ?";
    condition.parameters = @[className,className];
    [self deleteFrom:runtime condition:condition db:db];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}


- (BOOL)hadError:(FMDatabase*)db
{
    if ([db hadError]) {
        return YES;
    } else {
        return NO;
    }
}

@end
