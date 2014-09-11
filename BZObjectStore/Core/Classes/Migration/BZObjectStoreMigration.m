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
- (BOOL)saveObjects:(NSArray*)objects db:(FMDatabase*)db error:(NSError**)error;
- (BOOL)deleteObjects:(NSArray*)objects db:(FMDatabase*)db error:(NSError**)error;
- (BZObjectStoreRuntime*)runtime:(Class)clazz;
- (BOOL)hadError:(FMDatabase*)db error:(NSError**)error;
@end

@interface BZObjectStoreModelMapper (Private)
- (BOOL)deleteRelationshipObjectsWithClazzName:(NSString*)className attribute:(BZObjectStoreRuntimeProperty*)attribute relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db;
- (BOOL)deleteRelationshipObjectsWithClazzName:(NSString*)className relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db;
@end

@implementation BZObjectStoreMigration

- (BOOL)migrate:(FMDatabase*)db error:(NSError**)error
{
    
    // Get previous class and current class information
    NSMutableDictionary *currentRuntimes = [NSMutableDictionary dictionary];
    NSMutableArray *previousRuntimes = [self fetchObjects:[BZObjectStoreRuntime class] condition:nil db:db error:error];
    for (BZObjectStoreRuntime *runtime in previousRuntimes) {
        Class clazz = NSClassFromString(runtime.clazzName);
        if (clazz) {
            BZObjectStoreRuntime *currentRuntime = [self runtime:clazz];
            [currentRuntimes setObject:currentRuntime forKey:currentRuntime.clazzName];
        }
    }
	
    // create migration list
    NSMutableDictionary *migrationRuntimes = [NSMutableDictionary dictionary];
    for (BZObjectStoreRuntime *runtime in previousRuntimes) {
        BZObjectStoreMigrationRuntime *migrationRuntime = [[BZObjectStoreMigrationRuntime alloc]init];
        migrationRuntime.clazzName = runtime.clazzName;
        migrationRuntime.previousRuntime = runtime;
        BZObjectStoreRuntime *latestRuntime = [currentRuntimes objectForKey:runtime.clazzName];
        migrationRuntime.latestRuntime = latestRuntime;
        migrationRuntime.attributes = [NSMutableDictionary dictionary];
        [migrationRuntimes setObject:migrationRuntime forKey:migrationRuntime.clazzName];
    }
	
    // create migration property list
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
	
    // get migration type
    for (BZObjectStoreMigrationRuntime *migrationRuntime in migrationRuntimes.allValues) {
        for (BZObjectStoreMigrationRuntimeProperty *migrationAttribute in migrationRuntime.attributes.allValues) {
            migrationAttribute.added = migrationAttribute.latestAttbiute && !migrationAttribute.previousAttribute;
            migrationAttribute.deleted = !migrationAttribute.latestAttbiute && migrationAttribute.previousAttribute;
            migrationAttribute.typeChanged = ![migrationAttribute.latestAttbiute.attributeType isEqualToString:migrationAttribute.previousAttribute.attributeType];
            migrationAttribute.columnNameChanged = ![migrationAttribute.latestAttbiute.columnName isEqualToString:migrationAttribute.previousAttribute.columnName];
            if (migrationAttribute.deleted) {
                migrationRuntime.changed = YES;
            } else if (migrationAttribute.added) {
                migrationRuntime.changed = YES;
            } else if (migrationAttribute.typeChanged) {
                migrationRuntime.changed = YES;
            } else if (migrationAttribute.columnNameChanged) {
                migrationRuntime.changed = YES;
            }
        }
        if (migrationRuntime.latestRuntime && migrationRuntime.previousRuntime) {
            if (![migrationRuntime.latestRuntime.tableName isEqualToString:migrationRuntime.previousRuntime.tableName]) {
                migrationRuntime.tableNameChanged = YES;
                migrationRuntime.changed = YES;
            }
        } else if (!migrationRuntime.latestRuntime && migrationRuntime.previousRuntime) {
            migrationRuntime.deleted = YES;
        }
        
    }
	
    // get table list
    NSMutableDictionary *previousMigrationTables = [NSMutableDictionary dictionary];
    NSMutableDictionary *migrationTables = [NSMutableDictionary dictionary];
    for (BZObjectStoreMigrationRuntime *migrationRuntime in migrationRuntimes.allValues) {
        if (migrationRuntime.changed) {
            
            BZObjectStoreMigrationTable *migrationTable = nil;
            if (migrationRuntime.latestRuntime) {
                NSString *tableName = migrationRuntime.latestRuntime.tableName;
                migrationTable = [migrationTables objectForKey:tableName];
                if (!migrationTable) {
                    migrationTable = [[BZObjectStoreMigrationTable alloc]init];
                    migrationTable.tableName = migrationRuntime.latestRuntime.tableName;
                    migrationTable.temporaryTableName = [NSString stringWithFormat:@"__%@__",migrationRuntime.latestRuntime.tableName];
                    migrationTable.previousTables = [NSMutableDictionary dictionary];
                    migrationTable.attributes = [NSMutableDictionary dictionary];
                    migrationTable.identicalAttributes = [NSMutableDictionary dictionary];
                }
                migrationTable.fullTextSearch3 = migrationRuntime.latestRuntime.fullTextSearch3;
                migrationTable.fullTextSearch4 = migrationRuntime.latestRuntime.fullTextSearch4;
                [migrationTables setObject:migrationTable forKey:migrationTable.tableName];
                for (BZObjectStoreMigrationRuntimeProperty *migrationAttribute in migrationRuntime.attributes.allValues) {
                    [migrationTable.attributes setObject:migrationAttribute forKey:migrationAttribute.name];
                    if (migrationAttribute.latestAttbiute.identicalAttribute) {
                        [migrationTable.identicalAttributes setObject:migrationAttribute forKey:migrationAttribute.name];
                    }
                }
            }
            
            BZObjectStoreMigrationTable *previousMigrationTable =nil;
            if (migrationRuntime.previousRuntime) {
                previousMigrationTable = [migrationTable.previousTables objectForKey:migrationRuntime.previousRuntime.tableName];
                if (!previousMigrationTable) {
                    previousMigrationTable = [[BZObjectStoreMigrationTable alloc]init];
                    previousMigrationTable.tableName = migrationRuntime.previousRuntime.tableName;
                    previousMigrationTable.temporaryTableName = [NSString stringWithFormat:@"__%@__",migrationRuntime.previousRuntime.tableName];
                    previousMigrationTable.previousTables = [NSMutableDictionary dictionary];
                    previousMigrationTable.attributes = [NSMutableDictionary dictionary];
                    previousMigrationTable.migrateAttributes = [NSMutableDictionary dictionary];
                    previousMigrationTable.identicalAttributes = [NSMutableDictionary dictionary];
                }
                for (BZObjectStoreMigrationRuntimeProperty *migrationAttribute in migrationRuntime.attributes.allValues) {
                    [previousMigrationTable.attributes setObject:migrationAttribute forKey:migrationAttribute.name];
                    if (!migrationAttribute.deleted && !migrationAttribute.typeChanged && !migrationAttribute.added) {
                        [previousMigrationTable.migrateAttributes setObject:migrationAttribute forKey:migrationAttribute.name];
                    }
                }
            }
            if (migrationTable && previousMigrationTable) {
                [migrationTable.previousTables setObject:previousMigrationTable forKey:previousMigrationTable.tableName];
            }
            if (previousMigrationTable) {
                [previousMigrationTables setObject:previousMigrationTable forKey:previousMigrationTable.tableName];
            }
        }
    }
    
    // get table migration type
    for (BZObjectStoreMigrationTable *previousMigrationTable in previousMigrationTables.allValues) {
        previousMigrationTable.deleted = YES;
        for (BZObjectStoreMigrationTable *latestMigrationTable in migrationTables.allValues) {
            if ([previousMigrationTable.tableName isEqualToString:latestMigrationTable.tableName]) {
                previousMigrationTable.deleted = NO;
                break;
            }
        }
    }
	
    // start migration
    
    // delete relationship information
    BZObjectStoreRuntime *relationshipRuntime = [self runtime:[BZObjectStoreRelationshipModel class]];
    for (BZObjectStoreMigrationRuntime *migrationRuntime in migrationRuntimes.allValues) {
        if (migrationRuntime.changed) {
            for (BZObjectStoreMigrationRuntimeProperty *attribute in migrationRuntime.attributes.allValues) {
                BOOL deleteRelashionship = NO;
                if (attribute.deleted) {
                    if (attribute.previousAttribute.isRelationshipClazz ) {
                        deleteRelashionship = YES;
                    }
                } else if (attribute.typeChanged) {
                    if (attribute.previousAttribute.isRelationshipClazz && !attribute.latestAttbiute.isRelationshipClazz ) {
                        deleteRelashionship = YES;
                    }
                }
                if (deleteRelashionship) {
                    [self deleteRelationshipObjectsWithClazzName:migrationRuntime.clazzName attribute:attribute.previousAttribute relationshipRuntime:relationshipRuntime db:db];
                }
            }
        } else if (migrationRuntime.deleted) {
            [self deleteRelationshipObjectsWithClazzName:migrationRuntime.clazzName relationshipRuntime:relationshipRuntime db:db];
        }
    }
    
    // update runtime information
    for (BZObjectStoreMigrationRuntime *migrationRuntime in migrationRuntimes.allValues) {
        if (migrationRuntime.changed) {
            [self saveObjects:@[migrationRuntime.latestRuntime] db:db error:error];
            if ([self hadError:db error:error]) {
                return NO;
            }
        } else if (migrationRuntime.deleted) {
            [self deleteObjects:@[migrationRuntime.latestRuntime] db:db error:error];
            if ([self hadError:db error:error]) {
                return NO;
            }
        }
    }
    
    // update tableName
    for (BZObjectStoreMigrationRuntime *migrationRuntime in migrationRuntimes.allValues) {
        if (migrationRuntime.tableNameChanged) {
			
            // fromTableName
            NSString *updateFromTableName = [BZObjectStoreMigrationQueryBuilder updateRelationshipFromTableName:migrationRuntime.latestRuntime.tableName clazzName:migrationRuntime.clazzName];
            [db executeStatements:updateFromTableName];
            if ([self hadError:db error:error]) {
                return NO;
            }
			
            // toTableName
            NSString *updateToTableName = [BZObjectStoreMigrationQueryBuilder updateRelationshipToTableName:migrationRuntime.latestRuntime.tableName clazzName:migrationRuntime.clazzName];
            [db executeStatements:updateToTableName];
            if ([self hadError:db error:error]) {
                return NO;
            }
			
        }
    }
    
    // migration table
    for (BZObjectStoreMigrationTable *migrationTable in migrationTables.allValues) {
        
        // create temporary table
        NSString *createTempTableSql = [BZObjectStoreMigrationQueryBuilder createTempTableStatementWithMigrationTable:migrationTable];
        [db executeStatements:createTempTableSql];
        if ([self hadError:db error:error]) {
            return NO;
        }
        
        // delte temporary table data
        NSString *deleteTempTableSql = [BZObjectStoreMigrationQueryBuilder deleteFromStatementWithMigrationTable:migrationTable];
        [db executeStatements:deleteTempTableSql];
        if ([self hadError:db error:error]) {
            return NO;
        }
        
        // create temporary index
        NSString *createTempIndexSql = [BZObjectStoreMigrationQueryBuilder createTemporaryUniqueIndexStatementWithMigrationTable:migrationTable];
        [db executeStatements:createTempIndexSql];
        if ([self hadError:db error:error]) {
            return NO;
        }
        
        for (BZObjectStoreMigrationTable *previousMigrationTable in migrationTable.previousTables.allValues) {
            
            // copy data from previous to current table
            NSString *selectInsertSql = [BZObjectStoreMigrationQueryBuilder selectInsertStatementWithToMigrationTable:migrationTable fromMigrationTable:previousMigrationTable];
            [db executeStatements:selectInsertSql];
            if ([self hadError:db error:error]) {
                return NO;
            }
            
            // drop previous table
            if (previousMigrationTable.deleted) {
                NSString *dropSql = [BZObjectStoreMigrationQueryBuilder dropTableStatementWithMigrationTable:previousMigrationTable];
                [db executeStatements:dropSql];
                if ([self hadError:db error:error]) {
                    return NO;
                }
            }
            
        }
        
        // drop temporary index
        NSString *dropIndexSql = [BZObjectStoreMigrationQueryBuilder dropTempIndexStatementWithMigrationTable:migrationTable];
        [db executeStatements:dropIndexSql];
        if ([self hadError:db error:error]) {
            return NO;
        }
        
        // drop table
        NSString *dropSql = [BZObjectStoreMigrationQueryBuilder dropTableStatementWithMigrationTable:migrationTable];
        [db executeStatements:dropSql];
        if ([self hadError:db error:error]) {
            return NO;
        }
		
        // rename temporary table
        NSString *renameSql = [BZObjectStoreMigrationQueryBuilder alterTableRenameStatementWithMigrationTable:migrationTable];
        [db executeStatements:renameSql];
        if ([self hadError:db error:error]) {
            return NO;
        }
        
        // create index
        NSString *createIndexSql = [BZObjectStoreMigrationQueryBuilder createUniqueIndexStatementWithMigrationTable:migrationTable];
        [db executeStatements:createIndexSql];
        if ([self hadError:db error:error]) {
            return NO;
        }
    }
    
	return YES;
	
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
