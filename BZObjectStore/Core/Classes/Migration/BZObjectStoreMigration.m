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

#import "BZObjectStoreMigration.h"
#import "BZObjectStore.h"
#import "BZObjectStoreRuntime.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreSQLiteColumnModel.h"
#import "BZObjectStoreRelationshipModel.h"
#import "BZObjectStoreMigrationRuntime.h"
#import "BZObjectStoreMigrationRuntimeProperty.h"
#import "BZObjectStoreMigrationTable.h"
#import "BZObjectStoreMigrationQueryBuilder.h"
#import <FMDatabase.h>
#import <FMDatabaseQueue.h>
#import <FMDatabaseAdditions.h>
#import "FMDatabase+indexInfo.h"

@interface BZObjectStoreReferenceMapper (Protected)
- (NSMutableArray*)fetchObjects:(Class)clazz condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db error:(NSError**)error;
- (BZObjectStoreRuntime*)runtime:(Class)clazz;
- (BOOL)registerRuntime:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db error:(NSError**)error;
- (BOOL)unRegisterRuntime:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db error:(NSError**)error;
- (BOOL)hadError:(FMDatabase*)db error:(NSError**)error;
@end

@interface BZObjectStoreModelMapper (Private)
- (BOOL)deleteRelationshipObjectsWithClazzName:(NSString*)className attribute:(BZObjectStoreRuntimeProperty*)attribute relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db;
@end

@implementation BZObjectStoreMigration

