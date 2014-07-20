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
#import "BZObjectStoreModelInterface.h"

@class BZObjectStoreClazzUtil;
@class BZObjectStoreNameBuilder;
@class BZObjectStoreRuntimeProperty;
@class BZObjectStoreConditionModel;
@class BZObjectStoreClazz;
@class FMResultSet;

@interface BZObjectStoreRuntime : NSObject<OSModelInterface>

//
- (instancetype)initWithClazz:(Class)clazz osclazz:(BZObjectStoreClazz*)osclazz nameBuilder:(BZObjectStoreNameBuilder*)nameBuilder;

// class information
@property (nonatomic,assign) Class clazz;
@property (nonatomic,strong) NSString<OSIdenticalAttribute> *clazzName;
@property (nonatomic,assign) BOOL isArrayClazz;
@property (nonatomic,assign) BOOL isSimpleValueClazz;
@property (nonatomic,assign) BOOL isObjectClazz;
@property (nonatomic,assign) BOOL isRelationshipClazz;

// attribute inforamtion
@property (nonatomic,strong) BZObjectStoreRuntimeProperty<OSIgnoreAttribute> *rowidAttribute;
@property (nonatomic,strong) NSArray *attributes;
@property (nonatomic,strong) NSArray<OSIgnoreAttribute> *identificationAttributes;
@property (nonatomic,strong) NSArray<OSIgnoreAttribute> *insertAttributes;
@property (nonatomic,strong) NSArray<OSIgnoreAttribute> *updateAttributes;
@property (nonatomic,strong) NSArray<OSIgnoreAttribute> *relationshipAttributes;
@property (nonatomic,strong) NSArray<OSIgnoreAttribute> *simpleValueAttributes;

// class options
@property (nonatomic,assign) BOOL fullTextSearch3;
@property (nonatomic,assign) BOOL fullTextSearch4;
@property (nonatomic,assign) BOOL modelDidLoad;
@property (nonatomic,assign) BOOL modelDidSave;
@property (nonatomic,assign) BOOL modelDidDelete;

// for response
@property (nonatomic,assign) BOOL hasIdentificationAttributes;
@property (nonatomic,assign) BOOL hasRelationshipAttributes;
@property (nonatomic,assign) BOOL insertPerformance;
@property (nonatomic,assign) BOOL updatePerformance;
@property (nonatomic,assign) BOOL notification;
@property (nonatomic,assign) BOOL cascadeNotification;

//
@property (nonatomic,strong) BZObjectStoreClazz<OSSerializableAttribute> *osclazz;

// for response
@property (atomic,strong) NSString *tableName;
@property (nonatomic,strong) NSString *selectTemplateStatement;
@property (nonatomic,strong) NSString *updateTemplateStatement;
@property (nonatomic,strong) NSString *selectRowidTemplateStatement;
@property (nonatomic,strong) NSString *insertIntoTemplateStatement;
@property (nonatomic,strong) NSString *insertOrIgnoreIntoTemplateStatement;
@property (nonatomic,strong) NSString *insertOrReplaceIntoTemplateStatement;
@property (nonatomic,strong) NSString *deleteFromTemplateStatement;
@property (nonatomic,strong) NSString *createTableTemplateStatement;
@property (nonatomic,strong) NSString *dropTableTemplateStatement;
@property (nonatomic,strong) NSString *createUniqueIndexTemplateStatement;
@property (nonatomic,strong) NSString *dropIndexTemplateStatement;
@property (nonatomic,strong) NSString *countTemplateStatement;
@property (nonatomic,strong) NSString *referencedCountTemplateStatement;
@property (nonatomic,strong) NSString *uniqueIndexNameTemplateStatement;
@property (nonatomic,assign) BOOL hasNotUpdateIfValueIsNullAttribute;

// statement methods
- (NSString*)createTableStatement;
- (NSString*)dropTableStatement;
- (NSString*)createUniqueIndexStatement;
- (NSString*)dropUniqueIndexStatement;
- (NSString*)insertIntoStatement;
- (NSString*)insertOrIgnoreIntoStatement;
- (NSString*)insertOrReplaceIntoStatement;
- (NSString*)updateStatementWithObject:(NSObject*)object condition:(BZObjectStoreConditionModel*)condition;
- (NSString*)selectRowidStatement:(BZObjectStoreConditionModel*)condition;
- (NSString*)selectStatementWithCondition:(BZObjectStoreConditionModel*)condition;
- (NSString*)deleteFromStatementWithCondition:(BZObjectStoreConditionModel*)condition;
- (NSString*)referencedCountStatementWithCondition:(BZObjectStoreConditionModel*)condition;
- (NSString*)countStatementWithCondition:(BZObjectStoreConditionModel*)condition;
- (NSString*)uniqueIndexName;
- (NSString*)minStatementWithColumnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition;
- (NSString*)maxStatementWithColumnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition;
- (NSString*)avgStatementWithColumnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition;
- (NSString*)totalStatementWithColumnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition;
- (NSString*)sumStatementWithColumnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition;

// condition methods
- (BZObjectStoreConditionModel*)rowidCondition:(NSObject*)object;
- (BZObjectStoreConditionModel*)uniqueCondition:(NSObject*)object;

// parameter methods
- (NSMutableArray*)insertOrIgnoreAttributesParameters:(NSObject*)object;
- (NSMutableArray*)insertOrReplaceAttributesParameters:(NSObject*)object;
- (NSMutableArray*)insertAttributesParameters:(NSObject*)object;
- (NSMutableArray*)updateAttributesParameters:(NSObject*)object;

// for value in array
- (NSEnumerator*)objectEnumeratorWithObject:(id)object;
- (NSArray*)keysWithObject:(id)object;
- (id)objectWithObjects:(NSArray*)objects keys:(NSArray*)keys initializingOptions:(NSString*)initializingOptions;
- (id)object;

@end