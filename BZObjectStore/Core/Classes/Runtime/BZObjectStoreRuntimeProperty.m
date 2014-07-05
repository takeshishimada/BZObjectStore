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

#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreModelInterface.h"
#import "BZObjectStoreClazz.h"
#import "BZObjectStoreRuntime.h"
#import "BZObjectStoreNameBuilder.h"
#import "BZObjectStoreQueryBuilder.h"
#import "BZRuntimeProperty.h"
#import "BZRuntimePropertyEncoding.h"
#import "BZObjectStoreSQLiteColumnModel.h"


@implementation BZObjectStoreRuntimeProperty

+ (instancetype)propertyWithBZProperty:(BZRuntimeProperty*)bzproperty runtime:(BZObjectStoreRuntime*)runtime nameBuilder:(BZObjectStoreNameBuilder*)nameBuilder
{
    return [[self alloc]initWithBZProperty:bzproperty runtime:runtime nameBuilder:nameBuilder];
}

- (instancetype)initWithBZProperty:(BZRuntimeProperty*)bzproperty runtime:(BZObjectStoreRuntime*)runtime nameBuilder:(BZObjectStoreNameBuilder*)nameBuilder
{
    if (self = [super init]) {
        [self setupWithBZProperty:bzproperty runtime:runtime nameBuilder:nameBuilder];
    }
    return self;
}

- (void)setupWithBZProperty:(BZRuntimeProperty*)bzproperty runtime:(BZObjectStoreRuntime*)runtime nameBuilder:(BZObjectStoreNameBuilder*)nameBuilder
{
    BOOL isPrimitive = NO;
    BOOL isStructure = NO;
    BOOL isObject = NO;
    NSString *structureName = nil;
    
    // name
    self.name  = bzproperty.name;
    self.tableName = runtime.tableName;
    
    // data type
    if (bzproperty.propertyEncoding.isObject) {
        self.clazz = bzproperty.clazz;
        self.clazzName = NSStringFromClass(bzproperty.clazz);
        self.isValid = YES;
        isObject = YES;
        isStructure = NO;
        isPrimitive = NO;
    } else if (bzproperty.propertyEncoding.isStructure) {
        self.isValid = YES;
        isObject = NO;
        isStructure = YES;
        isPrimitive = NO;
    } else if (bzproperty.propertyEncoding) {
        if ([self isPrimitiveWithBZPropertyEncoding:bzproperty.propertyEncoding]) {
            self.isValid = YES;
            isObject = NO;
            isStructure = NO;
            isPrimitive = YES;
        } else {
            self.isValid = NO;
            isObject = NO;
            isStructure = NO;
            isPrimitive = NO;
        }
    }

    // attribute options
    self.identicalAttribute = [self boolWithProtocol:@protocol(OSIdenticalAttribute) bzproperty:bzproperty];
    self.ignoreAttribute = [self boolWithProtocol:@protocol(OSIgnoreAttribute) bzproperty:bzproperty];
    self.weakReferenceAttribute = [self boolWithProtocol:@protocol(OSWeakReferenceAttribute) bzproperty:bzproperty];
    self.notUpdateIfValueIsNullAttribute = [self boolWithProtocol:@protocol(OSNotUpdateIfValueIsNullAttribute) bzproperty:bzproperty];
    self.serializableAttribute = [self boolWithProtocol:@protocol(OSSerializableAttribute) bzproperty:bzproperty];
    self.fetchOnRefreshingAttribute = [self boolWithProtocol:@protocol(OSFetchOnRefreshingAttribute) bzproperty:bzproperty];
    self.onceUpdateAttribute = [self boolWithProtocol:@protocol(OSOnceUpdateAttribute) bzproperty:bzproperty];
    
    if ([runtime.clazz conformsToProtocol:@protocol(OSModelInterface)]) {

        Class clazz = runtime.clazz;
        if ([clazz respondsToSelector:@selector(attributeIsOSIdenticalAttribute:)]) {
            self.identicalAttribute = (BOOL)[clazz performSelector:@selector(attributeIsOSIdenticalAttribute:)withObject:self.name];
        }
        if ([clazz respondsToSelector:@selector(attributeIsOSIgnoreAttribute:)]) {
            self.ignoreAttribute = (BOOL)[clazz performSelector:@selector(attributeIsOSIgnoreAttribute:)withObject:self.name];
        }
        if ([clazz respondsToSelector:@selector(attributeIsOSWeakReferenceAttribute:)]) {
            self.weakReferenceAttribute = (BOOL)[clazz performSelector:@selector(attributeIsOSWeakReferenceAttribute:)withObject:self.name];
        }
        if ([clazz respondsToSelector:@selector(attributeIsOSNotUpdateIfValueIsNullAttribute:)]) {
            self.notUpdateIfValueIsNullAttribute = (BOOL)[clazz performSelector:@selector(attributeIsOSNotUpdateIfValueIsNullAttribute:)withObject:self.name];
        }
        if ([clazz respondsToSelector:@selector(attributeIsOSSerializableAttribute:)]) {
            self.serializableAttribute = (BOOL)[clazz performSelector:@selector(attributeIsOSSerializableAttribute:)withObject:self.name];
        }
        if ([clazz respondsToSelector:@selector(attributeIsOSFetchOnRefreshingAttribute:)]) {
            self.fetchOnRefreshingAttribute = (BOOL)[clazz performSelector:@selector(attributeIsOSFetchOnRefreshingAttribute:)withObject:self.name];
        }
        if ([clazz respondsToSelector:@selector(attributeIsOSOnceUpdateAttribute:)]) {
            self.onceUpdateAttribute = (BOOL)[clazz performSelector:@selector(attributeIsOSOnceUpdateAttribute:)withObject:self.name];
        }
    }
    
    // weak property will be weak reference attribute
    if (bzproperty.propertyType.isWeakReference) {
        self.weakReferenceAttribute = YES;
    }
    
    // structureName
    if (isStructure) {
        structureName = [self structureNameWithAttributes:bzproperty.attributes];
    }

    // clazz
    if (self.serializableAttribute) {
        self.osclazz = [BZObjectStoreClazz osclazzWithPrimitiveEncodingCode:@"Serialize"];
    } else if (isStructure) {
        self.osclazz = [BZObjectStoreClazz osclazzWithStructureName:structureName];
    } else if (isPrimitive) {
        self.osclazz = [BZObjectStoreClazz osclazzWithPrimitiveEncodingCode:bzproperty.propertyEncoding.code];
    } else if (isObject) {
        self.osclazz = [BZObjectStoreClazz osclazzWithClazz:self.clazz];
    }
    self.isSimpleValueClazz = self.osclazz.isSimpleValueClazz;
    self.isArrayClazz = self.osclazz.isArrayClazz;
    self.isObjectClazz = self.osclazz.isObjectClazz;
    self.isRelationshipClazz = self.osclazz.isRelationshipClazz;
    self.isPrimaryClazz = self.osclazz.isPrimaryClazz;
    self.attributeType = self.osclazz.attributeType;
    
    // identicalAttribute
    if (!self.isPrimaryClazz) {
        self.identicalAttribute = NO;
    }

    // relationship attribute
    if (self.serializableAttribute) {
        self.isRelationshipClazz = NO;
    }
    
    // fetchOnRefreshingAttribute
    if (self.fetchOnRefreshingAttribute) {
        self.notUpdateIfValueIsNullAttribute = YES;
    }
    
    // sqlite
    self.columnName = [nameBuilder columnName:bzproperty.name clazz:runtime.clazz];
    self.sqliteColumns = [self.osclazz sqliteColumnsWithAttribute:self];
    
}

