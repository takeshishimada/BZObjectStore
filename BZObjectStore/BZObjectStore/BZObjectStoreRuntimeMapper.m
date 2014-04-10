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

#import "BZObjectStoreRuntimeMapper.h"
#import "BZObjectStoreAttributeInterface.h"
#import "BZObjectStoreRelationshipModel.h"
#import "BZObjectStoreAttributeModel.h"
#import "BZObjectStoreFetchConditionModel.h"
#import "BZObjectStoreRuntime.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreNameBuilder.h"
#import "BZObjectStoreSQLiteColumnModel.h"
#import "BZObjectStoreError.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabase+TemporaryTable.h"
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
        nameBuilder.ignorePrefixName = [self.class ignorePrefixName];
        nameBuilder.ignoreSuffixName = [self.class ignoreSuffixName];
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

- (BOOL)registerAllRuntimes:(FMDatabase*)db
{
    NSArray *clazzNames = [self.registedClazzes allKeys];
    [self.registedClazzes removeAllObjects];
    for (NSString *clazzName in clazzNames) {
        Class clazz = NSClassFromString(clazzName);
        if (clazz) {
            BZObjectStoreRuntime *runtime = [self runtime:clazz];
            [self registerRuntime:runtime db:db];
            if ([self hadError:db]) {
                return NO;
            }
        }
    }
    for (NSString *clazzName in clazzNames) {
        [self.registedClazzes setObject:@YES forKey:clazzName];
    }
    return YES;
}

- (void)registedRuntime:(BZObjectStoreRuntime*)runtime
{
    [self.registedClazzes setObject:@YES forKey:runtime.clazzName];
}

- (BOOL)registerRuntime:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db
{
    NSNumber *registed = [self.registedClazzes objectForKey:runtime.clazzName];
    if (registed) {
        return YES;
    }
    [self createTable:runtime db:db];
    if ([self hadError:db]) {
        return NO;
    }
    return YES;
}

- (BOOL)createTable:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db
{
    BOOL tableExists = NO;
    if (!runtime.temporary) {
        tableExists = [db tableExists:runtime.tableName];
    } else {
        tableExists = [db temporaryTableExists:runtime.tableName];
    }
    if (!tableExists) {
        [db executeUpdate:[runtime createTableStatement]];
        if ([self hadError:db]) {
            return NO;
        }
        if (!runtime.fullTextSearch && runtime.hasIdentificationAttributes) {
            [db executeUpdate:[runtime createUniqueIndexStatement]];
            if ([self hadError:db]) {
                return NO;
            }
        }
        [self createAtributeTable:runtime db:db];
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
            if (!runtime.fullTextSearch) {
                NSArray *attributes = runtime.identificationAttributes;
                if (attributes.count > 0) {
                    [db executeUpdate:[runtime dropIndexStatement]];
                    if ([self hadError:db]) {
                        return NO;
                    }
                    [db executeUpdate:[runtime createUniqueIndexStatement]];
                    if ([self hadError:db]) {
                        return NO;
                    }
                }
            }
            [self createAtributeTable:runtime db:db];
            if ([self hadError:db]) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)createAtributeTable:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db
{
    if (runtime.clazz == [BZObjectStoreAttributeModel class]) {
        return YES;
    }
    if (runtime.clazz == [BZObjectStoreRelationshipModel class]) {
        return YES;
    }
    BZObjectStoreRuntime *attributeRuntime = [self runtime:[BZObjectStoreAttributeModel class]];
    BZObjectStoreFetchConditionModel *condition = [BZObjectStoreFetchConditionModel condition];
    condition.sqliteCondition.where = @"className = ?";
    condition.sqliteCondition.parameters = @[runtime.clazzName];
    NSString *deletesql = [attributeRuntime deleteFromStatementWithCondition:condition];
    [db executeUpdate:deletesql withArgumentsInArray:condition.sqliteCondition.parameters];
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
        NSLog(@"%@",[db lastError]);
        return YES;
    } else {
        return NO;
    }
}

@end
