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

#import "BZObjectStoreRuntime.h"
#import "BZObjectStoreClazz.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreAttributeInterface.h"
#import "BZObjectStoreNameBuilder.h"
#import "BZObjectStoreConst.h"
#import "BZObjectStoreFetchConditionModel.h"
#import "BZObjectStoreQueryBuilder.h"
#import "BZRuntime.h"
#import "NSObject+BZObjectStore.h"

@interface ObjectStoreReferenceModel : NSObject
@property (nonatomic,strong) NSNumber *rowid;
@end
@implementation ObjectStoreReferenceModel
@end

@interface BZObjectStoreRuntime ()
@property (nonatomic,strong) BZObjectStoreClazz *osclazz;
@property (nonatomic,strong) NSString *selectTemplateStatement;
@property (nonatomic,strong) NSString *updateTemplateStatement;
@property (nonatomic,strong) NSString *selectRowidTemplateStatement;
@property (nonatomic,strong) NSString *insertIntoTemplateStatement;
@property (nonatomic,strong) NSString *insertOrReplaceIntoTemplateStatement;
@property (nonatomic,strong) NSString *insertOrIgnoreIntoTemplateStatement;
@property (nonatomic,strong) NSString *deleteFromTemplateStatement;
@property (nonatomic,strong) NSString *createTableTemplateStatement;
@property (nonatomic,strong) NSString *dropTableTemplateStatement;
@property (nonatomic,strong) NSString *createIndexTemplateStatement;
@property (nonatomic,strong) NSString *createUniqueIndexTemplateStatement;
@property (nonatomic,strong) NSString *dropIndexTemplateStatement;
@property (nonatomic,strong) NSString *countTemplateStatement;
@property (nonatomic,strong) NSString *referencedCountTemplateStatement;
@property (nonatomic,assign) BOOL hasNotUpdateIfValueIsNullAttribute;
@end

#define ROWID @"ROWID"

@implementation BZObjectStoreRuntime


#pragma mark Constructor

+ (instancetype)runtimeWithClazz:(Class)clazz nameBuilder:(BZObjectStoreNameBuilder*)nameBuilder
{
    @synchronized(self) {
        static id _runtimes = nil;
        if (!_runtimes) {
            _runtimes = [NSMutableDictionary dictionary];
        }
        Class targetClazz = NULL;
        BZObjectStoreClazz *osclazz = [BZObjectStoreClazz osclazzWithClazz:clazz];
        if (osclazz.isObjectClazz) {
            targetClazz = clazz;
        } else {
            targetClazz = osclazz.superClazz;
        }
        BZObjectStoreRuntime *runtime = [_runtimes objectForKey:NSStringFromClass(targetClazz)];
        if (!runtime) {
            runtime = [[self alloc]initWithClazz:targetClazz osclazz:osclazz nameBuilder:nameBuilder];
            [_runtimes setObject:runtime forKey:NSStringFromClass(targetClazz)];
        }
        return runtime;
    }
}


- (instancetype)initWithClazz:(Class)clazz osclazz:(BZObjectStoreClazz*)osclazz nameBuilder:(BZObjectStoreNameBuilder*)nameBuilder
{
    if (self = [super init]) {
        [self setupWithClazz:clazz osclazz:osclazz nameBuilder:nameBuilder];
    }
    return self;
}