- (BOOL)isPrimitiveWithBZPropertyEncoding:(BZRuntimePropertyEncoding*)encoding
{
    if (encoding.isChar) return YES;
    else if (encoding.isInt) return YES;
    else if (encoding.isShort) return YES;
    else if (encoding.isLong) return YES;
    else if (encoding.isLongLong) return YES;
    else if (encoding.isUnsignedChar) return YES;
    else if (encoding.isUnsignedInt) return YES;
    else if (encoding.isUnsignedShort) return YES;
    else if (encoding.isUnsignedLong) return YES;
    else if (encoding.isUnsignedLongLong) return YES;
    else if (encoding.isFloat) return YES;
    else if (encoding.isDouble) return YES;
    else if (encoding.isBool) return YES;
    return NO;
}


- (BOOL)boolWithProtocol:(Protocol*)protocol bzproperty:(BZRuntimeProperty*)bzproperty
{
    NSString *name = NSStringFromProtocol(protocol);
    name = [NSString stringWithFormat:@"<%@>",name];
    NSRange range = [bzproperty.attributes rangeOfString:name];
    return range.location != NSNotFound;
}

- (NSString*)structureNameWithAttributes:(NSString*)attributes
{
    NSString *structureName = nil;
    NSArray *attributeList = [attributes componentsSeparatedByString:@","];
    NSString *firstAttribute = [attributeList firstObject];
    if (firstAttribute.length > 3) {
        NSString *name = [firstAttribute substringWithRange:NSMakeRange(2, firstAttribute.length - 3)];
        NSArray *names = [name componentsSeparatedByString:@"="];
        structureName = names.firstObject;
        if ([structureName isEqualToString:@"?"] && names.count > 1) {
            structureName = names[1];
        }
    }
    return structureName;
}

#pragma mark statement

- (NSString*)alterTableAddColumnStatement:(BZObjectStoreSQLiteColumnModel*)sqliteColumn
{
    return [BZObjectStoreQueryBuilder alterTableAddColumnStatement:self.tableName sqliteColumn:sqliteColumn];
}


#pragma mark mapping methods

- (NSArray*)storeValuesWithObject:(NSObject*)object
{
    return [self.osclazz storeValuesWithValue:[object valueForKey:self.name] attribute:self];
}

- (id)valueWithResultSet:(FMResultSet*)resultSet
{
    return [self.osclazz valueWithResultSet:resultSet attribute:self];
}

#pragma mark 

+ (NSString*)OSTableName
{
    return @"__ObjectStoreRuntimeProperty__";
}

@end
