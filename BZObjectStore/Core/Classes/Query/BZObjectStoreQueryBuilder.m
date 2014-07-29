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

#import "BZObjectStoreQueryBuilder.h"
#import "BZObjectStoreRuntime.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreNameBuilder.h"
#import "BZObjectStoreRelationshipModel.h"
#import "BZObjectStoreConditionModel.h"
#import "BZObjectStoreSQLiteColumnModel.h"
#import "BZObjectStoreMigrationTable.h"
#import "NSObject+BZObjectStore.h"

@implementation BZObjectStoreQueryBuilder

#pragma mark per runtime

+ (NSArray*)sqliteColumnsWithAttributes:(NSArray*)attributes
{
    NSMutableArray *sqliteColumns = [NSMutableArray array];
    for (BZObjectStoreRuntimeProperty *attribute in attributes) {
        [sqliteColumns addObjectsFromArray:attribute.sqliteColumns];
    }
    return sqliteColumns;
}

+ (NSString*)selectStatement:(BZObjectStoreRuntime*)runtime
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"SELECT "];
    NSArray *attributes = runtime.attributes;
    NSArray *sqliteColumns = [self sqliteColumnsWithAttributes:attributes];
    for (BZObjectStoreSQLiteColumnModel *sqliteColumn in sqliteColumns) {
        [sql appendString:@""];
        [sql appendString:sqliteColumn.columnName];
        [sql appendString:@""];
        if ([sqliteColumns lastObject] != sqliteColumn) {
            [sql appendString:@","];
        }
    }
    [sql appendString:@" FROM "];
    [sql appendString:@""];
    [sql appendString:tableName];
    [sql appendString:@""];
    return [NSString stringWithString:sql];
}

+ (NSString*)selectRowidStatement:(BZObjectStoreRuntime*)runtime
{
    BZObjectStoreSQLiteColumnModel *sqliteColumn = runtime.rowidAttribute.sqliteColumns.firstObject;
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"SELECT "];
    [sql appendString:@""];
    [sql appendString:sqliteColumn.columnName];
    [sql appendString:@""];
    [sql appendString:@" FROM "];
    [sql appendString:@""];
    [sql appendString:tableName];
    [sql appendString:@""];
    return [NSString stringWithString:sql];
}

+ (NSString*)updateStatement:(BZObjectStoreRuntime*)runtime
{
    return [self updateStatement:runtime attributes:runtime.updateAttributes];
}
+ (NSString*)updateStatement:(BZObjectStoreRuntime*)runtime attributes:(NSArray*)attributes
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"UPDATE "];
    [sql appendString:tableName];
    [sql appendString:@" SET "];
    NSArray *sqliteColumns = [self sqliteColumnsWithAttributes:attributes];
    for (BZObjectStoreSQLiteColumnModel *sqliteColumn in sqliteColumns) {
        [sql appendString:@""];
        [sql appendString:sqliteColumn.columnName];
        [sql appendString:@""];
        [sql appendString:@" = ?"];
        [sql appendString:@","];
    }
    [sql appendString:@"__updatedAt__ = datetime('now')"];
    return [NSString stringWithString:sql];
}

+ (NSString*)insertIntoStatement:(BZObjectStoreRuntime*)runtime
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"INSERT INTO "];
    [sql appendString:tableName];
    NSMutableString *sqlNames = [NSMutableString stringWithFormat:@" ("];
    NSMutableString *sqlValues = [NSMutableString stringWithFormat:@" ("];
    NSArray *attributes = runtime.insertAttributes;
    NSArray *sqliteColumns = [self sqliteColumnsWithAttributes:attributes];
    for (BZObjectStoreSQLiteColumnModel *sqliteColumn in sqliteColumns) {
        [sqlNames appendString:@""];
        [sqlNames appendString:sqliteColumn.columnName];
        [sqlNames appendString:@""];
        [sqlValues appendString:@"?"];
        [sqlNames appendString:@","];
        [sqlValues appendString:@","];
    }
    [sqlNames appendString:@"__createdAt__"];
    [sqlNames appendString:@",__updatedAt__"];
    [sqlValues appendString:@"datetime('now')"];
    [sqlValues appendString:@",datetime('now')"];
    [sqlNames appendString:@")"];
    [sqlValues appendString:@")"];
    [sql appendString:sqlNames];
    [sql appendString:@" VALUES "];
    [sql appendString:sqlValues];
    return [NSString stringWithString:sql];
}

