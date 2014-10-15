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

#import "BZObjectStoreReferenceMapper.h"
#import "BZObjectStoreModelInterface.h"
#import "BZObjectStoreRelationshipModel.h"
#import "BZObjectStoreConditionModel.h"
#import "BZObjectStoreRuntime.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreNameBuilder.h"
#import "BZObjectStoreClazz.h"
#import "BZObjectStoreNotificationCenter.h"
#import <FMDatabaseQueue.h>
#import <FMDatabase.h>
#import <FMResultSet.h>
#import "FMDatabaseAdditions.h"
#import "NSObject+BZObjectStore.h"

@interface BZObjectStoreModelMapper (Protected)
- (NSNumber*)avg:(BZObjectStoreRuntime*)runtime columnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db;
- (NSNumber*)total:(BZObjectStoreRuntime*)runtime columnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db;
- (NSNumber*)sum:(BZObjectStoreRuntime*)runtime columnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db;
- (NSNumber*)min:(BZObjectStoreRuntime*)runtime columnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db;
- (NSNumber*)max:(BZObjectStoreRuntime*)runtime columnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db;
- (NSNumber*)count:(BZObjectStoreRuntime*)runtime condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db;
- (BOOL)insertOrUpdate:(NSObject*)object db:(FMDatabase*)db;
- (BOOL)deleteFrom:(NSObject*)object db:(FMDatabase*)db;
- (BOOL)deleteFrom:(BZObjectStoreRuntime*)runtime condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db;
- (NSMutableArray*)select:(BZObjectStoreRuntime*)runtime condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db;
- (void)updateSimpleValueWithObject:(NSObject*)object db:(FMDatabase*)db;
- (NSNumber*)referencedCount:(NSObject*)object db:(FMDatabase*)db;

- (NSMutableArray*)relationshipObjectsWithObject:(NSObject*)object attribute:(BZObjectStoreRuntimeProperty*)attribute relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db;
- (BOOL)insertRelationshipObjectsWithRelationshipObjects:(NSArray*)relationshipObjects db:(FMDatabase*)db;
- (BOOL)deleteRelationshipObjectsWithObject:(NSObject*)object attribute:(BZObjectStoreRuntimeProperty*)attribute relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db;
- (BOOL)deleteRelationshipObjectsWithRelationshipObject:(BZObjectStoreRelationshipModel*)relationshipObject db:(FMDatabase*)db;
- (BOOL)deleteRelationshipObjectsWithFromObject:(NSObject*)object relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db;
- (BOOL)deleteRelationshipObjectsWithToObject:(NSObject*)object relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db;
- (NSMutableArray*)relationshipObjectsWithToObject:(NSObject*)toObject relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db;
- (void)updateRowid:(NSObject*)object db:(FMDatabase*)db;
- (void)updateRowidWithObjects:(NSArray*)objects db:(FMDatabase*)db;

- (BOOL)dropTable:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db;
- (NSArray*)selectAttributes:(BZObjectStoreRuntime*)runtime attributeRuntime:(BZObjectStoreRuntime*)attributeRuntime db:(FMDatabase*)db;
- (BOOL)createAttribute:(BZObjectStoreRuntime*)runtime attributeRuntime:(BZObjectStoreRuntime*)attributeRuntime db:(FMDatabase*)db;
- (BOOL)deleteAttribute:(BZObjectStoreRuntime*)runtime attributeRuntime:(BZObjectStoreRuntime*)attributeRuntime db:(FMDatabase*)db;

- (BOOL)createTable:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db;

@end


@interface BZProcessingModel : NSObject
@property (nonatomic,strong) NSObject *targetObject;
@property (nonatomic,strong) BZObjectStoreRuntimeProperty *attribute;
@property (nonatomic,strong) NSMutableArray *relationshipObjects;
@end
@implementation BZProcessingModel
@end

@interface BZProcessingInAttributeModel : NSObject
@property (nonatomic,strong) NSObject *targetObjectInAttribute;
@property (nonatomic,strong) BZObjectStoreRelationshipModel* parentRelationship;
@end
@implementation BZProcessingInAttributeModel
@end

@interface BZObjectStoreReferenceMapper ()
@property (nonatomic,strong) BZObjectStoreNameBuilder *nameBuilder;
@property (nonatomic,strong) NSMutableDictionary *registedClazzes;
@property (nonatomic,strong) NSMutableDictionary *registedRuntimes;
@end

@implementation BZObjectStoreReferenceMapper

+ (NSString*)ignorePrefixName
{
    return nil;
}

+ (NSString*)ignoreSuffixName
{
    return nil;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.registedRuntimes = [NSMutableDictionary dictionary];
        self.registedClazzes = [NSMutableDictionary dictionary];
        BZObjectStoreNameBuilder *nameBuilder = [[BZObjectStoreNameBuilder alloc]init];
        Class clazz = self.class;
        nameBuilder.ignorePrefixName = [clazz ignorePrefixName];
        nameBuilder.ignoreSuffixName = [clazz ignoreSuffixName];
        self.nameBuilder = nameBuilder;
    }
    return self;
}

