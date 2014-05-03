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

#import "BZObjectStoreModelMapper.h"
#import "BZObjectStoreConditionModel.h"
#import "BZObjectStoreModelInterface.h"
#import "BZObjectStoreRelationshipModel.h"
#import "BZObjectStoreAttributeModel.h"
#import "BZObjectStoreRuntime.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreNameBuilder.h"
#import "BZObjectStoreSQLiteColumnModel.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabase+indexInfo.h"
#import "NSObject+BZObjectStore.h"

@implementation BZObjectStoreModelMapper

#pragma mark create,drop

- (BOOL)existsTable:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db
{
    return [db tableExists:runtime.tableName];
}

- (BOOL)createTable:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db
{
    [db executeUpdate:[runtime createTableStatement]];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

- (BOOL)createUniqueIndex:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db
{
    [db executeUpdate:[runtime createUniqueIndexStatement]];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

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

- (BOOL)dropUniqueIndex:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db
{
    BOOL indexExists = [db indexExists:runtime.uniqueIndexName];
    if (indexExists) {
        [db executeUpdate:[runtime dropUniqueIndexStatement]];
        if ([self hadError:db]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)createAttribute:(BZObjectStoreRuntime*)runtime attributeRuntime:(BZObjectStoreRuntime*)attributeRuntime db:(FMDatabase*)db
{
    NSString *insertsql = [attributeRuntime insertIntoStatement];
    for (BZObjectStoreRuntimeProperty *attribute in runtime.insertAttributes) {
        BZObjectStoreAttributeModel *object = [[BZObjectStoreAttributeModel alloc]init];
        object.tableName = runtime.tableName;
        object.className = runtime.clazzName;
        object.attributeName = attribute.name;
        object.attributeType = attribute.attributeType;
        NSArray *parameters = [attributeRuntime insertAttributesParameters:object];
        [db executeUpdate:insertsql withArgumentsInArray:parameters];
        if ([self hadError:db]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)deleteAttribute:(BZObjectStoreRuntime*)runtime attributeRuntime:(BZObjectStoreRuntime*)attributeRuntime db:(FMDatabase*)db
{
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"className = ?";
    condition.sqlite.parameters = @[runtime.clazzName];
    NSString *deletesql = [attributeRuntime deleteFromStatementWithCondition:condition];
    [db executeUpdate:deletesql withArgumentsInArray:condition.sqlite.parameters];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}




- (BOOL)createAtributeTable2:(BZObjectStoreRuntime*)runtime attributeRuntime:(BZObjectStoreRuntime*)attributeRuntime db:(FMDatabase*)db
{
    if (runtime.clazz == [BZObjectStoreAttributeModel class]) {
        return YES;
    }
    if (runtime.clazz == [BZObjectStoreRelationshipModel class]) {
        return YES;
    }
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"className = ?";
    condition.sqlite.parameters = @[runtime.clazzName];
    NSString *deletesql = [attributeRuntime deleteFromStatementWithCondition:condition];
    [db executeUpdate:deletesql withArgumentsInArray:condition.sqlite.parameters];
    if ([self hadError:db]) {
        return NO;
    }
    
    NSString *insertsql = [attributeRuntime insertIntoStatement];
    for (BZObjectStoreRuntimeProperty *attribute in runtime.insertAttributes) {
        BZObjectStoreAttributeModel *object = [[BZObjectStoreAttributeModel alloc]init];
        object.tableName = runtime.tableName;
        object.className = runtime.clazzName;
        object.attributeName = attribute.name;
        object.attributeType = attribute.attributeType;
        NSArray *parameters = [attributeRuntime insertAttributesParameters:object];
        [db executeUpdate:insertsql withArgumentsInArray:parameters];
        if ([self hadError:db]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)createTable2:(BZObjectStoreRuntime*)runtime attributeRuntime:(BZObjectStoreRuntime*)attributeRuntime db:(FMDatabase*)db
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
        [self createAtributeTable2:runtime attributeRuntime:attributeRuntime db:db];
        if ([self hadError:db]) {
            return NO;
        }
    } else {
        BOOL addedColumns = NO;
        for (BZObjectStoreRuntimeProperty *attribute in runtime.insertAttributes) {
            for (BZObjectStoreSQLiteColumnModel *sqliteColumn in attribute.sqliteColumns) {
                if (![db columnExists:sqliteColumn.columnName inTableWithName:runtime.tableName]) {
                    NSString *sql = [attribute alterTableAddColumnStatement:sqliteColumn];
                    [db executeUpdate:sql];
                    if ([self hadError:db]) {
                        return NO;
                    }
                    addedColumns = YES;
                }
            }
            
        }
        if ( addedColumns ) {
            [self createAtributeTable2:runtime attributeRuntime:attributeRuntime db:db];
            if ([self hadError:db]) {
                return NO;
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



#pragma mark avg,total,sum,min,max,count 

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


#pragma mark insert, update, delete

- (BOOL)insertOrReplace:(NSObject*)object db:(FMDatabase*)db
{
    if (object.rowid) {
        BZObjectStoreConditionModel *condition = [object.runtime rowidCondition:object];
        NSString *sql = [object.runtime updateStatementWithObject:object condition:condition];
        NSMutableArray *parameters = [NSMutableArray array];
        [parameters addObjectsFromArray:[object.runtime updateAttributesParameters:object]];
        [parameters addObjectsFromArray:condition.sqlite.parameters];
        [db executeUpdate:sql withArgumentsInArray:parameters];
        if ([self hadError:db]) {
            return NO;
        }
        return YES;
    }

    if (object.runtime.hasIdentificationAttributes && !object.rowid) {
        if (object.runtime.insertPerformance) {
            [self insertByIdentificationAttributes:object db:db];
            if ([self changes:object db:db] > 0) {
                return YES;
            }
            [self updateByIdentificationAttributes:object db:db];
            if ([self changes:object db:db] > 0) {
                return YES;
            }
        } else {
            [self updateByIdentificationAttributes:object db:db];
            if ([self changes:object db:db] > 0) {
                return YES;
            }
            [self insertByIdentificationAttributes:object db:db];
            if ([self changes:object db:db] > 0) {
                return YES;
            }
        }
    }
    
    if (!object.rowid) {
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

- (BOOL)insertByIdentificationAttributes:(NSObject*)object db:(FMDatabase*)db
{
    NSString *sql = [object.runtime insertOrIgnoreIntoStatement];
    NSMutableArray *parameters = [object.runtime insertOrIgnoreAttributesParameters:object];
    [db executeUpdate:sql withArgumentsInArray:parameters];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

- (BOOL)updateByIdentificationAttributes:(NSObject*)object db:(FMDatabase*)db
{
    BZObjectStoreConditionModel *condition = [object.runtime uniqueCondition:object];
    NSString *sql = [object.runtime updateStatementWithObject:object condition:condition];
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObjectsFromArray:[object.runtime updateAttributesParameters:object]];
    [parameters addObjectsFromArray:condition.sqlite.parameters];
    [db executeUpdate:sql withArgumentsInArray:parameters];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

- (int)changes:(NSObject*)object db:(FMDatabase*)db
{
    int changes = [db changes];
    if (changes > 0) {
        sqlite_int64 lastInsertRowid = [db lastInsertRowId];
        if (lastInsertRowid != 0) {
            sqlite_int64 lastInsertRowid = [db lastInsertRowId];
            object.rowid = [NSNumber numberWithLongLong:lastInsertRowid];
        }
    }
    return changes;
}

- (BOOL)deleteFrom:(NSObject*)object db:(FMDatabase*)db
{
    BZObjectStoreConditionModel *condition = [object.runtime rowidCondition:object];
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObjectsFromArray:condition.sqlite.parameters];
    NSString *sql = [object.runtime deleteFromStatementWithCondition:condition];
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

- (NSMutableArray*)objectsWithRuntime:(BZObjectStoreRuntime*)runtime condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db
{
    NSString *sql = [runtime selectStatementWithCondition:condition];
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObjectsFromArray:condition.sqlite.parameters];
    
    NSMutableArray *list = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:condition.sqlite.parameters];
    while ([rs next]) {
        NSObject *targetObject = [runtime object];
        targetObject.runtime = runtime;
        for (BZObjectStoreRuntimeProperty *attribute in targetObject.runtime.simpleValueAttributes) {
            NSObject *value = [attribute valueWithResultSet:rs];
            [targetObject setValue:value forKey:attribute.name];
        }
        [list addObject:targetObject];
    }
    [rs close];
    return list;
}

- (void)updateObjectRowid:(NSObject*)object db:(FMDatabase*)db
{
    if (object.rowid) {
        return;
    } else if (!object.runtime.hasIdentificationAttributes) {
        return;
    }
    BZObjectStoreConditionModel *condition = [object.runtime uniqueCondition:object];
    NSString *sql = [object.runtime selectRowidStatement:condition];
    FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:condition.sqlite.parameters];
    while (rs.next) {
        object.rowid = [object.runtime.rowidAttribute valueWithResultSet:rs];
        break;
    }
    [rs close];
}

- (void)updateRowidWithObjects:(NSArray*)objects db:(FMDatabase*)db
{
    for (NSObject *object in objects) {
        [self updateObjectRowid:object db:db];
    }
    return;
}

- (void)updateSimpleValueWithObject:(NSObject*)object db:(FMDatabase*)db
{
    BZObjectStoreConditionModel *condition = [object.runtime rowidCondition:object];
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObjectsFromArray:condition.sqlite.parameters];
    NSString *sql = [object.runtime selectStatementWithCondition:condition];
    FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:condition.sqlite.parameters];
    if ([self hadError:db]) {
        return;
    }
    while ([rs next]) {
        for (BZObjectStoreRuntimeProperty *attribute in object.runtime.simpleValueAttributes) {
            if (!attribute.isRelationshipClazz) {
                NSObject *value = [attribute valueWithResultSet:rs];
                [object setValue:value forKey:attribute.name];
            }
        }
        break;
    }
    [rs close];
}

- (NSNumber*)referencedCount:(NSObject*)object db:(FMDatabase*)db
{
    [self updateObjectRowid:object db:db];
    if (!object.rowid) {
        return nil;
    }
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"toTableName = ? and toRowid = ?";
    condition.sqlite.parameters = @[object.runtime.tableName,object.rowid];
    NSString *sql = [object.runtime referencedCountStatementWithCondition:condition];
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
    NSMutableArray *list = [self objectsWithRuntime:relationshipRuntime condition:condition db:db];
    if ([self hadError:db]) {
        return NO;
    }
    return list;
}

- (BOOL)insertRelationshipObjectsWithRelationshipObjects:(NSArray*)relationshipObjects db:(FMDatabase*)db
{
    for (BZObjectStoreRelationshipModel *relationshipObject in relationshipObjects) {
        [self insertOrReplace:relationshipObject db:db];
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

- (BOOL)deleteRelationshipObjectsWithRelationshipObject:(BZObjectStoreRelationshipModel*)relationshipObject db:(FMDatabase*)db
{
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"fromClassName = ? and fromAttributeName = ? and fromRowid = ? and toClassName = ? and toRowid = ?";
    condition.sqlite.parameters = @[relationshipObject.fromClassName,relationshipObject.fromAttributeName,relationshipObject.fromRowid,relationshipObject.toClassName,relationshipObject.toRowid];
    [self deleteFrom:relationshipObject.runtime condition:condition db:db];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

- (BOOL)deleteRelationshipObjectsWithObject:(NSObject*)object relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db
{
    NSString *className = NSStringFromClass([object class]);
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"(fromClassName = ? and fromRowid = ?) or (toClassName = ? and toRowid = ?)";
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