- (void)migrate:(FMDatabase*)db error:(NSError**)error
{
    
    // 旧クラス情報を列挙かつ新クラスの情報も同時に取得する
    NSMutableDictionary *newestRuntimes = [NSMutableDictionary dictionary];
    NSMutableArray *oldestRuntimes = [self fetchObjects:[BZObjectStoreRuntime class] condition:nil db:db error:error];
    for (BZObjectStoreRuntime *runtime in oldestRuntimes) {
        Class clazz = NSClassFromString(runtime.clazzName);
        if (clazz) {
            BZObjectStoreRuntime *newestRuntime = [self runtime:clazz];
            [newestRuntimes setObject:newestRuntime forKey:newestRuntime.clazzName];
        }
    }

    // 新旧クラスを持つマイグレーションクラスの一覧を作成する
    NSMutableDictionary *migrationRuntimes = [NSMutableDictionary dictionary];
    for (BZObjectStoreRuntime *runtime in oldestRuntimes) {
        BZObjectStoreMigrationRuntime *migrationRuntime = [[BZObjectStoreMigrationRuntime alloc]init];
        migrationRuntime.clazzName = runtime.clazzName;
        migrationRuntime.previousRuntime = runtime;
        BZObjectStoreRuntime *latestRuntime = [newestRuntimes objectForKey:runtime.clazzName];
        migrationRuntime.latestRuntime = latestRuntime;
        migrationRuntime.attributes = [NSMutableDictionary dictionary];
        [migrationRuntimes setObject:migrationRuntime forKey:migrationRuntime.clazzName];
    }

    // プロパティを列挙する
    for (BZObjectStoreMigrationRuntime *migrationRuntime in migrationRuntimes.allValues) {
        BZObjectStoreRuntime *latestRuntime = migrationRuntime.latestRuntime;
        for (BZObjectStoreRuntimeProperty *attribute in latestRuntime.attributes) {
            BZObjectStoreMigrationRuntimeProperty *migrationAttribute = [migrationRuntime.attributes objectForKey:attribute.name];
            if (!migrationAttribute) {
                migrationAttribute = [[BZObjectStoreMigrationRuntimeProperty alloc]init];
                migrationAttribute.name = attribute.name;
                [migrationRuntime.attributes setObject:migrationAttribute forKey:attribute.name];
            }
            migrationAttribute.latestAttbiute = attribute;
        }
        BZObjectStoreRuntime *previousRuntime = migrationRuntime.previousRuntime;
        for (BZObjectStoreRuntimeProperty *attribute in previousRuntime.attributes) {
            BZObjectStoreMigrationRuntimeProperty *migrationAttribute = [migrationRuntime.attributes objectForKey:attribute.name];
            if (!migrationAttribute) {
                migrationAttribute = [[BZObjectStoreMigrationRuntimeProperty alloc]init];
                migrationAttribute.name = attribute.name;
                [migrationRuntime.attributes setObject:migrationAttribute forKey:attribute.name];
            }
            migrationAttribute.previousAttribute = attribute;
        }
    }

    // プロパティの変更情報を取得する
    for (BZObjectStoreMigrationRuntime *migrationRuntime in migrationRuntimes.allValues) {
        for (BZObjectStoreMigrationRuntimeProperty *migrationAttribute in migrationRuntime.attributes.allValues) {
            migrationAttribute.added = migrationAttribute.latestAttbiute && !migrationAttribute.previousAttribute;
            migrationAttribute.deleted = !migrationAttribute.latestAttbiute && migrationAttribute.previousAttribute;
            migrationAttribute.typeChanged = ![migrationAttribute.latestAttbiute.attributeType isEqualToString:migrationAttribute.previousAttribute.attributeType];
            if (migrationAttribute.deleted) {
                migrationRuntime.changed = YES;
            } else if (migrationAttribute.added) {
                migrationRuntime.changed = YES;
            } else if (migrationAttribute.typeChanged) {
                migrationRuntime.changed = YES;
            }
        }
        if (migrationRuntime.latestRuntime && migrationRuntime.previousRuntime) {
            if (![migrationRuntime.latestRuntime.tableName isEqualToString:migrationRuntime.previousRuntime.tableName]) {
                migrationRuntime.tableNameChanged = YES;
                migrationRuntime.changed = YES;
            }
        } else if (migrationRuntime.latestRuntime && !migrationRuntime.previousRuntime) {
            migrationRuntime.added = YES;
            migrationRuntime.changed = YES;
        } else if (!migrationRuntime.latestRuntime && migrationRuntime.previousRuntime) {
            migrationRuntime.deleted = YES;
            migrationRuntime.changed = YES;
        }
    }

    // マイグレーションするテーブル一覧を作成する
    NSMutableDictionary *migrationTables = [NSMutableDictionary dictionary];
    for (BZObjectStoreMigrationRuntime *migrationRuntime in migrationRuntimes.allValues) {
        if (migrationRuntime.changed) {
            // 新テーブルの情報
            NSString *tableName = migrationRuntime.latestRuntime.tableName;
            BZObjectStoreMigrationTable *migrationTable = [migrationTables objectForKey:tableName];
            if (!migrationTable) {
                migrationTable = [[BZObjectStoreMigrationTable alloc]init];
                migrationTable.tableName = migrationRuntime.latestRuntime.tableName;
                migrationTable.temporaryTableName = [NSString stringWithFormat:@"__%@__",migrationRuntime.latestRuntime.tableName];
                migrationTable.previousTables = [NSMutableDictionary dictionary];
                migrationTable.columns = [NSMutableDictionary dictionary];
                migrationTable.identicalColumns = [NSMutableDictionary dictionary];
            }
            migrationTable.fullTextSearch3 = migrationRuntime.latestRuntime.fullTextSearch3;
            migrationTable.fullTextSearch4 = migrationRuntime.latestRuntime.fullTextSearch4;
            [migrationTables setObject:migrationTable forKey:migrationTable.tableName];
            for (BZObjectStoreMigrationRuntimeProperty *migrationAttribute in migrationRuntime.attributes.allValues) {
                for (BZObjectStoreSQLiteColumnModel *sqlColumn in migrationAttribute.latestAttbiute.sqliteColumns) {
                    [migrationTable.columns setObject:sqlColumn forKey:sqlColumn.columnName];
                    if (migrationAttribute.latestAttbiute.identicalAttribute) {
                        [migrationTable.identicalColumns setObject:sqlColumn forKey:sqlColumn.columnName];
                    }
                }
            }
            if (migrationRuntime.previousRuntime) {
                // 新テーブルの情報
                BZObjectStoreMigrationTable *previousMigrationTable = [migrationTable.previousTables objectForKey:migrationRuntime.previousRuntime.tableName];
                if (!previousMigrationTable) {
                    previousMigrationTable = [[BZObjectStoreMigrationTable alloc]init];
                    previousMigrationTable.tableName = migrationRuntime.previousRuntime.tableName;
                    previousMigrationTable.temporaryTableName = [NSString stringWithFormat:@"__%@__",migrationRuntime.previousRuntime.tableName];
                    previousMigrationTable.previousTables = [NSMutableDictionary dictionary];
                    previousMigrationTable.columns = [NSMutableDictionary dictionary];
                    previousMigrationTable.identicalColumns = [NSMutableDictionary dictionary];
                }
                [migrationTable.previousTables setObject:previousMigrationTable forKey:previousMigrationTable.tableName];
                for (BZObjectStoreMigrationRuntimeProperty *migrationAttribute in migrationRuntime.attributes.allValues) {
                    for (BZObjectStoreSQLiteColumnModel *sqlColumn in migrationAttribute.previousAttribute.sqliteColumns) {
                        [previousMigrationTable.columns setObject:sqlColumn forKey:sqlColumn.columnName];
                        if (!migrationAttribute.deleted && !migrationAttribute.typeChanged && !migrationAttribute.added) {
                            [migrationTable.migrateColumns setObject:sqlColumn forKey:sqlColumn.columnName];
                        }
                    }
                }
            }
        }
    }
    
    // テーブルのマイグレーション方法を取得する
    for (BZObjectStoreMigrationTable *latestMigrationTable in migrationTables.allValues) {
        for (BZObjectStoreMigrationTable *previousMigrationTable in latestMigrationTable.previousTables.allValues) {
            latestMigrationTable.deletedTarget = YES;
            BZObjectStoreMigrationTable *table = [migrationTables objectForKey:previousMigrationTable.tableName];
            if (table) {
                latestMigrationTable.deletedTarget = NO;
                break;
            }
        }
    }

    // マイグレーション開始
    for (BZObjectStoreMigrationTable *migrationTable in migrationTables.allValues) {
        if (!migrationTable.deletedTarget) {

            // 一時テーブル作成
            NSString *createTableSql = [BZObjectStoreMigrationQueryBuilder createTableStatementWithMigrationTable:migrationTable];
//            [db executeStatements:createTableSql];
//            if (![self hadError:db error:error]) {
//                return;
//            }
            
            // 一時テーブルのデータ削除
            NSString *deleteTableSql = [BZObjectStoreMigrationQueryBuilder deleteFromStatementWithMigrationTable:migrationTable];
//            [db executeStatements:deleteTableSql];
//            if (![self hadError:db error:error]) {
//                return;
//            }
            
            // 一時インデックス作成
            NSString *createIndexSql = [BZObjectStoreMigrationQueryBuilder createUniqueIndexStatementWithMigrationTable:migrationTable];
//            [db executeStatements:createIndexSql];
//            if (![self hadError:db error:error]) {
//                return;
//            }
            
            for (BZObjectStoreMigrationTable *previousMigrationTable in migrationTable.previousTables) {
                
                // データコピー
                NSString *selectInsertSql = [BZObjectStoreMigrationQueryBuilder selectInsertStatementWithToMigrationTable:migrationTable fromMigrationTable:previousMigrationTable];
//                [db executeStatements:selectInsertSql];
//                if (![self hadError:db error:error]) {
//                    return;
//                }
                
                // 旧テーブル削除
                NSString *dropSql = [BZObjectStoreMigrationQueryBuilder dropTableStatementWithMigrationTable:previousMigrationTable];
//                [db executeStatements:dropSql];
//                if (![self hadError:db error:error]) {
//                    return;
//                }
                
            }
            
            // 一時テーブルの名前変更
            NSString *renameSql = [BZObjectStoreMigrationQueryBuilder alterTableRenameStatementWithMigrationTable:migrationTable];
//            [db executeStatements:renameSql];
//            if (![self hadError:db error:error]) {
//                return;
//            }
            
            // 一時インデックスの再作成
            NSString *dropIndexSql = [BZObjectStoreMigrationQueryBuilder dropIndexStatementWithMigrationTable:migrationTable];
//            [db executeStatements:dropIndexSql];
//            if (![self hadError:db error:error]) {
//                return;
//            }

        } else {
            
        }
        
    }
    
    BZObjectStoreRuntime *relationshipRuntime = [self runtime:[BZObjectStoreRelationshipModel class]];
    for (BZObjectStoreMigrationRuntime *migrationRuntime in migrationRuntimes.allValues) {
        // リレーション情報の削除
        for (BZObjectStoreMigrationRuntimeProperty *attribute in migrationRuntime.attributes.allValues) {
            BOOL deleteRelashionship = NO;
            if (attribute.deleted) {
                deleteRelashionship = YES;
            } else if (attribute.typeChanged) {
                if (attribute.previousAttribute.isRelationshipClazz || attribute.latestAttbiute.isRelationshipClazz ) {
                    deleteRelashionship = YES;
                }
            }
            if (deleteRelashionship) {
                [self deleteRelationshipObjectsWithClazzName:migrationRuntime.clazzName attribute:attribute.previousAttribute relationshipRuntime:relationshipRuntime db:db];
            }
        }
        // アトリビュート情報の更新
        if (migrationRuntime.deleted) {
            [self unRegisterRuntime:migrationRuntime.previousRuntime db:db error:error];
            if (![self hadError:db error:error]) {
                return;
            }
        } else if (migrationRuntime.changed) {
            [self registerRuntime:migrationRuntime.latestRuntime db:db error:error];
            if (![self hadError:db error:error]) {
                return;
            }
        }
    }

}

- (BOOL)hadError:(FMDatabase*)db error:(NSError**)error
{
    if ([db hadError]) {
        return YES;
    } else if (error) {
        if (*error) {
            return YES;
        }
    }
    return NO;
}

@end