- (void)setupWithClazz:(Class)clazz osclazz:(BZObjectStoreClazz*)osclazz nameBuilder:(BZObjectStoreNameBuilder*)nameBuilder
{
    // clazz
    self.clazz = clazz;
    self.clazzName = NSStringFromClass(clazz);
    
    // mapper
    self.osclazz = osclazz;
    self.isArrayClazz = self.osclazz.isArrayClazz;
    self.isObjectClazz = self.osclazz.isObjectClazz;
    self.isSimpleValueClazz = self.osclazz.isSimpleValueClazz;
    self.isRelationshipClazz = self.osclazz.isRelationshipClazz;
    
    if (!self.isObjectClazz) {
        return;
    }
    
    // table name and column name for query builder
    self.nameBuilder = nameBuilder;
    self.tableName = [self.nameBuilder tableName:self.clazz];

    // attributes
    BZRuntime *bzruntime = nil;
    if ([self.clazz conformsToProtocol:@protocol(OSIgnoreSuperClass)]) {
        bzruntime = [BZRuntime runtimeWithClass:self.clazz];
    } else {
        bzruntime = [BZRuntime runtimeSuperClassWithClass:self.clazz];
    }
    NSMutableArray *propertyList = [NSMutableArray array];
    for (BZRuntimeProperty *property in bzruntime.propertyList) {
        NSString *from = [property.name uppercaseString];
        if (![from isEqualToString:ROWID]) {
            BOOL exists = NO;
            for (BZRuntimeProperty *existingProperty in propertyList) {
                NSString *to = [existingProperty.name uppercaseString];
                if ([from isEqualToString:to]) {
                    exists = YES;
                    break;
                }
            }
            if (!exists) {
                [propertyList addObject:property];
            }
        }
    }
    NSMutableArray *insertAttributes = [NSMutableArray array];
    NSMutableArray *identicalAttributes = [NSMutableArray array];
    NSMutableArray *updateAttributes = [NSMutableArray array];
    NSMutableArray *relationshipAttributes = [NSMutableArray array];
    NSMutableArray *notRelationshipAttributes = [NSMutableArray array];
    for (BZRuntimeProperty *property in propertyList) {
        BZObjectStoreRuntimeProperty *objectStoreAttribute = [BZObjectStoreRuntimeProperty propertyWithBZProperty:property runtime:self];
        if (objectStoreAttribute.isValid) {
            if (!objectStoreAttribute.ignoreAttribute && !property.propertyType.isReadonly) {
                [insertAttributes addObject:objectStoreAttribute];
                if (objectStoreAttribute.identicalAttribute) {
                    [identicalAttributes addObject:objectStoreAttribute];
                } else {
                    if (!objectStoreAttribute.onceUpdateAttribute) {
                        [updateAttributes addObject:objectStoreAttribute];
                    }
                }
                if (objectStoreAttribute.notUpdateIfValueIsNullAttribute) {
                    self.hasNotUpdateIfValueIsNullAttribute = YES;
                }
                if (objectStoreAttribute.isRelationshipClazz) {
                    [relationshipAttributes addObject:objectStoreAttribute];
                } else {
                    [notRelationshipAttributes addObject:objectStoreAttribute];
                }
            }
        }
    }
    
    BZRuntime *referenceRuntime = [BZRuntime runtimeWithClass:[ObjectStoreReferenceModel class]];
    BZObjectStoreRuntimeProperty *rowidAttribute = [BZObjectStoreRuntimeProperty propertyWithBZProperty:referenceRuntime.propertyList.firstObject runtime:self];
    NSMutableArray *attributes = [NSMutableArray array];
    [attributes addObject:rowidAttribute];
    [attributes addObjectsFromArray:insertAttributes];
    [notRelationshipAttributes addObject:rowidAttribute];
    
    self.rowidAttribute = rowidAttribute;
    self.attributes = [NSArray arrayWithArray:attributes];
    self.insertAttributes = [NSArray arrayWithArray:insertAttributes];
    self.updateAttributes = [NSArray arrayWithArray:updateAttributes];
    self.identificationAttributes = [NSArray arrayWithArray:identicalAttributes];
    self.relationshipAttributes = [NSArray arrayWithArray:relationshipAttributes];
    self.notRelationshipAttributes = [NSArray arrayWithArray:notRelationshipAttributes];

    // class options
    self.fullTextSearch =  [self.clazz conformsToProtocol:@protocol(OSFullTextSearch)];
    self.temporary = [self.clazz conformsToProtocol:@protocol(OSTemporary)];
    
    // response
    if (self.identificationAttributes.count > 0) {
        self.hasIdentificationAttributes = YES;
    } else {
        self.hasIdentificationAttributes = NO;
    }
    if (self.relationshipAttributes.count > 0) {
        self.hasRelationshipAttributes = YES;
    } else {
        self.hasRelationshipAttributes = NO;
    }
    if (self.attributes.count == 0 && self.isObjectClazz) {
        self.isObjectClazz = NO;
    }
    
    // query
    self.selectTemplateStatement = [BZObjectStoreQueryBuilder selectStatement:self];
    self.updateTemplateStatement = [BZObjectStoreQueryBuilder updateStatement:self];
    self.selectRowidTemplateStatement = [BZObjectStoreQueryBuilder selectRowidStatement:self];
    self.insertIntoTemplateStatement = [BZObjectStoreQueryBuilder insertIntoStatement:self];
    self.insertOrReplaceIntoTemplateStatement = [BZObjectStoreQueryBuilder insertOrReplaceIntoStatement:self];
    self.insertOrIgnoreIntoTemplateStatement = [BZObjectStoreQueryBuilder insertOrIgnoreIntoStatement:self];
    self.deleteFromTemplateStatement = [BZObjectStoreQueryBuilder deleteFromStatement:self];
    self.createTableTemplateStatement = [BZObjectStoreQueryBuilder createTableStatement:self];
    self.dropTableTemplateStatement = [BZObjectStoreQueryBuilder dropTableStatement:self];
    self.createIndexTemplateStatement = [BZObjectStoreQueryBuilder createIndexStatement:self];
    self.createUniqueIndexTemplateStatement = [BZObjectStoreQueryBuilder createUniqueIndexStatement:self];
    self.dropIndexTemplateStatement = [BZObjectStoreQueryBuilder dropTableStatement:self];
    self.countTemplateStatement = [BZObjectStoreQueryBuilder countStatement:self];
    self.referencedCountTemplateStatement = [BZObjectStoreQueryBuilder referencedCountStatement:self];

    
}

