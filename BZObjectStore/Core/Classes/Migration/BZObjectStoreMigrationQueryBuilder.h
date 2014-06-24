//
//  BZObjectStoreMigrationQueryBuilder.h
//  BZObjectStore
//
//  Created by SHIMADATAKESHI on 2014/06/22.
//  Copyright (c) 2014年 BONZOO INC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BZObjectStoreMigrationTable;

@interface BZObjectStoreMigrationQueryBuilder : NSObject

+ (NSString*)createTableStatementWithMigrationTable:(BZObjectStoreMigrationTable*)migrationTable;
+ (NSString*)createTemporaryUniqueIndexStatementWithMigrationTable:(BZObjectStoreMigrationTable*)migrationTable;
+ (NSString*)createUniqueIndexStatementWithMigrationTable:(BZObjectStoreMigrationTable*)migrationTable;
+ (NSString*)selectInsertStatementWithToMigrationTable:(BZObjectStoreMigrationTable*)toMigrationTable fromMigrationTable:(BZObjectStoreMigrationTable*)fromMigrationTable;
+ (NSString*)deleteFromStatementWithMigrationTable:(BZObjectStoreMigrationTable*)migrationTable;
+ (NSString*)dropTableStatementWithMigrationTable:(BZObjectStoreMigrationTable*)migrationTable;
+ (NSString*)dropIndexStatementWithMigrationTable:(BZObjectStoreMigrationTable*)migrationTable;
+ (NSString*)alterTableRenameStatementWithMigrationTable:(BZObjectStoreMigrationTable*)migrationTable;

@end