#pragma mark group methods

- (NSNumber*)max:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateConditionRuntime:condition db:db error:error]) {
        return nil;
    }
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:clazz db:db error:error];
    NSNumber *value = [self max:runtime columnName:columnName condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return value;
}

- (NSNumber*)min:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateConditionRuntime:condition db:db error:error]) {
        return nil;
    }
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:clazz db:db error:error];
    NSNumber *value = [self min:runtime columnName:columnName condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return value;
}

- (NSNumber*)avg:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateConditionRuntime:condition db:db error:error]) {
        return nil;
    }
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:clazz db:db error:error];
    NSNumber *value = [self avg:runtime columnName:columnName condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return value;
}

- (NSNumber*)total:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateConditionRuntime:condition db:db error:error]) {
        return nil;
    }
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:clazz db:db error:error];
    NSNumber *value = [self total:runtime columnName:columnName condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return value;
}

- (NSNumber*)sum:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateConditionRuntime:condition db:db error:error]) {
        return nil;
    }
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:clazz db:db error:error];
    NSNumber *value = [self sum:runtime columnName:columnName condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return value;
}


#pragma mark exists method

- (NSNumber*)existsObject:(NSObject*)object db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateRuntime:object db:db error:error]) {
        return nil;
    }
    BZObjectStoreConditionModel *condition = nil;
    if (object.rowid) {
        condition = [object.OSRuntime rowidCondition:object];
    } else if (object.OSRuntime.hasIdentificationAttributes) {
        condition = [object.OSRuntime uniqueCondition:object];
    } else {
        return nil;
    }
    NSNumber *count = [self count:object.OSRuntime condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    if (!count) {
        return nil;
    } else if ([count isEqualToNumber:@0]) {
        return @NO;
    } else {
        return @YES;
    }
}


#pragma mark count methods

- (NSNumber*)count:(Class)clazz condition:(BZObjectStoreConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateConditionRuntime:condition db:db error:error]) {
        return nil;
    }
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:clazz db:db error:error];
    NSNumber *count = [self count:runtime condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return count;
}

- (NSNumber*)referencedCount:(NSObject*)object db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateRuntime:object db:db error:error]) {
        return nil;
    }
    NSNumber *count = [self referencedCount:object db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return count;
}


#pragma mark fetch methods

- (NSObject*)refreshObject:(NSObject*)object db:(FMDatabase*)db error:(NSError**)error
{
    if (!object) {
        return nil;
    }
    if (![self updateRuntime:object db:db error:error]) {
        return nil;
    }
    return [self refreshObjectSub:object db:db error:error];
}

- (NSObject*)refreshObjectSub:(NSObject*)object db:(FMDatabase*)db error:(NSError**)error
{
    BZObjectStoreConditionModel *condition = nil;
    if (object.rowid) {
        condition = [object.OSRuntime rowidCondition:object];
    } else if (object.OSRuntime.hasIdentificationAttributes) {
        condition = [object.OSRuntime uniqueCondition:object];
    } else {
        return nil;
    }
    if (![self updateConditionRuntime:condition db:db error:error]) {
        return nil;
    }
    NSMutableArray *list = [self select:object.OSRuntime condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    list = [self fetchObjectsSub:list refreshing:YES db:db error:error];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return list.firstObject;
}

- (NSMutableArray*)fetchObjects:(Class)clazz condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateConditionRuntime:condition db:db error:error]) {
        return nil;
    }
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:clazz db:db error:error];
    NSMutableArray *list = [self select:runtime condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    list = [self fetchObjectsSub:list refreshing:NO db:db error:error];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return list;
}

- (NSMutableArray*)fetchReferencingObjectsWithToObject:(NSObject*)object db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateRuntime:object db:db error:error]) {
        return nil;
    }
    [self updateRowid:object db:db];
    if ([db hadError]) {
        return nil;
    }
    if (!object.rowid) {
        return nil;
    }
    BZObjectStoreRuntime *relationshipRuntime = [self runtimeWithClazz:[BZObjectStoreRelationshipModel class] db:db error:error];
    if ([self hadError:db error:error]) {
        return nil;
    }
    NSMutableArray *relationshipObjects = [self relationshipObjectsWithToObject:object relationshipRuntime:relationshipRuntime db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    NSMutableArray *list = [NSMutableArray array];
    for (BZObjectStoreRelationshipModel *relationshipObject in relationshipObjects) {
        Class targetClazz = NSClassFromString(relationshipObject.fromClassName);
        if (targetClazz) {
            BZObjectStoreRuntime *runtime = [self runtimeWithClazz:targetClazz db:db error:error];
            if ([self hadError:db error:error]) {
                return nil;
            }
            if (runtime.isObjectClazz) {
                NSObject *targetObject = [runtime object];
                targetObject.OSRuntime = runtime;
                targetObject.rowid = relationshipObject.fromRowid;
                targetObject = [self refreshObjectSub:targetObject db:db error:error];
                if ([self hadError:db error:error]) {
                    return nil;
                }
                if (*error) {
                    return nil;
                }
                if (targetObject) {
                    [list addObject:targetObject];
                }
            }
        }
    }
    return list;
}

