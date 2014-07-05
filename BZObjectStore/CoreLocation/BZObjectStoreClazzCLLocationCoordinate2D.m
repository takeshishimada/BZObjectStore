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

#import "BZObjectStoreClazzCLLocationCoordinate2D.h"
#import <FMResultSet.h>
#import "BZObjectStoreConst.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreSQLiteColumnModel.h"
#import <CoreLocation/CoreLocation.h>

@implementation BZObjectStoreClazzCLLocationCoordinate2D

- (NSString*)attributeType
{
    return @"dd";
}
- (BOOL)isSimpleValueClazz
{
    return YES;
}

- (NSArray*)sqliteColumnsWithAttribute:(BZObjectStoreRuntimeProperty *)attribute
{
    BZObjectStoreSQLiteColumnModel *latitude = [[BZObjectStoreSQLiteColumnModel alloc]init];
    latitude.columnName = [NSString stringWithFormat:@"%@_latitude",attribute.columnName];
    latitude.dataTypeName = [self sqliteDataTypeName];
    
    BZObjectStoreSQLiteColumnModel *longitude = [[BZObjectStoreSQLiteColumnModel alloc]init];
    longitude.columnName = [NSString stringWithFormat:@"%@_longitude",attribute.columnName];
    longitude.dataTypeName = [self sqliteDataTypeName];
    
    return @[latitude,longitude];
}

- (NSArray*)storeValuesWithValue:(NSValue*)value attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    CLLocationCoordinate2D coordinate;
    [value getValue:&coordinate];
    NSNumber *latitude = [NSNumber numberWithDouble:coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:coordinate.longitude];
    return @[latitude,longitude];
}

- (id)valueWithResultSet:(FMResultSet*)resultSet attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *latitudeColumnName = [NSString stringWithFormat:@"%@_latitude",attribute.columnName];
    NSString *longitudeColumnName = [NSString stringWithFormat:@"%@_longitude",attribute.columnName];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [resultSet doubleForColumn:latitudeColumnName];
    coordinate.longitude = [resultSet doubleForColumn:longitudeColumnName];
    return [NSValue valueWithBytes:&coordinate objCType:@encode(CLLocationCoordinate2D)];
}

- (NSString*)sqliteDataTypeName
{
    return SQLITE_DATA_TYPE_REAL;
}

@end