+ (NSString*)insertOrReplaceIntoStatement:(BZObjectStoreRuntime*)runtime
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"INSERT OR REPLACE INTO "];
    [sql appendString:tableName];
    NSMutableString *sqlNames = [NSMutableString stringWithFormat:@" ("];
    NSMutableString *sqlValues = [NSMutableString stringWithFormat:@" ("];
    NSArray *attributes = runtime.attributes;
    NSArray *sqliteColumns = [self sqliteColumnsWithAttributes:attributes];
    for (BZObjectStoreSQLiteColumnModel *sqliteColumn in sqliteColumns) {
        [sqlNames appendString:@""];
        [sqlNames appendString:sqliteColumn.columnName];
        [sqlNames appendString:@""];
        [sqlValues appendString:@"?"];
        [sqlNames appendString:@","];
        [sqlValues appendString:@","];
    }
    [sqlNames appendString:@"__createdAt__"];
    [sqlNames appendString:@",__updatedAt__"];
    [sqlValues appendString:@"datetime('now')"];
    [sqlValues appendString:@",datetime('now')"];
    [sqlNames appendString:@")"];
    [sqlValues appendString:@")"];
    [sql appendString:sqlNames];
    [sql appendString:@" VALUES "];
    [sql appendString:sqlValues];
    return [NSString stringWithString:sql];
}

+ (NSString*)insertOrIgnoreIntoStatement:(BZObjectStoreRuntime*)runtime
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"INSERT OR IGNORE INTO "];
    [sql appendString:tableName];
    NSMutableString *sqlNames = [NSMutableString stringWithFormat:@" ("];
    NSMutableString *sqlValues = [NSMutableString stringWithFormat:@" ("];
    NSArray *attributes = runtime.insertAttributes;
    NSArray *sqliteColumns = [self sqliteColumnsWithAttributes:attributes];
    for (BZObjectStoreSQLiteColumnModel *sqliteColumn in sqliteColumns) {
        [sqlNames appendString:@""];
        [sqlNames appendString:sqliteColumn.columnName];
        [sqlNames appendString:@""];
        [sqlValues appendString:@"?"];
        [sqlNames appendString:@","];
        [sqlValues appendString:@","];
    }
    [sqlNames appendString:@"__createdAt__"];
    [sqlNames appendString:@",__updatedAt__"];
    [sqlValues appendString:@"datetime('now')"];
    [sqlValues appendString:@",datetime('now')"];
    [sqlNames appendString:@")"];
    [sqlValues appendString:@")"];
    [sql appendString:sqlNames];
    [sql appendString:@" VALUES "];
    [sql appendString:sqlValues];
    return [NSString stringWithString:sql];
}

+ (NSString*)deleteFromStatement:(BZObjectStoreRuntime*)runtime
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@",tableName];
    return [NSString stringWithString:sql];
}

+ (NSString*)createTableStatement:(BZObjectStoreRuntime*)runtime
{
    NSArray *sqliteColumns = [self sqliteColumnsWithAttributes:runtime.insertAttributes];
    return [self createTableStatement:runtime.tableName fullTextSearch3:runtime.fullTextSearch3 fullTextSearch4:runtime.fullTextSearch4 sqliteColumns:sqliteColumns];
}

+ (NSString*)createTableStatement:(NSString*)tableName fullTextSearch3:(BOOL)fullTextSearch3 fullTextSearch4:(BOOL)fullTextSearch4 sqliteColumns:(NSArray*)sqliteColumns
{
    NSMutableString *sql = [NSMutableString string];
    if (fullTextSearch3 || fullTextSearch4) {
        [sql appendString:@"CREATE VIRTUAL TABLE IF NOT EXISTS "];
    } else {
        [sql appendString:@"CREATE TABLE IF NOT EXISTS "];
    }
    [sql appendString:tableName];
    if (fullTextSearch3) {
        [sql appendString:@" USING fts3 "];
    } else if (fullTextSearch4) {
        [sql appendString:@" USING fts4 "];
    }
    [sql appendString:@" ("];
    for (BZObjectStoreSQLiteColumnModel *sqliteColumn in sqliteColumns) {
        [sql appendString:sqliteColumn.columnName];
        [sql appendString:@" "];
        [sql appendString:sqliteColumn.dataTypeName ];
        [sql appendString:@","];
    }
    [sql appendString:@"__createdAt__ "];
    [sql appendString:@"DATE"];
    [sql appendString:@",__updatedAt__ "];
    [sql appendString:@"DATE"];
    [sql appendString:@")"];
    return [NSString stringWithString:sql];
}

+ (NSString*)dropTableStatement:(BZObjectStoreRuntime*)runtime
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"DROP TABLE "];
    [sql appendString:tableName];
    return [NSString stringWithString:sql];
}

