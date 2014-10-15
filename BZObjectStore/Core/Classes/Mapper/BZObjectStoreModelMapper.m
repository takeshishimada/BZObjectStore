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

#import "BZObjectStoreModelMapper.h"
#import "BZObjectStoreConditionModel.h"
#import "BZObjectStoreModelInterface.h"
#import "BZObjectStoreRelationshipModel.h"
#import "BZObjectStoreRuntime.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreNameBuilder.h"
#import "BZObjectStoreSQLiteColumnModel.h"
#import <FMDatabaseQueue.h>
#import <FMDatabase.h>
#import <FMResultSet.h>
#import <FMDatabaseAdditions.h>
#import "FMDatabase+indexInfo.h"
#import "NSObject+BZObjectStore.h"

@implementation BZObjectStoreModelMapper

- (BOOL)createTable:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db
{
    BOOL tableExists = [db tableExists:runtime.tableName];
    if (!tableExists) {
        [db executeUpdate:[runtime createTableStatement]];
        if ([self hadError:db]) {
            return NO;
        }
        if (!runtime.fullTextSearch3 && !runtime.fullTextSearch4 && runtime.hasIdentificationAttributes) {
            [db executeUpdate:[runtime createUniqueIndexStatement]];
            if ([self hadError:db]) {
                return NO;
            }
        }
    } else {
        for (BZObjectStoreRuntimeProperty *attribute in runtime.insertAttributes) {
            for (BZObjectStoreSQLiteColumnModel *sqliteColumn in attribute.sqliteColumns) {
                if (![db columnExists:sqliteColumn.columnName inTableWithName:runtime.tableName]) {
                    NSString *sql = [attribute alterTableAddColumnStatement:sqliteColumn];
                    [db executeUpdate:sql];
                    if ([self hadError:db]) {
                        return NO;
                    }
                }
            }
            
        }
        if (!runtime.hasIdentificationAttributes || runtime.fullTextSearch3 || runtime.fullTextSearch4) {
            BOOL indexExists = [db indexExists:runtime.uniqueIndexName];
            if (indexExists) {
                [db executeUpdate:[runtime dropUniqueIndexStatement]];
                if ([self hadError:db]) {
                    return NO;
                }
            }
            
        } else {
            BOOL indexExists = [db indexExists:runtime.uniqueIndexName];
            if (!indexExists) {
                [db executeUpdate:[runtime createUniqueIndexStatement]];
                if ([self hadError:db]) {
                    return NO;
                }
            } else {
                BOOL changed = NO;
                NSArray *columnNames = [db columnNamesWithIndexName:runtime.uniqueIndexName];
                if (columnNames.count != runtime.identificationAttributes.count) {
                    changed = YES;
                } else {
                    for (NSInteger i = 0; i < columnNames.count; i++) {
                        BZObjectStoreRuntimeProperty *attribute = runtime.identificationAttributes[i];
                        NSString *columnNameFrom = columnNames[i];
                        NSString *columnNameTo = attribute.name;
                        if (![columnNameFrom isEqualToString:columnNameTo]) {
                            changed = YES;
                            break;
                        }
                    }
                }
                if (changed) {
                    [db executeUpdate:[runtime dropUniqueIndexStatement]];
                    if ([self hadError:db]) {
                        return NO;
                    }
                    [db executeUpdate:[runtime createUniqueIndexStatement]];
                    if ([self hadError:db]) {
                        return NO;
                    }
                }
            }
        }
    }
    return YES;
}




#pragma mark create,drop

- (BOOL)dropTable:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db
{
    BOOL tableExists = [db tableExists:runtime.tableName];
    if (tableExists) {
        [db executeUpdate:[runtime dropTableStatement]];
        if ([self hadError:db]) {
            return NO;
        }
    }
    return YES;
}


#pragma mark avg,total,sum,min,max,count,referencedCount

- (NSNumber*)avg:(BZObjectStoreRuntime*)runtime columnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSString *sql = [runtime avgStatementWithColumnName:columnName condition:condition];
    NSNumber *value = [self groupWithStatement:sql condition:condition db:db];
    return value;
}

- (NSNumber*)total:(BZObjectStoreRuntime*)runtime columnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSString *sql = [runtime totalStatementWithColumnName:columnName condition:condition];
    NSNumber *value = [self groupWithStatement:sql condition:condition db:db];
    return value;
}

