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

#import "BZObjectStoreRuntimeMapper.h"
#import "BZObjectStoreModelInterface.h"
#import "BZObjectStoreRelationshipModel.h"
#import "BZObjectStoreAttributeModel.h"
#import "BZObjectStoreConditionModel.h"
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

@interface BZObjectStoreRuntimeMapper()
@property (nonatomic,strong) NSMutableDictionary *registedClazzes;
@property (nonatomic,strong) BZObjectStoreNameBuilder *nameBuilder;
@end

@implementation BZObjectStoreRuntimeMapper

+ (NSString*)ignorePrefixName
{
    return nil;
}

+ (NSString*)ignoreSuffixName
{
    return nil;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.registedClazzes = [NSMutableDictionary dictionary];
        BZObjectStoreNameBuilder *nameBuilder = [[BZObjectStoreNameBuilder alloc]init];
        Class clazz = self.class;
        nameBuilder.ignorePrefixName = [clazz ignorePrefixName];
        nameBuilder.ignoreSuffixName = [clazz ignoreSuffixName];
        self.nameBuilder = nameBuilder;
    }
    return self;
}

- (BZObjectStoreRuntime*)runtime:(Class)clazz
{
    if (clazz == NULL) {
        return nil;
    }
    BZObjectStoreRuntime *runtime = [BZObjectStoreRuntime runtimeWithClazz:clazz nameBuilder:self.nameBuilder];
    return runtime;
}

- (void)registedRuntime:(BZObjectStoreRuntime*)runtime
{
    [self.registedClazzes setObject:@YES forKey:runtime.clazzName];
}

- (void)unRegistedRuntime:(BZObjectStoreRuntime*)runtime
{
    [self.registedClazzes removeObjectForKey:runtime.clazzName];
}

- (void)registedAllRuntime
{
    for (NSString *key in self.registedClazzes.allKeys) {
        [self.registedClazzes setObject:@YES forKey:key];
    }
}

- (BOOL)registerRuntime:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db
{
    NSNumber *registed = [self.registedClazzes objectForKey:runtime.clazzName];
    if (registed.boolValue) {
        return YES;
    }
    BZObjectStoreRuntime *attributeRuntime = [self runtime:[BZObjectStoreAttributeModel class]];
    [self createTable:runtime attributeRuntime:attributeRuntime db:db];
    if ([self hadError:db]) {
        return NO;
    }
    [self.registedClazzes setObject:@NO forKey:runtime.clazzName];
    return YES;
}

- (BOOL)unRegisterRuntime:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db
{
    NSNumber *registed = [self.registedClazzes objectForKey:runtime.clazzName];
    if (!registed.boolValue) {
        return YES;
    }
    [self dropTable:runtime db:db];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

- (BOOL)createTable:(BZObjectStoreRuntime*)runtime attributeRuntime:(BZObjectStoreRuntime*)attributeRuntime db:(FMDatabase*)db
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
        [self createAtributeTable:runtime attributeRuntime:attributeRuntime db:db];
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
            [self createAtributeTable:runtime attributeRuntime:attributeRuntime db:db];
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

- (BOOL)createAtributeTable:(BZObjectStoreRuntime*)runtime attributeRuntime:(BZObjectStoreRuntime*)attributeRuntime db:(FMDatabase*)db
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

- (BOOL)hadError:(FMDatabase*)db
{
    if ([db hadError]) {
        return YES;
    } else {
        return NO;
    }
}

@end
