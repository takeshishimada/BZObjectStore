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

#import "BZObjectStoreClazzCGSize.h"
#import <FMResultSet.h>
#import "BZObjectStoreConst.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreSQLiteColumnModel.h"

@implementation BZObjectStoreClazzCGSize

- (NSString*)attributeType
{
    return @"CGSize";
}
- (BOOL)isSimpleValueClazz
{
    return YES;
}

- (NSArray*)sqliteColumnsWithAttribute:(BZObjectStoreRuntimeProperty *)attribute
{
    BZObjectStoreSQLiteColumnModel *width = [[BZObjectStoreSQLiteColumnModel alloc]init];
    width.columnName = [NSString stringWithFormat:@"%@_width",attribute.columnName];
    width.dataTypeName = [self sqliteDataTypeName];
    
    BZObjectStoreSQLiteColumnModel *height = [[BZObjectStoreSQLiteColumnModel alloc]init];
    height.columnName = [NSString stringWithFormat:@"%@_height",attribute.columnName];
    height.dataTypeName = [self sqliteDataTypeName];
    
    return @[width,height];
}

- (NSArray*)storeValuesWithValue:(NSValue*)value attribute:(BZObjectStoreRuntimeProperty*)attribute
{
#if TARGET_OS_IPHONE
    CGSize size = [value CGSizeValue];
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
    NSSize size = [value sizeValue];
#endif
    NSNumber *width = nil;
    NSNumber *height = nil;
#if CGFLOAT_IS_DOUBLE
    width = [NSNumber numberWithDouble:size.width];
    height = [NSNumber numberWithDouble:size.height];
#else
    width = [NSNumber numberWithFloat:size.width];
    height = [NSNumber numberWithFloat:size.height];
#endif
    return @[width,height];
}

- (id)valueWithResultSet:(FMResultSet*)resultSet attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *columnNameWidth = [NSString stringWithFormat:@"%@_width",attribute.columnName];
    NSString *columnNameHeight = [NSString stringWithFormat:@"%@_height",attribute.columnName];
#if TARGET_OS_IPHONE
    CGSize size;
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
    NSSize size;
#endif
    size.width = [resultSet doubleForColumn:columnNameWidth];
    size.height = [resultSet doubleForColumn:columnNameHeight];
#if TARGET_OS_IPHONE
    return [NSValue valueWithCGSize:size];
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
    return [NSValue valueWithSize:size];
#endif
}

- (NSString*)sqliteDataTypeName
{
    return SQLITE_DATA_TYPE_REAL;
}

@end
