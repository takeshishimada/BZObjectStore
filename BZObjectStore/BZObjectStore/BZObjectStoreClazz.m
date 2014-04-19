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

#import "BZObjectStoreClazz.h"
#import "BZObjectStoreClazzID.h"
#import "BZObjectStoreClazzNSObject.h"
#import "BZObjectStoreClazzNSDate.h"
#import "BZObjectStoreClazzNSURL.h"
#import "BZObjectStoreClazzNSMutableString.h"
#import "BZObjectStoreClazzNSString.h"
#import "BZObjectStoreClazzNSNumber.h"
#import "BZObjectStoreClazzNSData.h"
#import "BZObjectStoreClazzUIColor.h"
#import "BZObjectStoreClazzUIImage.h"
#import "BZObjectStoreClazzNSValue.h"
#import "BZObjectStoreClazzNSNull.h"
#import "BZObjectStoreClazzPrimitive.h"
#import "BZObjectStoreClazzInt.h"
#import "BZObjectStoreClazzChar.h"
#import "BZObjectStoreClazzFloat.h"
#import "BZObjectStoreClazzDouble.h"
#import "BZObjectStoreClazzCGRect.h"
#import "BZObjectStoreClazzCGSize.h"
#import "BZObjectStoreClazzCGPoint.h"
#import "BZObjectStoreClazzNSRange.h"
#import "BZObjectStoreClazzNSMutableArray.h"
#import "BZObjectStoreClazzNSMutableDictionary.h"
#import "BZObjectStoreClazzNSMutableSet.h"
#import "BZObjectStoreClazzNSMutableOrderedSet.h"
#import "BZObjectStoreClazzNSArray.h"
#import "BZObjectStoreClazzNSDictionary.h"
#import "BZObjectStoreClazzNSSet.h"
#import "BZObjectStoreClazzNSOrderedSet.h"
#import "BZObjectStoreClazzSerialize.h"
#import "BZObjectStoreConst.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreSQLiteColumnModel.h"
#import "FMResultSet.h"

@implementation BZObjectStoreClazz


#pragma mark override methods,properties

- (NSEnumerator*)objectEnumeratorWithObject:(NSArray*)object
{
    NSArray *array = @[object];
    return [array objectEnumerator];
}

- (NSArray*)keysWithObject:(id)object
{
    return nil;
}
- (NSString*)initializingOptionsWithObject:(NSObject*)object
{
    return nil;
}
- (id)objectWithObjects:(NSArray*)objects keys:(NSArray*)keys initializingOptions:(NSString*)initializingOptions
{
    return nil;
}
- (id)objectWithClazz:(Class)clazz
{
    return nil;
}

- (Class)superClazz
{
    return nil;
}

- (NSString*)attributeType
{
    return @"";
}
- (BOOL)isSimpleValueClazz
{
    return NO;
}
- (BOOL)isArrayClazz
{
    return NO;
}
- (BOOL)isObjectClazz
{
    return NO;
}
- (BOOL)isRelationshipClazz
{
    return NO;
}
- (BOOL)isStringNumberClazz
{
    return NO;
}
- (id)storeValueWithValue:(id)value
{
    if (!value) {
        return [NSNull null];
    } else {
        return value;
    }
}
- (id)valueWithStoreValue:(id)value
{
    return value;
}
- (NSArray*)storeValuesWithObject:(NSObject*)object attributeName:(NSString*)attributeName
{
    return @[[self storeValueWithValue:[object valueForKey:attributeName]]];
}
- (id)valueWithResultSet:(FMResultSet*)resultSet attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    return [self valueWithStoreValue:[resultSet stringForColumn:attribute.columnName]];
}
- (NSString*)sqliteDataTypeName
{
    return @"";
}

- (NSArray*)sqliteColumnsWithAttribute:(BZObjectStoreRuntimeProperty*)attribute
{
    BZObjectStoreSQLiteColumnModel *sqliteColumn = [[BZObjectStoreSQLiteColumnModel alloc]init];
    sqliteColumn.columnName = attribute.columnName;
    sqliteColumn.dataTypeName = [self sqliteDataTypeName];
    return @[sqliteColumn];
}


#pragma mark constractor

+ (NSMutableArray*)osclazzsArray
{
    static NSMutableArray *_osclazzs = nil;
    if (!_osclazzs) {
        @synchronized(self) {
            _osclazzs = [NSMutableArray array];
        }
    }
    return _osclazzs;
}