// attribute with name
- (BZObjectStoreRuntimeProperty*)attributeWithName:(NSString*)name
{
    for (BZObjectStoreRuntimeProperty *attribute in self.attributes) {
        if ([attribute.name isEqualToString:name]) {
            return attribute;
        }
    }
    return nil;
}

#pragma mark statement methods

- (NSString*)createTableStatement
{
    return self.createTableTemplateStatement;
}
- (NSString*)createIndexStatement
{
    return self.createIndexTemplateStatement;
}
- (NSString*)createUniqueIndexStatement
{
    return self.createUniqueIndexTemplateStatement;
}
- (NSString*)dropTableStatement
{
    return self.dropTableTemplateStatement;
}
- (NSString*)dropIndexStatement
{
    return self.dropIndexTemplateStatement;
}
- (NSString*)insertIntoStatement
{
    return self.insertIntoTemplateStatement;
}
- (NSString*)insertOrIgnoreIntoStatement
{
    return self.insertOrIgnoreIntoTemplateStatement;
}
- (NSString*)insertOrReplaceIntoStatement
{
    return self.insertOrReplaceIntoTemplateStatement;
}
- (NSString*)updateStatementWithObject:(NSObject*)object condition:(BZObjectStoreFetchConditionModel*)condition
{
    if (self.hasNotUpdateIfValueIsNullAttribute) {
        NSMutableArray *attributes = [NSMutableArray array];
        for (BZObjectStoreRuntimeProperty *attribute in self.updateAttributes) {
            id value = [attribute storeValueWithObject:object];
            if (value != [NSNull null]) {
                [attributes addObject:attribute];
            }
        }
        NSMutableString *sql = [NSMutableString string];
        [sql appendString:[BZObjectStoreQueryBuilder updateStatement:self attributes:attributes]];
        [sql appendString:[BZObjectStoreQueryBuilder updateConditionStatement:condition]];
        return [NSString stringWithString:sql];
    } else {
        NSMutableString *sql = [NSMutableString string];
        [sql appendString:self.updateTemplateStatement];
        [sql appendString:[BZObjectStoreQueryBuilder updateConditionStatement:condition]];
        return [NSString stringWithString:sql];
    }
}
- (NSString*)selectStatementWithCondition:(BZObjectStoreFetchConditionModel*)condition
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:self.selectTemplateStatement];
    [sql appendString:[BZObjectStoreQueryBuilder selectConditionStatement:condition runtime:self]];
    [sql appendString:[BZObjectStoreQueryBuilder selectConditionOptionStatement:condition]];
    return [NSString stringWithString:sql];
}

- (NSString*)selectRowidStatement:(BZObjectStoreFetchConditionModel*)condition
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:self.selectRowidTemplateStatement];
    [sql appendString:[BZObjectStoreQueryBuilder selectConditionStatement:condition]];
    return [NSString stringWithString:sql];
}


- (NSString*)deleteFromStatementWithCondition:(BZObjectStoreFetchConditionModel*)condition
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:self.deleteFromTemplateStatement];
    [sql appendString:[BZObjectStoreQueryBuilder deleteConditionStatement:condition]];
    return [NSString stringWithString:sql];
}

- (NSString*)referencedCountStatementWithCondition:(BZObjectStoreFetchConditionModel*)condition
{
    NSString *conditionStatement = [BZObjectStoreQueryBuilder selectConditionStatement:condition runtime:self];
    NSString *sql = self.referencedCountTemplateStatement;
    sql = [NSString stringWithFormat:sql,conditionStatement];
    return sql;
}