- (NSNumber*)sum:(BZObjectStoreRuntime*)runtime columnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSString *sql = [runtime sumStatementWithColumnName:columnName condition:condition];
    NSNumber *value = [self groupWithStatement:sql condition:condition db:db];
    return value;
}

- (NSNumber*)min:(BZObjectStoreRuntime*)runtime columnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSString *sql = [runtime minStatementWithColumnName:columnName condition:condition];
    NSNumber *value = [self groupWithStatement:sql condition:condition db:db];
    return value;
}

- (NSNumber*)max:(BZObjectStoreRuntime*)runtime columnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSString *sql = [runtime maxStatementWithColumnName:columnName condition:condition];
    NSNumber *value = [self groupWithStatement:sql condition:condition db:db];
    return value;
}

- (NSNumber*)count:(BZObjectStoreRuntime*)runtime condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSString *sql = [runtime countStatementWithCondition:condition];
    NSNumber *value = [self groupWithStatement:sql condition:condition db:db];
    return value;
}

- (NSNumber*)groupWithStatement:(NSString*)statement condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    FMResultSet *rs = [db executeQuery:statement withArgumentsInArray:condition.sqlite.parameters];
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

- (NSNumber*)referencedCount:(NSObject*)object db:(FMDatabase*)db
{
    [self updateRowid:object db:db];
    if (!object.rowid) {
        return nil;
    }
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"toTableName = ? and toRowid = ?";
    condition.sqlite.parameters = @[object.OSRuntime.tableName,object.rowid];
    NSString *sql = [object.OSRuntime referencedCountStatementWithCondition:condition];
    FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:condition.sqlite.parameters];
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

#pragma mark insert, update, delete

- (NSMutableArray*)select:(BZObjectStoreRuntime*)runtime condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSString *sql = [runtime selectStatementWithCondition:condition];
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObjectsFromArray:condition.sqlite.parameters];
    
    NSMutableArray *list = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:condition.sqlite.parameters];
    if ([self hadError:db]) {
        return nil;
    }
    while ([rs next]) {
        NSObject *targetObject = [runtime object];
        targetObject.OSRuntime = runtime;
        for (BZObjectStoreRuntimeProperty *attribute in targetObject.OSRuntime.simpleValueAttributes) {
            NSObject *value = [attribute valueWithResultSet:rs];
            [targetObject setValue:value forKey:attribute.name];
        }
        [list addObject:targetObject];
    }
    [rs close];
    return list;
}

- (BOOL)insertOrUpdate:(NSObject*)object db:(FMDatabase*)db
{
    if (object.rowid) {
        [self updateByRowId:object db:db];
        int changes = [db changes];
        if (changes == 0) {
            [self insertByRowId:object db:db];
        }
    } else if (object.OSRuntime.hasIdentificationAttributes ) {
        if (object.OSRuntime.insertPerformance) {
            [self insertByIdentificationAttributes:object db:db];
            if (!object.rowid) {
                [self updateByIdentificationAttributes:object db:db];
            }
        } else {
            [self updateByIdentificationAttributes:object db:db];
            if (!object.rowid) {
                [self insertByIdentificationAttributes:object db:db];
            }
        }
    } else if (!object.rowid) {
        [self insert:object db:db];
    }
    return YES;
}