+ (NSString*)uniqueIndexName:(BZObjectStoreRuntime*)runtime
{
    return [self uniqueIndexNameWithTableName:runtime.tableName];
}

+ (NSString*)uniqueIndexNameWithTableName:(NSString*)tableName
{
    return [NSString stringWithFormat:@"%@_IDX",tableName];
}


+ (NSString*)createUniqueIndexStatement:(BZObjectStoreRuntime*)runtime
{
    NSArray *sqliteColumns = [self sqliteColumnsWithAttributes:runtime.identificationAttributes];
    return [self createUniqueIndexStatement:runtime.tableName sqliteColumns:sqliteColumns];
}

+ (NSString*)createUniqueIndexStatement:(NSString*)tableName sqliteColumns:(NSArray*)sqliteColumns
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"CREATE "];
    [sql appendString:@"UNIQUE "];
    [sql appendString:@"INDEX "];
    [sql appendString:[self uniqueIndexNameWithTableName:tableName]];
    [sql appendString:@" ON "];
    [sql appendString:tableName];
    [sql appendString:@" ("];
    for (BZObjectStoreSQLiteColumnModel *sqliteColumn in sqliteColumns) {
        [sql appendString:sqliteColumn.columnName];
        if (sqliteColumns.lastObject != sqliteColumn) {
            [sql appendString:@","];
        }
    }
    [sql appendString:@")"];
    return sql;
}

+ (NSString*)dropIndexStatement:(BZObjectStoreRuntime*)runtime
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"DROP INDEX IF EXISTS "];
    [sql appendString:tableName];
    [sql appendString:@"_IDX"];
    return [NSString stringWithString:sql];
}

+ (NSString*)referencedCountStatement:(BZObjectStoreRuntime*)runtime
{
    NSString *tableName = @"__ObjectStoreRelationship__";
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"SELECT COUNT(*) FROM ("];
    [sql appendString:@"SELECT DISTINCT fromTableName,fromRowid FROM "];
    [sql appendString:tableName];
    [sql appendString:@"%@ "];
    [sql appendString:@") TBL "];
    return [NSString stringWithString:sql];
}

+ (NSString*)countStatement:(BZObjectStoreRuntime*)runtime
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"SELECT COUNT(*) FROM "];
    [sql appendString:tableName];
    [sql appendString:@""];
    return [NSString stringWithString:sql];
}


#pragma mark per attribute

+ (NSString*)alterTableAddColumnStatement:(NSString*)tableName sqliteColumn:(BZObjectStoreSQLiteColumnModel*)sqliteColumn
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"ALTER TABLE "];
    [sql appendString:tableName];
    [sql appendString:@" ADD COLUMN "];
    [sql appendString:sqliteColumn.columnName];
    [sql appendString:@" "];
    [sql appendString:sqliteColumn.dataTypeName];
    return [NSString stringWithString:sql];
}

+ (NSString*)maxStatement:(BZObjectStoreRuntime*)runtime columnName:(NSString*)columnName
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT MAX(%@) %@ FROM %@",columnName,columnName,tableName];
    return [NSString stringWithString:sql];
}

+ (NSString*)minStatement:(BZObjectStoreRuntime*)runtime columnName:(NSString*)columnName
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT MIN(%@) %@ FROM %@",columnName,columnName,tableName];
    return [NSString stringWithString:sql];
}

+ (NSString*)avgStatement:(BZObjectStoreRuntime*)runtime columnName:(NSString*)columnName
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT AVG(%@) %@ FROM %@",columnName,columnName,tableName];
    return [NSString stringWithString:sql];
}

+ (NSString*)totalStatement:(BZObjectStoreRuntime*)runtime columnName:(NSString*)columnName
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT TOTAL(%@) %@ FROM %@",columnName,columnName,tableName];
    return [NSString stringWithString:sql];
}

+ (NSString*)sumStatement:(BZObjectStoreRuntime*)runtime columnName:(NSString*)columnName
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT SUM(%@) %@ FROM %@",columnName,columnName,tableName];
    return [NSString stringWithString:sql];
}

#pragma mark unique condition

+ (NSString*)rowidConditionStatement
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"rowid = ?"];
    return [NSString stringWithString:sql];
}

+ (NSString*)uniqueConditionStatement:(BZObjectStoreRuntime*)runtime
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@""];
    NSArray *attributes = runtime.identificationAttributes;
    NSArray *sqliteColumns = [self sqliteColumnsWithAttributes:attributes];
    for (BZObjectStoreSQLiteColumnModel *sqliteColumn in sqliteColumns) {
        [sql appendString:sqliteColumn.columnName];
        [sql appendString:@" = ?"];
        if (sqliteColumn != sqliteColumns.lastObject) {
            [sql appendString:@" AND "];
        }
    }
    return [NSString stringWithString:sql];
}