+ (NSMutableDictionary*)osclazzs
{
    static NSMutableDictionary *_osclazzs = nil;
    if (!_osclazzs) {
        @synchronized(self) {
            NSMutableArray *osclazzsArray = [self osclazzsArray];
            _osclazzs = [NSMutableDictionary dictionary];
            [self addOSClazz:[BZObjectStoreClazzID class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSObject class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSMutableString class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSMutableArray class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSMutableDictionary class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSMutableSet class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSMutableOrderedSet class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSDate class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSURL class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSString class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSNumber class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSData class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzUIColor class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzUIImage class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSValue class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSNull class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSArray class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSDictionary class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSSet class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSOrderedSet class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzPrimitive class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzInt class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzChar class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzFloat class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzDouble class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzCGRect class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzCGSize class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzCGPoint class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzNSRange class] osclazzsArray:osclazzsArray];
            [self addOSClazz:[BZObjectStoreClazzSerialize class] osclazzsArray:osclazzsArray];
        }
    }
    return _osclazzs;
}

+ (void)addClazz:(Class)clazz
{
    if ([clazz isSubclassOfClass:[BZObjectStoreClazz class]]) {
        return;
    }
    @synchronized(self) {
        NSMutableArray *osclazzsArray = [self osclazzsArray];
        [self addOSClazz:clazz osclazzsArray:osclazzsArray];
    }
}

+ (void)addOSClazz:(Class)clazz osclazzsArray:(NSMutableArray*)osclazzsArray
{
    BZObjectStoreClazz *osclazz = [[clazz alloc]init];
    [osclazzsArray addObject:osclazz];
}


+ (BZObjectStoreClazz*)osclazzWithClazz:(Class)clazz
{
    NSMutableDictionary *osclazzs = [self osclazzs];
    BZObjectStoreClazz *osclazz = [osclazzs objectForKey:NSStringFromClass(clazz)];
    if (osclazz) {
        return osclazz;
    }
    NSMutableArray *osclazzsArray = [self osclazzsArray];
    if (!clazz) {
        return osclazzsArray[0];
    }
    for (BZObjectStoreClazz *osclazz in osclazzsArray) {
        if ( osclazz.superClazz != [NSObject class]) {
            if ([clazz isSubclassOfClass:osclazz.superClazz]) {
                [osclazzs setObject:osclazz forKey:NSStringFromClass(clazz)];
                return osclazz;
            }
        }
    }
    [osclazzs setObject:osclazzsArray[1] forKey:NSStringFromClass(clazz)];
    return osclazzsArray[1];
}

+ (BZObjectStoreClazz*)osclazzWithPrimitiveEncodingCode:(NSString*)primitiveEncodingCode
{
    NSString *key = primitiveEncodingCode;
    NSMutableDictionary *osclazzs = [self osclazzs];
    BZObjectStoreClazz* osclazz = [osclazzs objectForKey:key];
    if (!osclazz) {
        NSMutableArray *osclazzsArray = [self osclazzsArray];
        for (BZObjectStoreClazz *newosclazz in osclazzsArray) {
            if ([newosclazz.attributeType isEqualToString:key]) {
                osclazz = newosclazz;
                break;
            }
        }
        if (!osclazz) {
            osclazz = [[BZObjectStoreClazzPrimitive alloc]init];
        }
        if (osclazz) {
            [osclazzs setObject:osclazz forKey:key];
        }
    }
    return osclazz;
}

+ (BZObjectStoreClazz*)osclazzWithStructureName:(NSString*)StructureName
{
    NSString *key = StructureName;
    NSMutableDictionary *osclazzs = [self osclazzs];
    BZObjectStoreClazz* osclazz = [osclazzs objectForKey:key];
    if (!osclazz) {
        NSMutableArray *osclazzsArray = [self osclazzsArray];
        for (BZObjectStoreClazz *newosclazz in osclazzsArray) {
            if ([newosclazz.attributeType isEqualToString:key]) {
                osclazz = newosclazz;
                break;
            }
        }
        if (!osclazz) {
            osclazz = [[BZObjectStoreClazzNSValue alloc]init];
        }
        if (osclazz) {
            [osclazzs setObject:osclazz forKey:key];
        }
    }
    return osclazz;
}


@end
