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

#import <Foundation/Foundation.h>

@class BZObjectStoreClazzUtil;
@class BZObjectStoreNameBuilder;
@class BZObjectStoreRuntimeProperty;
@class BZObjectStoreConditionModel;
@class BZObjectStoreClazz;
@class FMResultSet;

@interface BZObjectStoreRuntime : NSObject

+ (instancetype)runtimeWithClazz:(Class)clazz nameBuilder:(BZObjectStoreNameBuilder*)nameBuilder;

// name information
@property (nonatomic,strong) BZObjectStoreNameBuilder *nameBuilder;
@property (atomic,strong) NSString *tableName;

// class information
@property (nonatomic,assign) Class clazz;
@property (nonatomic,strong) NSString *clazzName;
@property (nonatomic,assign) BOOL isArrayClazz;
@property (nonatomic,assign) BOOL isSimpleValueClazz;
@property (nonatomic,assign) BOOL isObjectClazz;
@property (nonatomic,assign) BOOL isRelationshipClazz;

// attribute inforamtion
@property (nonatomic,strong) BZObjectStoreRuntimeProperty *rowidAttribute;
@property (nonatomic,strong) NSArray *attributes;
@property (nonatomic,strong) NSArray *identificationAttributes;
@property (nonatomic,strong) NSArray *insertAttributes;
@property (nonatomic,strong) NSArray *updateAttributes;
@property (nonatomic,strong) NSArray *relationshipAttributes;
@property (nonatomic,strong) NSArray *notRelationshipAttributes;

// class options
@property (nonatomic,assign) BOOL fullTextSearch;
@property (nonatomic,assign) BOOL modelDidLoad;
@property (nonatomic,assign) BOOL modelDidSave;
@property (nonatomic,assign) BOOL modelDidRemove;

// for response
@property (nonatomic,assign) BOOL hasIdentificationAttributes;
@property (nonatomic,assign) BOOL hasRelationshipAttributes;
@property (nonatomic,assign) BOOL insertPerformance;
@property (nonatomic,assign) BOOL updatePerformance;

// statement methods
- (NSString*)createTableStatement;
- (NSString*)createIndexStatement;
- (NSString*)createUniqueIndexStatement;
- (NSString*)dropTableStatement;
- (NSString*)dropUniqueIndexStatement;
- (NSString*)insertIntoStatement;
- (NSString*)insertOrReplaceIntoStatement;
- (NSString*)insertOrIgnoreIntoStatement;
- (NSString*)updateStatementWithObject:(NSObject*)object condition:(BZObjectStoreConditionModel*)condition;
- (NSString*)selectRowidStatement:(BZObjectStoreConditionModel*)condition;
- (NSString*)selectStatementWithCondition:(BZObjectStoreConditionModel*)condition;
- (NSString*)deleteFromStatementWithCondition:(BZObjectStoreConditionModel*)condition;
- (NSString*)referencedCountStatementWithCondition:(BZObjectStoreConditionModel*)condition;
- (NSString*)countStatementWithCondition:(BZObjectStoreConditionModel*)condition;

// condition methods
- (BZObjectStoreConditionModel*)rowidCondition:(NSObject*)object;
- (BZObjectStoreConditionModel*)uniqueCondition:(NSObject*)object;

// parameter methods
- (NSMutableArray*)insertOrIgnoreAttributesParameters:(NSObject*)object;
- (NSMutableArray*)insertOrReplaceAttributesParameters:(NSObject*)object;
- (NSMutableArray*)insertAttributesParameters:(NSObject*)object;
- (NSMutableArray*)updateAttributesParameters:(NSObject*)object;

// attribute with name
- (BZObjectStoreRuntimeProperty*)attributeWithColumnName:(NSString*)columnName;

// for value in array
- (NSString*)initializingOptionsWithObject:(NSObject*)object;
- (NSEnumerator*)objectEnumeratorWithObject:(id)object;
- (NSArray*)keysWithObject:(id)object;
- (id)objectWithObjects:(NSArray*)objects keys:(NSArray*)keys initializingOptions:(NSString*)initializingOptions;
- (id)object;
- (id)storeValueWithValue:(NSObject*)value;
- (id)valueWithStoreValue:(NSObject*)value;

@end