#pragma mark condition

+ (NSString*)selectConditionStatement:(BZObjectStoreConditionModel*)condition
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@" where "];
    if (condition.sqlite.where) {
        [sql appendString:@" ("];
        [sql appendString:condition.sqlite.where];
        [sql appendString:@" )"];
    }
    return [NSString stringWithString:sql];
}

+ (NSString*)deleteConditionStatement:(BZObjectStoreConditionModel*)condition
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@" where "];
    if (condition.sqlite.where) {
        [sql appendString:@" ("];
        [sql appendString:condition.sqlite.where];
        [sql appendString:@" )"];
    }
    return [NSString stringWithString:sql];
}

+ (NSString*)updateConditionStatement:(BZObjectStoreConditionModel*)condition
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@" where "];
    if (condition.sqlite.where) {
        [sql appendString:@" ("];
        [sql appendString:condition.sqlite.where];
        [sql appendString:@" )"];
    }
    return [NSString stringWithString:sql];
}

+ (NSString*)selectConditionStatement:(BZObjectStoreConditionModel*)condition runtime:(BZObjectStoreRuntime*)runtime
{
    NSMutableString *sql = [NSMutableString string];
    if ( condition.sqlite.where || condition.reference.from || condition.reference.to) {
        BOOL firstCondition = YES;
        [sql appendString:@" where "];
        if (condition.sqlite.where) {
            [sql appendString:@" ("];
            [sql appendString:condition.sqlite.where];
            [sql appendString:@" )"];
            firstCondition = NO;
        }
        if (condition.reference.from) {
            if (!firstCondition) {
                [sql appendString:@" AND "];
                firstCondition = NO;
            }
            NSString *relationshipTableName = @"__ObjectStoreRelationship__";
            NSString *toTableName = runtime.tableName;
            NSString *fromTableName = condition.reference.from.OSRuntime.tableName;
            NSString *fromRowid = [condition.reference.from.rowid stringValue];
            if ([NSNull null] == condition.reference.from) {
                [sql appendString:[NSString stringWithFormat:@" NOT EXISTS (SELECT * FROM %@ r1 WHERE r1.toRowid = %@.rowid AND r1.toTableName = '%@' )",relationshipTableName,toTableName,toTableName]];
            } else {
                [sql appendString:[NSString stringWithFormat:@" EXISTS (SELECT * FROM %@ r1 WHERE r1.fromTableName = '%@' and r1.fromRowid = %@ and r1.toRowid = %@.rowid AND r1.toTableName = '%@' )",relationshipTableName,fromTableName,fromRowid,toTableName,toTableName]];
            }
        }
        if (condition.reference.to) {
            if (!firstCondition) {
                [sql appendString:@" AND "];
            }
            NSString *relationshipTableName = @"__ObjectStoreRelationship__";
            NSString *fromTableName = runtime.tableName;
            NSString *toTableName = condition.reference.to.OSRuntime.tableName;;
            NSString *toRowid = [condition.reference.to.rowid stringValue];
            if ([NSNull null] == condition.reference.to) {
                [sql appendString:[NSString stringWithFormat:@" NOT EXISTS (SELECT * FROM %@ r1 WHERE r1.fromRowid = %@.rowid AND r1.fromTableName = '%@' )",relationshipTableName,fromTableName,fromTableName]];
            } else {
                [sql appendString:[NSString stringWithFormat:@" EXISTS (SELECT * FROM %@ r1 WHERE r1.toTableName = '%@' and r1.toRowid = %@ and r1.fromRowid = %@.rowid AND r1.fromTableName = '%@' )",relationshipTableName,toTableName,toRowid,fromTableName,fromTableName]];
            }
        }
    }
    return [NSString stringWithString:sql];
}

+ (NSString*)selectConditionOptionStatement:(BZObjectStoreConditionModel*)condition
{
    NSMutableString *sql = [NSMutableString string];
    if ( condition.sqlite.orderBy ) {
        [sql appendString:@" order by "];
        [sql appendString:condition.sqlite.orderBy];
        [sql appendString:@" "];
    }
    if ( condition.sqlite.limit ) {
        [sql appendString:@" limit "];
        [sql appendString:[condition.sqlite.limit stringValue]];
        [sql appendString:@" "];
    }
    if ( condition.sqlite.offset ) {
        [sql appendString:@" offset "];
        [sql appendString:[condition.sqlite.offset stringValue]];
        [sql appendString:@" "];
    }
    return [NSString stringWithString:sql];
}

@end
