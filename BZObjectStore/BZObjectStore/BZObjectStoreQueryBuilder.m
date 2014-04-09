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

#import "BZObjectStoreQueryBuilder.h"
#import "BZObjectStoreRuntime.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreConst.h"
#import "BZObjectStoreNameBuilder.h"
#import "BZObjectStoreRelationshipModel.h"
#import "BZObjectStoreFetchConditionModel.h"
#import "NSObject+BZObjectStore.h"

@implementation BZObjectStoreQueryBuilder

#pragma mark per runtime

+ (NSString*)selectStatement:(BZObjectStoreRuntime*)runtime
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"SELECT "];
    for ( BZObjectStoreRuntimeProperty *attribute in runtime.attributes) {
        [sql appendString:@""];
        [sql appendString:attribute.columnName];
        [sql appendString:@""];
        if ([runtime.attributes lastObject] != attribute) {
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
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"SELECT "];
    [sql appendString:@""];
    [sql appendString:runtime.rowidAttribute.columnName];
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
    for ( BZObjectStoreRuntimeProperty *attribute in attributes) {
        [sql appendString:@""];
        [sql appendString:attribute.columnName];
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
    for ( BZObjectStoreRuntimeProperty *attribute in runtime.insertAttributes) {
        [sqlNames appendString:@""];
        [sqlNames appendString:attribute.columnName];
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
    for ( BZObjectStoreRuntimeProperty *attribute in runtime.attributes) {
        [sqlNames appendString:@""];
        [sqlNames appendString:attribute.columnName];
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
    for ( BZObjectStoreRuntimeProperty *attribute in runtime.insertAttributes) {
        [sqlNames appendString:@""];
        [sqlNames appendString:attribute.columnName];
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
    NSString *tableName = runtime.tableName;
    NSArray *attributes = runtime.insertAttributes;
    NSMutableString *sql = [NSMutableString string];
    if (runtime.fullTextSearch) {
        [sql appendString:@"CREATE VIRTUAL TABLE IF NOT EXISTS "];
    } else if (runtime.temporary) {
        [sql appendString:@"CREATE TEMP TABLE IF NOT EXISTS "];
    } else {
        [sql appendString:@"CREATE TABLE IF NOT EXISTS "];
    }
    [sql appendString:tableName];
    if (runtime.fullTextSearch) {
        [sql appendString:@" USING fts4 "];
    }
    [sql appendString:@" ("];
    for ( BZObjectStoreRuntimeProperty *attribute in attributes) {
        [sql appendString:attribute.columnName];
        [sql appendString:@" "];
        [sql appendString:attribute.sqliteDataTypeName];
        [sql appendString:@","];
    }
    [sql appendString:@"__createdAt__ "];
    [sql appendString:SQLITE_DATA_TYPE_DATETIME];
    [sql appendString:@",__updatedAt__ "];
    [sql appendString:SQLITE_DATA_TYPE_DATETIME];
    [sql appendString:@")"];
    return [NSString stringWithString:sql];
}

+ (NSString*)dropTableStatement:(BZObjectStoreRuntime*)runtime
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"DROP TABLE "];
    [sql appendString:tableName];
    [sql appendString:@""];
    return [NSString stringWithString:sql];
}

+ (NSString*)createUniqueIndexStatement:(BZObjectStoreRuntime*)runtime
{
    NSMutableString *sql = [self createIndexStatementSub:runtime unique:YES attributes:runtime.identificationAttributes];
    return [NSString stringWithString:sql];
}

+ (NSString*)createIndexStatement:(BZObjectStoreRuntime*)runtime
{
    NSMutableString *sql = [self createIndexStatementSub:runtime unique:NO attributes:runtime.indexAttributes];
    return [NSString stringWithString:sql];
}

+ (NSMutableString*)createIndexStatementSub:(BZObjectStoreRuntime*)runtime unique:(BOOL)unique attributes:(NSArray*)attributes
{
    NSString *tableName = runtime.tableName;
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"CREATE "];
    if (unique) {
        [sql appendString:@"UNIQUE "];
    }
    [sql appendString:@"INDEX "];
    [sql appendString:tableName];
    [sql appendString:@"_IDX ON "];
    [sql appendString:tableName];
    [sql appendString:@" ("];
    for (BZObjectStoreRuntimeProperty *attribute in attributes) {
        [sql appendString:attribute.columnName];
        if ([attributes lastObject] != attribute) {
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
    [sql appendString:@"DROP INDEX "];
    [sql appendString:tableName];
    [sql appendString:@"_IDX"];
    return [NSString stringWithString:sql];
}

+ (NSString*)referencedCountStatement:(BZObjectStoreRuntime*)runtime
{
    NSString *tableName = [runtime.nameBuilder tableName:[BZObjectStoreRelationshipModel class]];
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

+ (NSString*)alterTableAddColumnStatement:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *tableName = attribute.tableName;
    NSString *columnName = attribute.columnName;
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"ALTER TABLE "];
    [sql appendString:tableName];
    [sql appendString:@" ADD COLUMN "];
    [sql appendString:columnName];
    [sql appendString:@" "];
    [sql appendString:attribute.sqliteDataTypeName];
    return [NSString stringWithString:sql];
}

+ (NSString*)maxStatement:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *tableName = attribute.tableName;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT MAX(%@) %@ FROM %@",attribute.columnName,attribute.columnName,tableName];
    return [NSString stringWithString:sql];
}

+ (NSString*)minStatement:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *tableName = attribute.tableName;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT MIN(%@) %@ FROM %@",attribute.columnName,attribute.columnName,tableName];
    return [NSString stringWithString:sql];
}

+ (NSString*)avgStatement:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *tableName = attribute.tableName;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT AVG(%@) %@ FROM %@",attribute.columnName,attribute.columnName,tableName];
    return [NSString stringWithString:sql];
}

