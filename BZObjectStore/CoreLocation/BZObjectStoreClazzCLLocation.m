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

#import "BZObjectStoreClazzCLLocation.h"
#import <FMResultSet.h>
#import "BZObjectStoreConst.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreSQLiteColumnModel.h"
#import <CoreLocation/CoreLocation.h>

@implementation BZObjectStoreClazzCLLocation

- (Class)superClazz
{
    return [CLLocation class];
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
    BZObjectStoreSQLiteColumnModel *altitude = [[BZObjectStoreSQLiteColumnModel alloc]init];
    altitude.columnName = [NSString stringWithFormat:@"%@_altitude",attribute.columnName];
    altitude.dataTypeName = [self sqliteDataTypeName];
    
    BZObjectStoreSQLiteColumnModel *latitude = [[BZObjectStoreSQLiteColumnModel alloc]init];
    latitude.columnName = [NSString stringWithFormat:@"%@_latitude",attribute.columnName];
    latitude.dataTypeName = [self sqliteDataTypeName];

    BZObjectStoreSQLiteColumnModel *longitude = [[BZObjectStoreSQLiteColumnModel alloc]init];
    longitude.columnName = [NSString stringWithFormat:@"%@_longitude",attribute.columnName];
    longitude.dataTypeName = [self sqliteDataTypeName];

    BZObjectStoreSQLiteColumnModel *course = [[BZObjectStoreSQLiteColumnModel alloc]init];
    course.columnName = [NSString stringWithFormat:@"%@_course",attribute.columnName];
    course.dataTypeName = [self sqliteDataTypeName];

    BZObjectStoreSQLiteColumnModel *horizontalAccuracy = [[BZObjectStoreSQLiteColumnModel alloc]init];
    horizontalAccuracy.columnName = [NSString stringWithFormat:@"%@_horizontalAccuracy",attribute.columnName];
    horizontalAccuracy.dataTypeName = [self sqliteDataTypeName];

    BZObjectStoreSQLiteColumnModel *speed = [[BZObjectStoreSQLiteColumnModel alloc]init];
    speed.columnName = [NSString stringWithFormat:@"%@_speed",attribute.columnName];
    speed.dataTypeName = [self sqliteDataTypeName];

    BZObjectStoreSQLiteColumnModel *timestamp = [[BZObjectStoreSQLiteColumnModel alloc]init];
    timestamp.columnName = [NSString stringWithFormat:@"%@_timestamp",attribute.columnName];
    timestamp.dataTypeName = [self sqliteDataTypeName];

    BZObjectStoreSQLiteColumnModel *verticalAccuracy = [[BZObjectStoreSQLiteColumnModel alloc]init];
    verticalAccuracy.columnName = [NSString stringWithFormat:@"%@_verticalAccuracy",attribute.columnName];
    verticalAccuracy.dataTypeName = [self sqliteDataTypeName];

    return @[altitude,latitude,longitude,course,horizontalAccuracy,speed,timestamp,verticalAccuracy];
}

- (NSArray*)storeValuesWithValue:(CLLocation*)value attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    if (value) {
        NSNumber *altitude = [NSNumber numberWithDouble:value.altitude];
        NSNumber *latitude = [NSNumber numberWithDouble:value.coordinate.latitude];
        NSNumber *longitude = [NSNumber numberWithDouble:value.coordinate.longitude];
        NSNumber *course = [NSNumber numberWithDouble:value.course];
        NSNumber *horizontalAccuracy = [NSNumber numberWithDouble:value.horizontalAccuracy];
        NSNumber *speed = [NSNumber numberWithDouble:value.speed];
        NSNumber *timestamp = [NSNumber numberWithDouble:[value.timestamp timeIntervalSince1970]];
        NSNumber *verticalAccuracy = [NSNumber numberWithDouble:value.verticalAccuracy];
        return @[altitude,latitude,longitude,course,horizontalAccuracy,speed,timestamp,verticalAccuracy];
    } else {
        return @[[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null]];
    }
}

- (id)valueWithResultSet:(FMResultSet*)resultSet attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *altitudeColumnName = [NSString stringWithFormat:@"%@_altitude",attribute.columnName];
    NSString *latitudeColumnName = [NSString stringWithFormat:@"%@_latitude",attribute.columnName];
    NSString *longitudeColumnName = [NSString stringWithFormat:@"%@_longitude",attribute.columnName];
    NSString *courseColumnName = [NSString stringWithFormat:@"%@_course",attribute.columnName];
    NSString *horizontalAccuracyColumnName = [NSString stringWithFormat:@"%@_horizontalAccuracy",attribute.columnName];
    NSString *speedColumnName = [NSString stringWithFormat:@"%@_speed",attribute.columnName];
    NSString *timestampColumnName = [NSString stringWithFormat:@"%@_timestamp",attribute.columnName];
    NSString *verticalAccuracyColumnName = [NSString stringWithFormat:@"%@_verticalAccuracy",attribute.columnName];
    id naltitude = [resultSet objectForColumnName:altitudeColumnName];
    id nlatitude = [resultSet objectForColumnName:latitudeColumnName];
    id nlongitude = [resultSet objectForColumnName:longitudeColumnName];
    id ncourse = [resultSet objectForColumnName:courseColumnName];
    id nhorizontalAccuracy = [resultSet objectForColumnName:horizontalAccuracyColumnName];
    id nspeed = [resultSet objectForColumnName:speedColumnName];
    id ntimestamp = [resultSet objectForColumnName:timestampColumnName];
    id nverticalAccuracy = [resultSet objectForColumnName:verticalAccuracyColumnName];
    NSNumber *altitude = nil;
    NSNumber *latitude = nil;
    NSNumber *longitude = nil;
    NSNumber *course = nil;
    NSNumber *horizontalAccuracy = nil;
    NSNumber *speed = nil;
    NSNumber *timestamp = nil;
    NSNumber *verticalAccuracy = nil;
    if ([[naltitude class]isSubclassOfClass:[NSNumber class]]) {
        altitude = naltitude;
    }
    if ([[nlatitude class]isSubclassOfClass:[NSNumber class]]) {
        latitude = nlatitude;
    }
    if ([[nlongitude class]isSubclassOfClass:[NSNumber class]]) {
        longitude = nlongitude;
    }
    if ([[ncourse class]isSubclassOfClass:[NSNumber class]]) {
        course = ncourse;
    }
    if ([[nhorizontalAccuracy class]isSubclassOfClass:[NSNumber class]]) {
        horizontalAccuracy = nhorizontalAccuracy;
    }
    if ([[nspeed class]isSubclassOfClass:[NSNumber class]]) {
        speed = nspeed;
    }
    if ([[ntimestamp class]isSubclassOfClass:[NSNumber class]]) {
        timestamp = ntimestamp;
    }
    if ([[nverticalAccuracy class]isSubclassOfClass:[NSNumber class]]) {
        verticalAccuracy = nverticalAccuracy;
    }
    if (altitude || latitude || longitude || course || horizontalAccuracy || speed || timestamp || verticalAccuracy) {
        CLLocation *location = [[CLLocation alloc]initWithCoordinate:CLLocationCoordinate2DMake(latitude.doubleValue,longitude.doubleValue) altitude:altitude.doubleValue horizontalAccuracy:horizontalAccuracy.doubleValue verticalAccuracy:verticalAccuracy.doubleValue course:course.doubleValue speed:speed.doubleValue timestamp:[NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue]];
        return location;
    } else {
        return nil;
    }
}

- (NSString*)sqliteDataTypeName
{
    return SQLITE_DATA_TYPE_REAL;
}

@end
