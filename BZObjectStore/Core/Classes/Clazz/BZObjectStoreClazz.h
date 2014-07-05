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

#import <Foundation/Foundation.h>

@class BZObjectStoreRuntimeProperty;
@class FMResultSet;

@protocol BZObjectStoreClazzProtocol <NSObject>
@optional
- (Class)superClazz;
- (BOOL)isSimpleValueClazz;
- (BOOL)isArrayClazz;
- (BOOL)isObjectClazz;
- (BOOL)isRelationshipClazz;
- (BOOL)isPrimaryClazz;
- (BOOL)isSubClazz:(Class)clazz;
- (NSString*)attributeType;
- (id)objectWithObjects:(NSArray*)objects keys:(NSArray*)keys initializingOptions:(NSString*)initializingOptions;
- (id)objectWithClazz:(Class)clazz;
- (NSEnumerator*)objectEnumeratorWithObject:(id)object;
- (NSArray*)keysWithObject:(id)object;
- (NSArray*)storeValuesWithValue:(id)value attribute:(BZObjectStoreRuntimeProperty*)attribute;
- (id)valueWithResultSet:(FMResultSet*)resultSet attribute:(BZObjectStoreRuntimeProperty*)attribute;
- (NSString*)sqliteDataTypeName;
- (NSArray*)sqliteColumnsWithAttribute:(BZObjectStoreRuntimeProperty*)attribute;
- (NSArray*)requiredPropertyList;
@end


@interface BZObjectStoreClazz : NSObject<BZObjectStoreClazzProtocol>
+ (BZObjectStoreClazz*)osclazzWithClazz:(Class)clazz;
+ (BZObjectStoreClazz*)osclazzWithPrimitiveEncodingCode:(NSString*)primitiveEncodingCode;
+ (BZObjectStoreClazz*)osclazzWithStructureName:(NSString*)StructureName;
+ (void)addClazz:(Class)clazz;
@end