- (NSMutableArray*)fetchObjectsSub:(NSArray*)objects refreshing:(BOOL)refreshing db:(FMDatabase*)db error:(NSError**)error
{
    NSMutableDictionary *processedObjects = [NSMutableDictionary dictionary];
    NSMutableArray *targetObjects = [NSMutableArray array];
    for (NSObject *object in objects) {
        if (![processedObjects valueForKey:object.OSHashForSave]) {
            [processedObjects setValue:object forKey:object.OSHashForSave];
            if (object.rowid && object.OSRuntime.hasRelationshipAttributes) {
                [targetObjects addObject:object];
            }
        }
    }
    BZObjectStoreRuntime *relationshipRuntime = [self runtimeWithClazz:[BZObjectStoreRelationshipModel class] db:db error:error];
    if ([self hadError:db error:error]) {
        return nil;
    }
    while (targetObjects.count > 0) {
        
        // each object
        NSObject *targetObject = [targetObjects lastObject];
        // each object-attribute
        for (BZObjectStoreRuntimeProperty *attribute in targetObject.OSRuntime.relationshipAttributes) {
            BOOL ignoreFetch = NO;
            if (attribute.fetchOnRefreshingAttribute) {
                if (!(refreshing && [objects containsObject:targetObject])) {
                    ignoreFetch = YES;
                }
            }
            if (!ignoreFetch) {
                BZProcessingModel *processingObject = [[BZProcessingModel alloc]init];
                processingObject.targetObject = targetObject;
                processingObject.attribute = attribute;
                processingObject.relationshipObjects = [self relationshipObjectsWithObject:targetObject attribute:attribute relationshipRuntime:relationshipRuntime db:db];
                for (BZObjectStoreRelationshipModel *relationshipObject in processingObject.relationshipObjects) {
                    Class attributeClazz = NSClassFromString(relationshipObject.toClassName);
                    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:attributeClazz db:db error:error];
                    if ([self hadError:db error:error]) {
                        return nil;
                    }
                    if (runtime.isObjectClazz) {
                        NSObject *object = [runtime object];
                        object.rowid = relationshipObject.toRowid;
                        NSObject *processedObject = [processedObjects valueForKey:object.OSHashForFetch];
                        if (processedObject) {
                            relationshipObject.attributeFromObject = targetObject;
                            relationshipObject.attributeValue = processedObject;
                        } else {
                            relationshipObject.attributeFromObject = targetObject;
                            relationshipObject.attributeValue = object;
                            object.OSRuntime = runtime;
                            if (object.OSRuntime.hasRelationshipAttributes) {
                                [targetObjects addObject:object];
                            }
                            [processedObjects setValue:object forKey:object.OSHashForFetch];
                        }
                        
                    } else if (runtime.isArrayClazz) {
                        NSMutableArray *objects = [NSMutableArray array];
                        NSMutableArray *keys = [NSMutableArray array];
                        for (BZObjectStoreRelationshipModel *child in processingObject.relationshipObjects) {
                            if ([child.attributeParentLevel isEqualToNumber:relationshipObject.attributeLevel]) {
                                if ([child.attributeParentSequence isEqualToNumber:relationshipObject.attributeSequence]) {
                                    if (child.attributeValue) {
                                        if (child.attributeKey) {
                                            [keys addObject:child.attributeKey];
                                        } else {
                                            [keys addObject:[NSNull null]];
                                        }
                                        [objects addObject:child.attributeValue];
                                    }
                                }
                            }
                        }
                        NSObject *value = [runtime objectWithObjects:objects keys:keys initializingOptions:relationshipObject.attributeKey];
                        relationshipObject.attributeFromObject = targetObject;
                        relationshipObject.attributeValue = value;
                    } else if (runtime.isSimpleValueClazz ) {
                        Class clazz = NSClassFromString(relationshipObject.toClassName);
                        if (clazz) {
                            relationshipObject.attributeFromObject = targetObject;
                        }
                    }
                    
                    if (runtime) {
                        if (relationshipObject == processingObject.relationshipObjects.lastObject) {
                            [targetObject setValue:relationshipObject.attributeValue forKey:attribute.name];
                        }
                    }
                }
            }
        }
        [targetObjects removeObject:targetObject];
    }

    
    // fetch objects
    NSArray *allValues = processedObjects.allValues;
    for (NSObject *targetObject in allValues) {
        [self updateSimpleValueWithObject:targetObject db:db];
        if ([self hadError:db error:error]) {
            return nil;
        }
    }
    
    for (NSObject *targetObject in allValues) {
        if (targetObject.OSRuntime.modelDidLoad) {
            if ([targetObject respondsToSelector:@selector(OSModelDidLoad)]) {
                [targetObject performSelector:@selector(OSModelDidLoad) withObject:nil];
            }
        }
    }

    return [NSMutableArray arrayWithArray:objects];
}


#pragma mark save methods

