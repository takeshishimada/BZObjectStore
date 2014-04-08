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

#import "BZObjectStoreClazz.h"
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
#import "BZObjectStoreConst.h"

#import "FMResultSet.h"

@implementation BZObjectStoreClazz


#pragma mark override methods,properties

- (NSEnumerator*)objectEnumeratorWithObject:(id)object
{
    return nil;
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
- (id)storeValueWithObject:(NSObject*)object name:(NSString*)name
{
    return [self storeValueWithValue:[object valueForKey:name]];
}
- (id)valueWithResultSet:(FMResultSet*)resultSet colunmName:(NSString*)columnName
{
    return [self valueWithStoreValue:[resultSet stringForColumn:columnName]];
}
- (NSString*)sqliteDataTypeName
{
    return @"";
}



#pragma mark constractor

+ (NSMutableDictionary*)osclazzs
{
    static NSMutableDictionary *_osclazzs = nil;
    if (!_osclazzs) {
        @synchronized(self) {
            _osclazzs = [NSMutableDictionary dictionary];
            [self addOSClazz:[BZObjectStoreClazzNSMutableString class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSMutableArray class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSMutableDictionary class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSMutableSet class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSMutableOrderedSet class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSDate class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSURL class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSString class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSNumber class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSData class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzUIColor class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzUIImage class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSValue class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSNull class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSArray class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSDictionary class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSSet class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSOrderedSet class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSObject class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzPrimitive class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzInt class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzChar class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzFloat class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzDouble class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzCGRect class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzCGSize class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzCGPoint class] osclazzs:_osclazzs];
            [self addOSClazz:[BZObjectStoreClazzNSRange class] osclazzs:_osclazzs];
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
        NSMutableDictionary *osclazzs = [self osclazzs];
        [self addOSClazz:clazz osclazzs:osclazzs];
    }
}

+ (void)addOSClazz:(Class)clazz osclazzs:(NSMutableDictionary*)osclazzs
{
    BZObjectStoreClazz *osclazz = [[clazz alloc]init];
    [osclazzs setObject:osclazz forKey:osclazz.attributeType];
}

+ (BZObjectStoreClazz*)osclazzWithClazz:(Class)clazz
{
    NSMutableDictionary *osclazzs = [self osclazzs];
    BZObjectStoreClazz *osclazz = [osclazzs objectForKey:NSStringFromClass(clazz)];
    if (osclazz) {
        return osclazz;
    }
    for (BZObjectStoreClazz *osclazz in osclazzs.allValues) {
        if (osclazz.superClazz && osclazz.superClazz != [NSObject class]) {
            if ([clazz isSubclassOfClass:osclazz.superClazz]) {
                return osclazz;
            }
        }
    }
    return [osclazzs objectForKey:NSStringFromClass([NSObject class])];
}

+ (BZObjectStoreClazz*)osclazzWithPrimitiveEncodingCode:(NSString*)primitiveEncodingCode
{
    NSString *key = primitiveEncodingCode;
    NSMutableDictionary *osclazzs = [self osclazzs];
    BZObjectStoreClazz* osclazz = [osclazzs objectForKey:key];
    if (!osclazz) {
        osclazz = [[BZObjectStoreClazzPrimitive alloc]init];
        [osclazzs setObject:osclazz forKey:primitiveEncodingCode];
    }
    return osclazz;
}

+ (BZObjectStoreClazz*)osclazzWithStructureName:(NSString*)StructureName
{
    NSString *key = StructureName;
    NSMutableDictionary *osclazzs = [self osclazzs];
    BZObjectStoreClazz* osclazz = [osclazzs objectForKey:key];
    if (!osclazz) {
        osclazz = [[BZObjectStoreClazzNSValue alloc]init];
        [osclazzs setObject:osclazz forKey:StructureName];
    }
    return osclazz;
}


@end
