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

#import "BZObjectStoreClazzNSRange.h"
#import <FMResultSet.h>
#import "BZObjectStoreConst.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreSQLiteColumnModel.h"

@implementation BZObjectStoreClazzNSRange

- (NSString*)attributeType
{
    return @"_NSRange";
}
- (BOOL)isSimpleValueClazz
{
    return YES;
}


- (NSArray*)sqliteColumnsWithAttribute:(BZObjectStoreRuntimeProperty *)attribute
{
    BZObjectStoreSQLiteColumnModel *length = [[BZObjectStoreSQLiteColumnModel alloc]init];
    length.columnName = [NSString stringWithFormat:@"%@_length",attribute.columnName];
    length.dataTypeName = [self sqliteDataTypeName];
    
    BZObjectStoreSQLiteColumnModel *location = [[BZObjectStoreSQLiteColumnModel alloc]init];
    location.columnName = [NSString stringWithFormat:@"%@_location",attribute.columnName];
    location.dataTypeName = [self sqliteDataTypeName];
    
    return @[length,location];
}

- (NSArray*)storeValuesWithValue:(NSValue*)value attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    NSRange range = [value rangeValue];
    NSNumber *length = [NSNumber numberWithUnsignedInteger:range.length];
    NSNumber *location = [NSNumber numberWithUnsignedInteger:range.location];
    return @[length,location];
}

- (id)valueWithResultSet:(FMResultSet*)resultSet attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *columnNameLength = [NSString stringWithFormat:@"%@_length",attribute.columnName];
    NSString *columnNameLocation = [NSString stringWithFormat:@"%@_location",attribute.columnName];
    NSRange range;
    range.length = [resultSet longForColumn:columnNameLength];
    range.location = [resultSet longForColumn:columnNameLocation];
    return [NSValue valueWithRange:range];
    
}

- (NSString*)sqliteDataTypeName
{
    return SQLITE_DATA_TYPE_INTEGER;
}

@end