- (BOOL)saveObjects:(NSArray*)objects db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateRuntimes:objects db:db error:error]) {
        return NO;
    }
    if ([self hadError:db error:error]) {
        return NO;
    }
    return [self saveObjectsSub:objects db:db error:error];
}

- (BOOL)saveObjectsSub:(NSArray*)objects db:(FMDatabase*)db error:(NSError**)error
{
    NSMutableArray *processingObjects = [NSMutableArray array];
    NSMutableDictionary *processedObjects = [NSMutableDictionary dictionary];
    NSMutableArray *targetObjects = [NSMutableArray array];
    for (NSObject *object in objects) {
        if (object.OSRuntime.hasRelationshipAttributes) {
            [targetObjects addObjectsFromArray:objects];
        } else {
            if (![processedObjects valueForKey:object.OSHashForSave]) {
                [processedObjects setValue:object forKey:object.OSHashForSave];
            }
        }
    }
    while (targetObjects.count > 0) {
        NSObject *targetObject = [targetObjects lastObject];
        if (![processedObjects valueForKey:targetObject.OSHashForSave]) {
            [processedObjects setValue:targetObject forKey:targetObject.OSHashForSave];
            for (BZObjectStoreRuntimeProperty *attribute in targetObject.OSRuntime.relationshipAttributes) {
                NSObject *targetObjectInAttribute = [targetObject valueForKey:attribute.name];
                BZProcessingModel *processingObject = [[BZProcessingModel alloc]init];
                processingObject.targetObject = targetObject;
                processingObject.attribute = attribute;
                if (targetObjectInAttribute) {
                    
                    NSMutableArray *processingInAttributeObjects = [NSMutableArray array];
                    NSMutableArray *allRelationshipObjects = [NSMutableArray array];
                    
                    BZObjectStoreRuntime *runtime;
                    if (attribute.clazz ) {
                        runtime = [self runtimeWithClazz:attribute.clazz db:db error:error];
                        if ([self hadError:db error:error]) {
                            return NO;
                        }
                    } else {
                        runtime = [self runtimeWithClazz:[targetObjectInAttribute class] db:db error:error];
                        if ([self hadError:db error:error]) {
                            return NO;
                        }
                    }
                    if (runtime.isArrayClazz) {
                        BZObjectStoreRelationshipModel *topRelationshipObject = [[BZObjectStoreRelationshipModel alloc]init];
                        topRelationshipObject.fromClassName = targetObject.OSRuntime.clazzName;
                        topRelationshipObject.fromTableName = targetObject.OSRuntime.tableName;
                        topRelationshipObject.fromAttributeName = attribute.name;
                        topRelationshipObject.fromRowid = @0;
                        topRelationshipObject.toClassName = attribute.clazzName;
                        topRelationshipObject.toTableName = nil;
                        topRelationshipObject.toRowid = @0;
                        topRelationshipObject.attributeValue = nil;
                        topRelationshipObject.attributeLevel = @1;
                        topRelationshipObject.attributeSequence = @1;
                        topRelationshipObject.attributeParentLevel = @0;
                        topRelationshipObject.attributeParentSequence = @0;
                        topRelationshipObject.attributeFromObject = targetObject;
                        topRelationshipObject.attributeToObject = [targetObject valueForKey:attribute.name];
                        topRelationshipObject.attributeToObject.OSRuntime = runtime;
                        topRelationshipObject.attributeKey = nil;
                        [allRelationshipObjects addObject:topRelationshipObject];
                        
                        BZProcessingInAttributeModel *processingInAttributeObject = [[BZProcessingInAttributeModel alloc]init];
                        processingInAttributeObject.parentRelationship = topRelationshipObject;
                        processingInAttributeObject.targetObjectInAttribute = targetObjectInAttribute;
                        [processingInAttributeObjects addObject:processingInAttributeObject];
                        
                    } else if (runtime.isObjectClazz || runtime.isSimpleValueClazz) {
                        BZProcessingInAttributeModel *processingInAttributeObject = [[BZProcessingInAttributeModel alloc]init];
                        processingInAttributeObject.parentRelationship = nil;
                        processingInAttributeObject.targetObjectInAttribute = targetObjectInAttribute;
                        [processingInAttributeObjects addObject:processingInAttributeObject];
                        
                    }
                    
                    while (processingInAttributeObjects.count > 0) {
                        BZProcessingInAttributeModel *processingInAttributeObject = [processingInAttributeObjects lastObject];
                        [processingInAttributeObjects removeLastObject];
                        
                        NSMutableArray *relationshipObjects = [NSMutableArray array];
                        NSEnumerator *enumerator = nil;
                        NSArray *keys = nil;
                        NSInteger attributeSequence = 1;
                        NSNumber *attributeLevel = [NSNumber numberWithUnsignedInteger:[processingInAttributeObject.parentRelationship.attributeLevel unsignedIntegerValue] + 1];
                        NSNumber *attributeParentLevel = processingInAttributeObject.parentRelationship.attributeLevel;
                        NSNumber *attributeParentSequence = processingInAttributeObject.parentRelationship.attributeSequence;
                        if (!attributeParentLevel) {
                            attributeParentLevel = @0;
                        }
                        if (!attributeParentSequence) {
                            attributeParentSequence = @0;
                        }
                        
                        BZObjectStoreRuntime *runtime = [self runtimeWithClazz:processingInAttributeObject.targetObjectInAttribute.class db:db error:error];
                        if ([self hadError:db error:error]) {
                            return NO;
                        }
                        if (runtime.isRelationshipClazz) {
                            processingInAttributeObject.targetObjectInAttribute.OSRuntime = runtime;
                            enumerator = [processingInAttributeObject.targetObjectInAttribute.OSRuntime objectEnumeratorWithObject:processingInAttributeObject.targetObjectInAttribute];
                            keys = [processingInAttributeObject.targetObjectInAttribute.OSRuntime keysWithObject:processingInAttributeObject.targetObjectInAttribute];
                        }
                        for (NSObject *attributeObjectInEnumerator in enumerator) {
                            Class attributeClazzInEnumerator = [attributeObjectInEnumerator class];
                            BZObjectStoreRuntime *attributeRuntimeInEnumerator = [self runtimeWithClazz:attributeClazzInEnumerator db:db error:error];
                            if ([self hadError:db error:error]) {
                                return NO;
                            }
                            if (attributeRuntimeInEnumerator) {
                                if (attributeRuntimeInEnumerator.isRelationshipClazz) {
                                    attributeObjectInEnumerator.OSRuntime = attributeRuntimeInEnumerator;
                                }
                                NSString *attributeObjectClassName = nil;
                                NSString *attributeObjectTableName = nil;
                                NSObject *attributeObject = nil;
                                NSObject *attributeValue = nil;
                                if (attributeRuntimeInEnumerator.isObjectClazz) {
                                    attributeObject = attributeObjectInEnumerator;
                                    attributeObjectTableName = [self.nameBuilder tableName:[attributeObjectInEnumerator class]];;
                                    attributeObjectClassName = attributeRuntimeInEnumerator.clazzName;
                                } else if (attributeRuntimeInEnumerator.isArrayClazz ) {
                                    attributeObject = attributeObjectInEnumerator;
                                    attributeObjectClassName = attributeRuntimeInEnumerator.clazzName;
                                } else if (attributeRuntimeInEnumerator.isSimpleValueClazz) {
                                    attributeObject = attributeObjectInEnumerator;
                                    attributeObjectClassName = attributeRuntimeInEnumerator.clazzName;
                                    attributeValue = attributeObjectInEnumerator;
                                }
                                BZObjectStoreRelationshipModel *relationshipObject = [[BZObjectStoreRelationshipModel alloc]init];
                                relationshipObject.fromClassName = targetObject.OSRuntime.clazzName;
                                relationshipObject.fromTableName = targetObject.OSRuntime.tableName;
                                relationshipObject.fromAttributeName = attribute.name;
                                relationshipObject.fromRowid = @0;
                                relationshipObject.toClassName = attributeObjectClassName;
                                relationshipObject.toTableName = attributeObjectTableName;
                                relationshipObject.toRowid = @0;
                                relationshipObject.attributeValue = attributeValue;
                                relationshipObject.attributeLevel = attributeLevel;
                                relationshipObject.attributeSequence = [NSNumber numberWithInteger:attributeSequence];
                                relationshipObject.attributeParentLevel = attributeParentLevel;
                                relationshipObject.attributeParentSequence = attributeParentSequence;
                                relationshipObject.attributeFromObject = targetObject;
                                relationshipObject.attributeToObject = attributeObject;
                                if (keys) {
                                    relationshipObject.attributeKey = keys[attributeSequence - 1];
                                } else {
                                    relationshipObject.attributeKey = nil;
                                }
                                if (attributeRuntimeInEnumerator.isRelationshipClazz) {
                                    relationshipObject.attributeToObject.OSRuntime = attributeRuntimeInEnumerator;
                                }
                                [relationshipObjects addObject:relationshipObject];
                                [allRelationshipObjects addObject:relationshipObject];
                                attributeSequence++;
                            }
                        }
                        for (BZObjectStoreRelationshipModel *relationshipObject in relationshipObjects) {
                            if (relationshipObject.attributeToObject.OSRuntime.isArrayClazz) {
                                BZProcessingInAttributeModel *processingInAttributeObject = [[BZProcessingInAttributeModel alloc]init];
                                processingInAttributeObject.parentRelationship = relationshipObject;
                                processingInAttributeObject.targetObjectInAttribute = relationshipObject.attributeToObject;
                                [processingInAttributeObjects addObject:processingInAttributeObject];
                                
                            } else if (relationshipObject.attributeToObject.OSRuntime.isObjectClazz) {
                                [targetObjects addObject:relationshipObject.attributeToObject];
                            }
                        }
                    }
                    processingObject.relationshipObjects = allRelationshipObjects;
                }
                [processingObjects addObject:processingObject];
            }
            [targetObjects removeObject:targetObject];
        } else {
            [targetObjects removeObject:targetObject];
        }
    }
    
    // save objects
    NSArray *allValues = processedObjects.allValues;
    for (NSObject *targetObject in allValues) {
        [self insertOrUpdate:targetObject db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
    }
    
    // save relationship
    BZObjectStoreRuntime *relationshipRuntime = [self runtimeWithClazz:[BZObjectStoreRelationshipModel class] db:db error:error];
    if ([self hadError:db error:error]) {
        return NO;
    }
    for (BZProcessingModel *processingObject in processingObjects) {
        for (BZObjectStoreRelationshipModel *relationshipObject in processingObject.relationshipObjects) {
            relationshipObject.OSRuntime = relationshipRuntime;
            relationshipObject.fromRowid = relationshipObject.attributeFromObject.rowid;
            if (relationshipObject.attributeToObject) {
                if (relationshipObject.toTableName) {
                    relationshipObject.toRowid = relationshipObject.attributeToObject.rowid;
                }
            }
        }
    }
    for (BZProcessingModel *processingObject in processingObjects) {
        for (BZObjectStoreRelationshipModel *relationshipObject in processingObject.relationshipObjects) {
            [self deleteRelationshipObjectsWithRelationshipObject:relationshipObject db:db];
            if ([self hadError:db error:error]) {
                return NO;
            }
        }
        NSMutableArray *relationshipObjects = [self relationshipObjectsWithObject:processingObject.targetObject attribute:processingObject.attribute relationshipRuntime:relationshipRuntime db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
        if (!processingObject.attribute.weakReferenceAttribute) {
            for (BZObjectStoreRelationshipModel *relationshipObject in relationshipObjects) {
                if (relationshipObject.toTableName) {
                    Class targetClazz = NSClassFromString(relationshipObject.toClassName);
                    BZObjectStoreRuntime *targetRuntime = [self runtimeWithClazz:targetClazz db:db error:error];
                    if ([self hadError:db error:error]) {
                        return NO;
                    }
                    if (targetRuntime.isObjectClazz) {
                        NSObject *object = [targetRuntime object];
                        object.OSRuntime = targetRuntime;
                        object.rowid = relationshipObject.toRowid;
                        object = [self refreshObjectSub:object db:db error:error];
                        if ([self hadError:db error:error]) {
                            return NO;
                        }
                        if (object) {
                            [self deleteObjectsSub:@[object] db:db error:error];
                            if ([self hadError:db error:error]) {
                                return NO;
                            }
                        }
                    }
                }
            }
        }
        [self deleteRelationshipObjectsWithObject:processingObject.targetObject attribute:processingObject.attribute relationshipRuntime:relationshipRuntime db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
        [self insertRelationshipObjectsWithRelationshipObjects:processingObject.relationshipObjects db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
    }
    
    for (NSObject *targetObject in allValues) {
        if (targetObject.OSRuntime.modelDidSave) {
            if ([targetObject respondsToSelector:@selector(OSModelDidSave)]) {
                [targetObject performSelector:@selector(OSModelDidSave) withObject:nil];
            }
        }
        if (!self.disableNotifications) {
            if (targetObject.OSRuntime.cascadeNotification) {
                BZObjectStoreNotificationCenter *center  = [[BZObjectStoreNotificationCenter alloc]init];
                [center postOSNotification:targetObject notificationType:BZObjectStoreNotificationTypeSaved];
            }
        }
    }

    for (NSObject *targetObject in objects) {
        if (!self.disableNotifications) {
            if (targetObject.OSRuntime.notification && !targetObject.OSRuntime.cascadeNotification) {
                BZObjectStoreNotificationCenter *center  = [[BZObjectStoreNotificationCenter alloc]init];
                [center postOSNotification:targetObject notificationType:BZObjectStoreNotificationTypeSaved];
            }
        }
    }

    return YES;
}



#pragma mark delete methods

- (BOOL)deleteObjects:(Class)clazz condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateConditionRuntime:condition db:db error:error]) {
        return NO;
    }
    NSArray *objects = [self fetchObjects:clazz condition:condition db:db error:error];
    if ([self hadError:db error:error]) {
        return NO;
    }
    [self deleteObjectsSub:objects db:db error:error];
    if ([self hadError:db error:error]) {
        return NO;
    }
    return YES;
}

- (BOOL)deleteObjects:(NSArray*)objects db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateRuntimes:objects db:db error:error]) {
        return NO;
    }
    [self updateRowidWithObjects:objects db:db];
    if ([self hadError:db error:error]) {
        return NO;
    }
    objects = [self fetchObjectsSub:objects refreshing:YES db:db error:error];
    if ([self hadError:db error:error]) {
        return NO;
    }
    [self deleteObjectsSub:objects db:db error:error];
    if ([self hadError:db error:error]) {
        return NO;
    }
    return YES;
}