- (BOOL)insertByRowId:(NSObject*)object db:(FMDatabase*)db
{
    NSString *sql = [object.OSRuntime insertOrReplaceIntoStatement];
    NSMutableArray *parameters = [object.OSRuntime insertOrReplaceAttributesParameters:object];
    [db executeUpdate:sql withArgumentsInArray:parameters];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

- (BOOL)updateByRowId:(NSObject*)object db:(FMDatabase*)db
{
    BZObjectStoreConditionModel *condition = [object.OSRuntime rowidCondition:object];
    NSString *sql = [object.OSRuntime updateStatementWithObject:object condition:condition];
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObjectsFromArray:[object.OSRuntime updateAttributesParameters:object]];
    [parameters addObjectsFromArray:condition.sqlite.parameters];
    [db executeUpdate:sql withArgumentsInArray:parameters];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

- (BOOL)insertByIdentificationAttributes:(NSObject*)object db:(FMDatabase*)db
{
    NSString *sql = [object.OSRuntime insertOrIgnoreIntoStatement];
    NSMutableArray *parameters = [object.OSRuntime insertOrIgnoreAttributesParameters:object];
    [db executeUpdate:sql withArgumentsInArray:parameters];
    if ([self hadError:db]) {
        return NO;
    }
    int changes = [db changes];
    if (changes > 0) {
        sqlite_int64 lastInsertRowid = [db lastInsertRowId];
        object.rowid = [NSNumber numberWithLongLong:lastInsertRowid];
    }
    return YES;
}

- (BOOL)updateByIdentificationAttributes:(NSObject*)object db:(FMDatabase*)db
{
    BZObjectStoreConditionModel *condition = [object.OSRuntime uniqueCondition:object];
    NSString *sql = [object.OSRuntime updateStatementWithObject:object condition:condition];
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObjectsFromArray:[object.OSRuntime updateAttributesParameters:object]];
    [parameters addObjectsFromArray:condition.sqlite.parameters];
    [db executeUpdate:sql withArgumentsInArray:parameters];
    if ([self hadError:db]) {
        return NO;
    }
    [self updateRowid:object db:db];
    return YES;
}

- (BOOL)insert:(NSObject*)object db:(FMDatabase*)db
{
    NSString *sql = [object.OSRuntime insertIntoStatement];
    NSMutableArray *parameters = [object.OSRuntime insertAttributesParameters:object];
    [db executeUpdate:sql withArgumentsInArray:parameters];
    if ([self hadError:db]) {
        return NO;
    }
    int changes = [db changes];
    if (changes > 0) {
        sqlite_int64 lastInsertRowid = [db lastInsertRowId];
        object.rowid = [NSNumber numberWithLongLong:lastInsertRowid];
    }
    return YES;
}

- (BOOL)deleteFrom:(NSObject*)object db:(FMDatabase*)db
{
    BZObjectStoreConditionModel *condition = [object.OSRuntime rowidCondition:object];
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObjectsFromArray:condition.sqlite.parameters];
    NSString *sql = [object.OSRuntime deleteFromStatementWithCondition:condition];
    [db executeUpdate:sql withArgumentsInArray:parameters];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

- (BOOL)deleteFrom:(BZObjectStoreRuntime*)runtime condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSString *sql = [runtime deleteFromStatementWithCondition:condition];
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObjectsFromArray:condition.sqlite.parameters];
    [db executeUpdate:sql withArgumentsInArray:parameters];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}


#pragma mark object update methods

- (void)updateRowid:(NSObject*)object db:(FMDatabase*)db
{
    if (object.rowid) {
        return;
    } else if (!object.OSRuntime.hasIdentificationAttributes) {
        return;
    }
    BZObjectStoreConditionModel *condition = [object.OSRuntime uniqueCondition:object];
    NSString *sql = [object.OSRuntime selectRowidStatement:condition];
    FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:condition.sqlite.parameters];
    while (rs.next) {
        object.rowid = [object.OSRuntime.rowidAttribute valueWithResultSet:rs];
        break;
    }
    [rs close];
}

- (void)updateRowidWithObjects:(NSArray*)objects db:(FMDatabase*)db
{
    for (NSObject *object in objects) {
        [self updateRowid:object db:db];
    }
    return;
}

- (void)updateSimpleValueWithObject:(NSObject*)object db:(FMDatabase*)db
{
    BZObjectStoreConditionModel *condition = [object.OSRuntime rowidCondition:object];
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObjectsFromArray:condition.sqlite.parameters];
    NSString *sql = [object.OSRuntime selectStatementWithCondition:condition];
    FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:condition.sqlite.parameters];
    if ([self hadError:db]) {
        return;
    }
    while ([rs next]) {
        for (BZObjectStoreRuntimeProperty *attribute in object.OSRuntime.simpleValueAttributes) {
            if (!attribute.isRelationshipClazz) {
                NSObject *value = [attribute valueWithResultSet:rs];
                [object setValue:value forKey:attribute.name];
            }
        }
        break;
    }
    [rs close];
}


#pragma mark relationship methods

