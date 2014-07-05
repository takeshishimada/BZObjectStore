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

#import "BZObjectStoreClazzCGRect.h"
#import <FMResultSet.h>
#import "BZObjectStoreConst.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreSQLiteColumnModel.h"

@implementation BZObjectStoreClazzCGRect

- (NSString*)attributeType
{
    return @"CGRect";
}
- (BOOL)isSimpleValueClazz
{
    return YES;
}

- (NSArray*)sqliteColumnsWithAttribute:(BZObjectStoreRuntimeProperty *)attribute
{
    BZObjectStoreSQLiteColumnModel *x = [[BZObjectStoreSQLiteColumnModel alloc]init];
    x.columnName = [NSString stringWithFormat:@"%@_x",attribute.columnName];
    x.dataTypeName = [self sqliteDataTypeName];
    
    BZObjectStoreSQLiteColumnModel *y = [[BZObjectStoreSQLiteColumnModel alloc]init];
    y.columnName = [NSString stringWithFormat:@"%@_y",attribute.columnName];
    y.dataTypeName = [self sqliteDataTypeName];
    
    BZObjectStoreSQLiteColumnModel *width = [[BZObjectStoreSQLiteColumnModel alloc]init];
    width.columnName = [NSString stringWithFormat:@"%@_width",attribute.columnName];
    width.dataTypeName = [self sqliteDataTypeName];
    
    BZObjectStoreSQLiteColumnModel *height = [[BZObjectStoreSQLiteColumnModel alloc]init];
    height.columnName = [NSString stringWithFormat:@"%@_height",attribute.columnName];
    height.dataTypeName = [self sqliteDataTypeName];
    
    return @[x,y,width,height];
}

- (NSArray*)storeValuesWithValue:(NSValue*)value attribute:(BZObjectStoreRuntimeProperty*)attribute
{
#if TARGET_OS_IPHONE
    CGRect rect = [value CGRectValue];
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
    NSRect rect = [value rectValue];
#endif
    NSNumber *x = nil;
    NSNumber *y = nil;
    NSNumber *width = nil;
    NSNumber *height = nil;
#if CGFLOAT_IS_DOUBLE
    x = [NSNumber numberWithDouble:rect.origin.x];
    y = [NSNumber numberWithDouble:rect.origin.y];
    width = [NSNumber numberWithDouble:rect.size.width];
    height = [NSNumber numberWithDouble:rect.size.height];
#else
    x = [NSNumber numberWithFloat:rect.origin.x];
    y = [NSNumber numberWithFloat:rect.origin.y];
    width = [NSNumber numberWithFloat:rect.size.width];
    height = [NSNumber numberWithFloat:rect.size.height];
#endif
    return @[x,y,width,height];
}

- (id)valueWithResultSet:(FMResultSet*)resultSet attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *columnNameX = [NSString stringWithFormat:@"%@_x",attribute.columnName];
    NSString *columnNameY = [NSString stringWithFormat:@"%@_y",attribute.columnName];
    NSString *columnNameWidth = [NSString stringWithFormat:@"%@_width",attribute.columnName];
    NSString *columnNameHeight = [NSString stringWithFormat:@"%@_height",attribute.columnName];
#if TARGET_OS_IPHONE
    CGRect rect;
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
    NSRect rect;
#endif
    rect.origin.x = [resultSet doubleForColumn:columnNameX];
    rect.origin.y = [resultSet doubleForColumn:columnNameY];
    rect.size.width = [resultSet doubleForColumn:columnNameWidth];
    rect.size.height = [resultSet doubleForColumn:columnNameHeight];
#if TARGET_OS_IPHONE
    return [NSValue valueWithCGRect:rect];
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
    return [NSValue valueWithRect:rect];
#endif
}

- (NSString*)sqliteDataTypeName
{
    return SQLITE_DATA_TYPE_REAL;
}

@end