- (BOOL)deleteObjectsSub:(NSArray*)objects db:(FMDatabase*)db error:(NSError**)error
{
    NSMutableDictionary *processedObjects = [NSMutableDictionary dictionary];
    NSMutableArray *targetObjects = [NSMutableArray array];
    for (NSObject *targetObject in objects) {
        if (targetObject.rowid) {
            if (targetObject.OSRuntime.hasRelationshipAttributes) {
                [targetObjects addObject:targetObject];
            } else {
                if (![processedObjects valueForKey:targetObject.OSHashForSave]) {
                    [processedObjects setValue:targetObject forKey:targetObject.OSHashForSave];
                }
            }
        }
    }
    while (targetObjects.count > 0) {
        NSObject *targetObject = [targetObjects lastObject];
        if (![processedObjects valueForKey:targetObject.OSHashForSave]) {
            [processedObjects setValue:targetObject forKey:targetObject.OSHashForSave];
            for (BZObjectStoreRuntimeProperty *attribute in targetObject.OSRuntime.relationshipAttributes) {
                if (!attribute.weakReferenceAttribute) {
                    NSObject *tagetObjectInAttribute = [targetObject valueForKey:attribute.name];
                    if (tagetObjectInAttribute) {
                        NSMutableArray *tagetObjectsInAttribute = [NSMutableArray array];
                        [tagetObjectsInAttribute addObject:tagetObjectInAttribute];
                        
                        while (tagetObjectsInAttribute.count > 0) {
                            NSObject *tagetObjectInAttribute = [tagetObjectsInAttribute lastObject];
                            [tagetObjectsInAttribute removeLastObject];
                            [self updateRuntime:tagetObjectInAttribute db:db error:error];
                            if ([self hadError:db error:error]) {
                                return NO;
                            }
                            if (tagetObjectInAttribute.OSRuntime.isRelationshipClazz) {
                                NSEnumerator *enumerator = [tagetObjectInAttribute.OSRuntime objectEnumeratorWithObject:tagetObjectInAttribute];
                                for (NSObject *tagetObjectInEnumeratorInAttribute in enumerator) {
                                    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:[tagetObjectInEnumeratorInAttribute class] db:db error:error];
                                    if (runtime.isObjectClazz) {
                                        tagetObjectInEnumeratorInAttribute.OSRuntime = runtime;
                                        [targetObjects addObject:tagetObjectInEnumeratorInAttribute];
                                    } else if (runtime.isArrayClazz) {
                                        [tagetObjectsInAttribute addObject:tagetObjectInEnumeratorInAttribute];
                                    }
                                }
                            }
                        }
                    }
                }
            }
            [targetObjects removeObject:targetObject];
        } else {
            [targetObjects removeObject:targetObject];
        }
    }
    
    // delete objects
    BZObjectStoreRuntime *relationshipRuntime = [self runtimeWithClazz:[BZObjectStoreRelationshipModel class] db:db error:error];
    if ([self hadError:db error:error]) {
        return NO;
    }
    // delete objects
    NSArray *allValues = processedObjects.allValues;
    for (NSObject *targetObject in allValues) {
        [self deleteFrom:targetObject db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
        [self deleteRelationshipObjectsWithFromObject:targetObject relationshipRuntime:relationshipRuntime db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
    }
    
    // referencing objects
    NSMutableDictionary *referencingObjects = [NSMutableDictionary dictionary];
    for (NSObject *targetObject in allValues) {
        NSMutableArray *relationshipObjects = [self relationshipObjectsWithToObject:targetObject relationshipRuntime:relationshipRuntime db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
        for (BZObjectStoreRelationshipModel *relationshipObject in relationshipObjects) {
            Class targetClazz = NSClassFromString(relationshipObject.fromClassName);
            if (targetClazz) {
                BZObjectStoreRuntime *runtime = [self runtimeWithClazz:targetClazz db:db error:error];
                if ([self hadError:db error:error]) {
                    return NO;
                }
                if (runtime.isObjectClazz && runtime.cascadeNotification) {
                    NSObject *referencingObject = [runtime object];
                    referencingObject.OSRuntime = runtime;
                    referencingObject.rowid = relationshipObject.fromRowid;
                    [referencingObjects setValue:referencingObject forKey:referencingObject.OSHashForSave];
                }
            }
        }
        [self deleteRelationshipObjectsWithToObject:targetObject relationshipRuntime:relationshipRuntime db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
    }
    
    // delete events and notifications
    for (NSObject *targetObject in allValues) {
        if (targetObject.OSRuntime.modelDidDelete) {
            if ([targetObject respondsToSelector:@selector(OSModelDidDelete)]) {
                [targetObject performSelector:@selector(OSModelDidDelete) withObject:nil];
            }
        }
        if (!self.disableNotifications) {
            if (targetObject.OSRuntime.cascadeNotification) {
                BZObjectStoreNotificationCenter *center  = [[BZObjectStoreNotificationCenter alloc]init];
                [center postOSNotification:targetObject notificationType:BZObjectStoreNotificationTypeDeleted];
            }
        }
    }
    
    // delete cascade notifications
    for (NSObject *targetObject in objects) {
        if (!self.disableNotifications) {
            if (targetObject.OSRuntime.notification && !targetObject.OSRuntime.cascadeNotification) {
                BZObjectStoreNotificationCenter *center  = [[BZObjectStoreNotificationCenter alloc]init];
                [center postOSNotification:targetObject notificationType:BZObjectStoreNotificationTypeDeleted];
            }
        }
    }
    
    // save cascade notifications
    for (NSObject *targetObject in referencingObjects.allValues) {
        NSObject *latestObject = [self refreshObjectSub:targetObject db:db error:error];
        if ([self hadError:db error:error]) {
            return NO;
        }
        BZObjectStoreNotificationCenter *center  = [[BZObjectStoreNotificationCenter alloc]init];
        [center postOSNotification:latestObject notificationType:BZObjectStoreNotificationTypeSaved];
    }
    
    
    for (NSObject *targetObject in allValues) {
        targetObject.rowid = nil;
    }

    
    return YES;
}







#pragma mark common

- (BOOL)updateConditionRuntime:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db error:(NSError**)error
{
    if (condition.reference.from) {
        if (![self updateRuntime:condition.reference.from db:db error:error]) {
            return NO;
        }
    }
    if (condition.reference.to) {
        if (![self updateRuntime:condition.reference.to db:db error:error]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)updateRuntimes:(NSArray*)objects db:(FMDatabase*)db error:(NSError**)error
{
    for (NSObject *object in objects) {
        if (![self updateRuntime:object db:db error:error]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)updateRuntime:(NSObject*)object db:(FMDatabase*)db error:(NSError**)error
{
    if (object.OSRuntime) {
        return YES;
    }
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:[object class] db:db error:error];
    if (!runtime) {
        return NO;
    }
    object.OSRuntime = runtime;
    return YES;
}


- (BZObjectStoreRuntime*)runtimeWithClazz:(Class)clazz db:(FMDatabase*)db error:(NSError**)error
{
    BZObjectStoreRuntime *runtime = [self runtime:clazz];
    if (!runtime) {
        return nil;
    }
    if (runtime.isObjectClazz) {
        [self registerRuntime:runtime db:db error:error];
        if ([self hadError:db error:nil]) {
            return nil;
        }
    }
    return runtime;
}

- (BOOL)hadError:(FMDatabase*)db error:(NSError**)error
{
    if ([db hadError]) {
        return YES;
    } else if (error) {
        if (*error) {
            return YES;
        }
    }
    return NO;
}


- (BZObjectStoreRuntime*)runtime:(Class)clazz
{
    if (clazz == NULL) {
        return nil;
    }
    
    Class targetClazz = NULL;
    BZObjectStoreClazz *osclazz = [BZObjectStoreClazz osclazzWithClazz:clazz];
    if (osclazz.isObjectClazz) {
        targetClazz = clazz;
    } else {
        targetClazz = osclazz.superClazz;
    }
   
    BZObjectStoreRuntime *runtime = [self.registedRuntimes objectForKey:NSStringFromClass(targetClazz)];
    if (!runtime) {
        runtime = [[BZObjectStoreRuntime alloc]initWithClazz:targetClazz osclazz:osclazz nameBuilder:self.nameBuilder];
        [self.registedRuntimes setObject:runtime forKey:NSStringFromClass(targetClazz)];
    }
    return runtime;
    
}

- (void)setRegistedRuntimeFlag:(BZObjectStoreRuntime*)runtime
{
    [self.registedClazzes setObject:@YES forKey:runtime.clazzName];
}

- (void)setUnRegistedRuntimeFlag:(BZObjectStoreRuntime*)runtime
{
    [self.registedClazzes removeObjectForKey:runtime.clazzName];
}

- (void)setUnRegistedAllRuntimeFlag
{
    for (NSString *key in self.registedClazzes.allKeys) {
        [self.registedClazzes removeObjectForKey:key];
    }
}

- (BOOL)registerRuntime:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db error:(NSError**)error
{
    NSNumber *registed = [self.registedClazzes objectForKey:runtime.clazzName];
    if (registed) {
        return YES;
    }

    if (runtime.isObjectClazz) {
        [self createTable:runtime db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
        if (runtime.clazz == [BZObjectStoreRelationshipModel class]) {
            return YES;
        }
        if (runtime.clazz == [BZObjectStoreRuntime class]) {
            return YES;
        }
        if (runtime.clazz == [BZObjectStoreRuntimeProperty class]) {
            return YES;
        }
        if (![self updateRuntime:runtime db:db error:error]) {
            return NO;
        }
        [self updateRowid:runtime db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
        [self saveObjects:@[runtime] db:db error:error];
        if ([self hadError:db error:error]) {
            return NO;
        }
    }
    
    [self.registedClazzes setObject:@YES forKey:runtime.clazzName];
    return YES;
}


- (BOOL)unRegisterRuntime:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db error:(NSError**)error
{
    NSNumber *registed = [self.registedClazzes objectForKey:runtime.clazzName];
    if (!registed.boolValue) {
        return YES;
    }
    [self deleteObjects:runtime.clazz condition:nil db:db error:error];
    if ([self hadError:db error:error]) {
        return NO;
    }
    [self dropTable:runtime db:db];
    if ([self hadError:db error:error]) {
        return NO;
    }
    return YES;
}

@end


