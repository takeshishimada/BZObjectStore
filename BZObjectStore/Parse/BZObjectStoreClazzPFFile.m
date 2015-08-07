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

#import "BZObjectStoreClazzPFFile.h"
#import <FMDB/FMResultSet.h>
#import "BZObjectStoreConst.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreSQLiteColumnModel.h"
#import "BZObjectStoreParseImport.h"

@implementation BZObjectStoreClazzPFFile

- (Class)superClazz
{
    return [PFFile class];
}
- (NSString*)attributeType
{
    return NSStringFromClass([self superClazz]);
}
- (BOOL)isSimpleValueClazz
{
    return YES;
}

- (NSArray*)sqliteColumnsWithAttribute:(BZObjectStoreRuntimeProperty *)attribute
{
    BZObjectStoreSQLiteColumnModel *name = [[BZObjectStoreSQLiteColumnModel alloc]init];
    name.columnName = [NSString stringWithFormat:@"%@_name",attribute.columnName];
    name.dataTypeName = SQLITE_DATA_TYPE_TEXT;
    
    BZObjectStoreSQLiteColumnModel *data = [[BZObjectStoreSQLiteColumnModel alloc]init];
    data.columnName = [NSString stringWithFormat:@"%@_data",attribute.columnName];
    data.dataTypeName = SQLITE_DATA_TYPE_BLOB;
    
    return @[name,data];
}

- (NSArray*)storeValuesWithValue:(PFFile*)value attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *name = value.name;
    NSData *data = [value getData];
    return @[name,data];
}

- (id)valueWithResultSet:(FMResultSet*)resultSet attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *columnNameName = [NSString stringWithFormat:@"%@_name",attribute.columnName];
    NSString *columnNameData = [NSString stringWithFormat:@"%@_data",attribute.columnName];
    NSString *name = [resultSet stringForColumn:columnNameName];
    NSData *data = [resultSet dataForColumn:columnNameData];
    PFFile *file = [PFFile fileWithName:name data:data];
    return file;
    
}

@end