- (NSString*)countStatementWithCondition:(BZObjectStoreFetchConditionModel*)condition
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:self.countTemplateStatement];
    [sql appendString:[BZObjectStoreQueryBuilder selectConditionStatement:condition runtime:self]];
    return [NSString stringWithString:sql];
}

#pragma marks unique condition

- (BZObjectStoreFetchConditionModel*)rowidCondition:(NSObject*)object
{
    BZObjectStoreFetchConditionModel *condition = [BZObjectStoreFetchConditionModel condition];
    condition.sqliteCondition.where = [BZObjectStoreQueryBuilder rowidConditionStatement];
    condition.sqliteCondition.parameters = [self rowidAttributeParameter:object];
    return condition;
}

- (BZObjectStoreFetchConditionModel*)uniqueCondition:(NSObject*)object
{
    BZObjectStoreFetchConditionModel *condition = [BZObjectStoreFetchConditionModel condition];
    condition.sqliteCondition.where = [BZObjectStoreQueryBuilder uniqueConditionStatement:self];
    condition.sqliteCondition.parameters = [self identificationAttributesParameters:object];
    return condition;
}

#pragma marks parameter methods

- (NSMutableArray*)insertAttributesParameters:(NSObject*)object
{
    NSMutableArray *parameters = [NSMutableArray array];
    for (BZObjectStoreRuntimeProperty *attribute in self.insertAttributes) {
        [parameters addObject:[attribute storeValueWithObject:object]];
    }
    return parameters;
}

- (NSMutableArray*)insertOrIgnoreAttributesParameters:(NSObject*)object
{
    NSMutableArray *parameters = [NSMutableArray array];
    for (BZObjectStoreRuntimeProperty *attribute in self.insertAttributes) {
        [parameters addObject:[attribute storeValueWithObject:object]];
    }
    return parameters;
}

- (NSMutableArray*)insertOrReplaceAttributesParameters:(NSObject*)object
{
    NSMutableArray *parameters = [NSMutableArray array];
    for (BZObjectStoreRuntimeProperty *attribute in self.attributes) {
        [parameters addObject:[attribute storeValueWithObject:object]];
    }
    return parameters;
}

- (NSMutableArray*)updateAttributesParameters:(NSObject*)object
{
    NSMutableArray *parameters = [NSMutableArray array];
    if (self.hasNotUpdateIfValueIsNullAttribute) {
        for (BZObjectStoreRuntimeProperty *attribute in self.updateAttributes) {
            id value = [attribute storeValueWithObject:object];
            if (value != [NSNull null]) {
                [parameters addObject:value];
            }
        }
    } else {
        for (BZObjectStoreRuntimeProperty *attribute in self.updateAttributes) {
            [parameters addObject:[attribute storeValueWithObject:object]];
        }
    }
    return parameters;
}

- (NSMutableArray*)identificationAttributesParameters:(NSObject*)object
{
    NSMutableArray *parameters = [NSMutableArray array];
    for (BZObjectStoreRuntimeProperty *attribute in self.identificationAttributes) {
        [parameters addObject:[attribute storeValueWithObject:object]];
    }
    return parameters;
}

- (NSMutableArray*)rowidAttributeParameter:(NSObject*)object
{
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObject:[self.attributes.firstObject storeValueWithObject:object]];
    return parameters;
}


#pragma mark value mapper

- (id)object
{
    return [self.osclazz objectWithClazz:self.clazz];
}
- (NSString*)initializingOptionsWithObject:(NSObject*)object
{
    return [self.osclazz initializingOptionsWithObject:object];
}
- (NSEnumerator*)objectEnumeratorWithObject:(id)object
{
    return [self.osclazz objectEnumeratorWithObject:object];
}
- (NSArray*)keysWithObject:(id)object
{
    return [self.osclazz keysWithObject:object];
}
- (id)objectWithObjects:(NSArray*)objects keys:(NSArray*)keys initializingOptions:(NSString*)initializingOptions
{
    return [self.osclazz objectWithObjects:objects keys:keys initializingOptions:initializingOptions];
}
- (id)storeValueWithValue:(NSObject*)value
{
    return [self.osclazz storeValueWithValue:value];
}
- (id)valueWithStoreValue:(NSObject*)value
{
    return [self.osclazz valueWithStoreValue:value];
}

@end