+ (NSString*)totalStatement:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *tableName = attribute.tableName;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT TOTAL(%@) %@ FROM %@",attribute.columnName,attribute.columnName,tableName];
    return [NSString stringWithString:sql];
}

+ (NSString*)sumStatement:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *tableName = attribute.tableName;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT SUM(%@) %@ FROM %@",attribute.columnName,attribute.columnName,tableName];
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
    for (BZObjectStoreRuntimeProperty *attribute in runtime.identificationAttributes) {
        [sql appendString:attribute.columnName];
        [sql appendString:@" = ?"];
        if (attribute != runtime.identificationAttributes.lastObject) {
            [sql appendString:@" AND "];
        }
    }
    return [NSString stringWithString:sql];
}


#pragma mark condition

+ (NSString*)selectConditionStatement:(BZObjectStoreFetchConditionModel*)condition
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@" where "];
    if (condition.sqliteCondition.where) {
        [sql appendString:@" ("];
        [sql appendString:condition.sqliteCondition.where];
        [sql appendString:@" )"];
    }
    return [NSString stringWithString:sql];
}

+ (NSString*)deleteConditionStatement:(BZObjectStoreFetchConditionModel*)condition
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@" where "];
    if (condition.sqliteCondition.where) {
        [sql appendString:@" ("];
        [sql appendString:condition.sqliteCondition.where];
        [sql appendString:@" )"];
    }
    return [NSString stringWithString:sql];
}

+ (NSString*)updateConditionStatement:(BZObjectStoreFetchConditionModel*)condition
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@" where "];
    if (condition.sqliteCondition.where) {
        [sql appendString:@" ("];
        [sql appendString:condition.sqliteCondition.where];
        [sql appendString:@" )"];
    }
    return [NSString stringWithString:sql];
}

+ (NSString*)selectConditionStatement:(BZObjectStoreFetchConditionModel*)condition runtime:(BZObjectStoreRuntime*)runtime
{
    NSMutableString *sql = [NSMutableString string];
    if ( condition.sqliteCondition.where || condition.referenceCondition.from || condition.referenceCondition.to) {
        BOOL firstCondition = YES;
        [sql appendString:@" where "];
        if (condition.sqliteCondition.where) {
            [sql appendString:@" ("];
            [sql appendString:condition.sqliteCondition.where];
            [sql appendString:@" )"];
            firstCondition = NO;
        }
        BZObjectStoreRelationshipModel *relationship = [[BZObjectStoreRelationshipModel alloc]init];
        if (condition.referenceCondition.from) {
            if (!firstCondition) {
                [sql appendString:@" AND "];
                firstCondition = NO;
            }
            NSString *relationshipTableName = [runtime.nameBuilder tableName:[BZObjectStoreRelationshipModel class]];
            NSString *toTableName = runtime.tableName;
            NSString *fromTableName = [runtime.nameBuilder tableName:[condition.referenceCondition.from class]];
            NSString *fromRowid = [condition.referenceCondition.from.rowid stringValue];
            if ([NSNull null] == condition.referenceCondition.from) {
                [sql appendString:[NSString stringWithFormat:@" NOT EXISTS (SELECT * FROM %@ r1 WHERE r1.toRowid = %@.rowid AND r1.toTableName = '%@' )",relationshipTableName,toTableName,toTableName]];
            } else {
                [sql appendString:[NSString stringWithFormat:@" EXISTS (SELECT * FROM %@ r1 WHERE r1.fromTableName = '%@' and r1.fromRowid = %@ and r1.toRowid = %@.rowid AND r1.toTableName = '%@' )",relationshipTableName,fromTableName,fromRowid,toTableName,toTableName]];
            }
        }
        if (condition.referenceCondition.to) {
            if (!firstCondition) {
                [sql appendString:@" AND "];
            }
            NSString *relationshipTableName = [runtime.nameBuilder tableName:[relationship class]];
            NSString *fromTableName = runtime.tableName;
            NSString *toTableName = [runtime.nameBuilder tableName:[condition.referenceCondition.to class]];
            NSString *toRowid = [condition.referenceCondition.to.rowid stringValue];
            if ([NSNull null] == condition.referenceCondition.to) {
                [sql appendString:[NSString stringWithFormat:@" NOT EXISTS (SELECT * FROM %@ r1 WHERE r1.fromRowid = %@.rowid AND r1.fromTableName = '%@' )",relationshipTableName,fromTableName,fromTableName]];
            } else {
                [sql appendString:[NSString stringWithFormat:@" EXISTS (SELECT * FROM %@ r1 WHERE r1.toTableName = '%@' and r1.toRowid = %@ and r1.fromRowid = %@.rowid AND r1.fromTableName = '%@' )",relationshipTableName,toTableName,toRowid,fromTableName,fromTableName]];
            }
        }
    }
    return [NSString stringWithString:sql];
}

+ (NSString*)selectConditionOptionStatement:(BZObjectStoreFetchConditionModel*)condition
{
    NSMutableString *sql = [NSMutableString string];
    if ( condition.sqliteCondition.orderBy ) {
        [sql appendString:@" order by "];
        [sql appendString:condition.sqliteCondition.orderBy];
        [sql appendString:@" "];
    }
    if ( condition.sqliteCondition.limit ) {
        [sql appendString:@" limit "];
        [sql appendString:[condition.sqliteCondition.limit stringValue]];
        [sql appendString:@" "];
    }
    if ( condition.sqliteCondition.offset ) {
        [sql appendString:@" offset "];
        [sql appendString:[condition.sqliteCondition.offset stringValue]];
        [sql appendString:@" "];
    }
    return [NSString stringWithString:sql];
}

@end