- (NSMutableArray*)relationshipObjectsWithObject:(NSObject*)object attribute:(BZObjectStoreRuntimeProperty*)attribute relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db
{
    NSString *fromClassName = NSStringFromClass([object class]);
    NSString *fromAttributeName = attribute.name;
    NSNumber *fromRowid = object.rowid;
    NSArray *parameters = @[fromClassName,fromAttributeName,fromRowid];
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"fromClassName = ? and fromAttributeName = ? and fromRowid = ?";
    condition.sqlite.orderBy = @"attributeLevel desc,attributeSequence asc,attributeParentLevel desc,attributeParentSequence asc";
    condition.sqlite.parameters = parameters;
    return [self relationshipObjectsWithCondition:condition relationshipRuntime:relationshipRuntime db:db];
}

- (NSMutableArray*)relationshipObjectsWithToObject:(NSObject*)toObject relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db
{
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"toClassName = ? and toRowid = ?";
    condition.sqlite.orderBy = @"toClassName,toRowid";
    condition.sqlite.parameters = @[NSStringFromClass([toObject class]),toObject.rowid];
    return [self relationshipObjectsWithCondition:condition relationshipRuntime:relationshipRuntime db:db];
}

- (NSMutableArray*)relationshipObjectsWithCondition:(BZObjectStoreConditionModel*)condition relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db
{
    NSMutableArray *list = [self select:relationshipRuntime condition:condition db:db];
    if ([self hadError:db]) {
        return nil;
    }
    return list;
}

- (BOOL)insertRelationshipObjectsWithRelationshipObjects:(NSArray*)relationshipObjects db:(FMDatabase*)db
{
    for (BZObjectStoreRelationshipModel *relationshipObject in relationshipObjects) {
        [self insertOrUpdate:relationshipObject db:db];
        if ([self hadError:db]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)deleteRelationshipObjectsWithObject:(NSObject*)object attribute:(BZObjectStoreRuntimeProperty*)attribute relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db
{
    NSString *className = NSStringFromClass([object class]);
    NSString *attributeName = attribute.name;
    NSNumber *rowid = object.rowid;
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"fromClassName = ? and fromAttributeName = ? and fromRowid = ?";
    condition.sqlite.parameters = @[className,attributeName,rowid];
    [self deleteFrom:relationshipRuntime condition:condition db:db];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

- (BOOL)deleteRelationshipObjectsWithClazzName:(NSString*)className attribute:(BZObjectStoreRuntimeProperty*)attribute relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db
{
    NSString *attributeName = attribute.name;
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"fromClassName = ? and fromAttributeName = ?";
    condition.sqlite.parameters = @[className,attributeName];
    [self deleteFrom:relationshipRuntime condition:condition db:db];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

- (BOOL)deleteRelationshipObjectsWithClazzName:(NSString*)className relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db
{
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"fromClassName = ?";
    condition.sqlite.parameters = @[className];
    [self deleteFrom:relationshipRuntime condition:condition db:db];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

- (BOOL)deleteRelationshipObjectsWithRelationshipObject:(BZObjectStoreRelationshipModel*)relationshipObject db:(FMDatabase*)db
{
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"fromClassName = ? and fromAttributeName = ? and fromRowid = ? and toClassName = ? and toRowid = ?";
    condition.sqlite.parameters = @[relationshipObject.fromClassName,relationshipObject.fromAttributeName,relationshipObject.fromRowid,relationshipObject.toClassName,relationshipObject.toRowid];
    [self deleteFrom:relationshipObject.OSRuntime condition:condition db:db];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}


- (BOOL)deleteRelationshipObjectsWithFromObject:(NSObject*)object relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db
{
    NSString *className = NSStringFromClass([object class]);
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"(fromClassName = ? and fromRowid = ?)";
    condition.sqlite.parameters = @[className,object.rowid,className,object.rowid];
    [self deleteFrom:relationshipRuntime condition:condition db:db];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

- (BOOL)deleteRelationshipObjectsWithToObject:(NSObject*)object relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db
{
    NSString *className = NSStringFromClass([object class]);
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"(toClassName = ? and toRowid = ?)";
    condition.sqlite.parameters = @[className,object.rowid,className,object.rowid];
    [self deleteFrom:relationshipRuntime condition:condition db:db];
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
