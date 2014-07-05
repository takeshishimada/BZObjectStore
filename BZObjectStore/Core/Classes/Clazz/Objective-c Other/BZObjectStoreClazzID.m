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

#import "BZObjectStoreClazzID.h"
#import <FMResultSet.h>
#import "BZObjectStoreConst.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreSQLiteColumnModel.h"
#import "BZObjectStoreClazz.h"

@implementation BZObjectStoreClazzID

- (Class)superClazz
{
    return NULL;
}
- (NSString*)attributeType
{
    return nil;
}
- (BOOL)isObjectClazz
{
    return YES;
}
- (BOOL)isRelationshipClazz
{
    return YES;
}
- (BOOL)isSimpleValueClazz
{
    return YES;
}

- (NSArray*)sqliteColumnsWithAttribute:(BZObjectStoreRuntimeProperty *)attribute
{
    BZObjectStoreSQLiteColumnModel *value = [[BZObjectStoreSQLiteColumnModel alloc]init];
    value.columnName = attribute.columnName;
    value.dataTypeName = SQLITE_DATA_TYPE_NONE;
    
    BZObjectStoreSQLiteColumnModel *attributeType = [[BZObjectStoreSQLiteColumnModel alloc]init];
    attributeType.columnName = [NSString stringWithFormat:@"%@_attributeType",attribute.columnName];
    attributeType.dataTypeName = SQLITE_DATA_TYPE_TEXT;
    
    return @[value,attributeType];
}

- (NSArray*)storeValuesWithValue:(NSObject*)value attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *attributeType = nil;
    if (value) {
        BZObjectStoreClazz *osclazz = [BZObjectStoreClazz osclazzWithClazz:[value class]];
        NSArray *storeValue = [osclazz storeValuesWithValue:value attribute:attribute];
        attributeType = osclazz.attributeType;
        NSMutableArray *storeValues = [NSMutableArray arrayWithArray:storeValue];
        if (storeValues.count == 1) {
            return @[storeValues[0],attributeType];
        }
    }
    return @[[NSNull null],[NSNull null]];
}

- (id)valueWithResultSet:(FMResultSet*)resultSet attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *attributeTypeColumnName = [NSString stringWithFormat:@"%@_attributeType",attribute.columnName];
    NSString *attributeType = [resultSet stringForColumn:attributeTypeColumnName];
    Class clazz = NSClassFromString(attributeType);
    if (clazz) {
        NSObject *value = [resultSet objectForColumnName:attribute.columnName];
        if (value) {
            BZObjectStoreClazz *osclazz = [BZObjectStoreClazz osclazzWithClazz:clazz];
            if (osclazz.isSimpleValueClazz) {
                NSObject *value = [osclazz valueWithResultSet:resultSet attribute:attribute];
                return value;
            }
        }
    }
    return nil;
}

@end