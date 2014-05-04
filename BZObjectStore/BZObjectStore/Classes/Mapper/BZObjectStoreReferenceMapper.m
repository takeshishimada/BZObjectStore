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

#import "BZObjectStoreReferenceMapper.h"
#import "BZObjectStoreModelInterface.h"
#import "BZObjectStoreRelationshipModel.h"
#import "BZObjectStoreAttributeModel.h"
#import "BZObjectStoreConditionModel.h"
#import "BZObjectStoreRuntime.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreNameBuilder.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
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
- (BOOL)deleteRelationshipObjectsWithObject:(NSObject*)object relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db;
- (NSMutableArray*)relationshipObjectsWithToObject:(NSObject*)toObject relationshipRuntime:(BZObjectStoreRuntime*)relationshipRuntime db:(FMDatabase*)db;
- (void)updateObjectRowid:(NSObject*)object db:(FMDatabase*)db;
- (void)updateRowidWithObjects:(NSArray*)objects db:(FMDatabase*)db;

- (BOOL)existsTable:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db;
- (BOOL)existsIndex:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db;
- (BOOL)createTable:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db;
- (BOOL)createUniqueIndex:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db;
- (BOOL)dropTable:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db;
- (BOOL)dropUniqueIndex:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db;
- (NSArray*)selectAttributes:(BZObjectStoreRuntime*)runtime attributeRuntime:(BZObjectStoreRuntime*)attributeRuntime db:(FMDatabase*)db;
- (BOOL)createAttribute:(BZObjectStoreRuntime*)runtime attributeRuntime:(BZObjectStoreRuntime*)attributeRuntime db:(FMDatabase*)db;
- (BOOL)deleteAttribute:(BZObjectStoreRuntime*)runtime attributeRuntime:(BZObjectStoreRuntime*)attributeRuntime db:(FMDatabase*)db;

- (BOOL)createTable2:(BZObjectStoreRuntime*)runtime attributeRuntime:(BZObjectStoreRuntime*)attributeRuntime db:(FMDatabase*)db;

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
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:clazz db:db error:error];
    NSNumber *value = [self max:runtime columnName:columnName condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return value;
}

- (NSNumber*)min:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error
{
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:clazz db:db error:error];
    NSNumber *value = [self min:runtime columnName:columnName condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return value;
}

- (NSNumber*)avg:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error
{
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:clazz db:db error:error];
    NSNumber *value = [self avg:runtime columnName:columnName condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return value;
}

- (NSNumber*)total:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error
{
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:clazz db:db error:error];
    NSNumber *value = [self total:runtime columnName:columnName condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return value;
}

- (NSNumber*)sum:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error
{
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
        condition = [object.runtime rowidCondition:object];
    } else if (object.runtime.hasIdentificationAttributes) {
        condition = [object.runtime uniqueCondition:object];
    } else {
        return nil;
    }
    NSNumber *count = [self count:object.runtime condition:condition db:db];
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
        condition = [object.runtime rowidCondition:object];
    } else if (object.runtime.hasIdentificationAttributes) {
        condition = [object.runtime uniqueCondition:object];
    } else {
        // toerror
        return nil;
    }
    NSMutableArray *list = [self select:object.runtime condition:condition db:db];
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
    [self updateObjectRowid:object db:db];
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
                targetObject.runtime = runtime;
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
        if (![processedObjects valueForKey:object.objectStoreHashForSave]) {
            [processedObjects setValue:object forKey:object.objectStoreHashForSave];
            if (object.runtime.hasRelationshipAttributes) {
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
        for (BZObjectStoreRuntimeProperty *attribute in targetObject.runtime.relationshipAttributes) {
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
                        NSObject *processedObject = [processedObjects valueForKey:object.objectStoreHashForFetch];
                        if (processedObject) {
                            relationshipObject.attributeFromObject = targetObject;
                            relationshipObject.attributeValue = processedObject;
                        } else {
                            relationshipObject.attributeFromObject = targetObject;
                            relationshipObject.attributeValue = object;
                            object.runtime = runtime;
                            if (object.runtime.hasRelationshipAttributes) {
                                [targetObjects addObject:object];
                            }
                            [processedObjects setValue:object forKey:object.objectStoreHashForFetch];
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
        if (targetObject.runtime.modelDidLoad) {
            [targetObject performSelector:@selector(OSModelDidLoad) withObject:nil];
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
        if (object.runtime.hasRelationshipAttributes) {
            [targetObjects addObjectsFromArray:objects];
        } else {
            if (![processedObjects valueForKey:object.objectStoreHashForSave]) {
                [processedObjects setValue:object forKey:object.objectStoreHashForSave];
            }
        }
    }
    while (targetObjects.count > 0) {
        NSObject *targetObject = [targetObjects lastObject];
        if (![processedObjects valueForKey:targetObject.objectStoreHashForSave]) {
            [processedObjects setValue:targetObject forKey:targetObject.objectStoreHashForSave];
            for (BZObjectStoreRuntimeProperty *attribute in targetObject.runtime.relationshipAttributes) {
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
                        topRelationshipObject.fromClassName = targetObject.runtime.clazzName;
                        topRelationshipObject.fromTableName = targetObject.runtime.tableName;
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
                        topRelationshipObject.attributeToObject.runtime = runtime;
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
                        
                        [self updateRuntime:processingInAttributeObject.targetObjectInAttribute db:db error:error];
                        if ([self hadError:db error:error]) {
                            return NO;
                        }
                        if (processingInAttributeObject.targetObjectInAttribute.runtime.isRelationshipClazz) {
                            enumerator = [processingInAttributeObject.targetObjectInAttribute.runtime objectEnumeratorWithObject:processingInAttributeObject.targetObjectInAttribute];
                            keys = [processingInAttributeObject.targetObjectInAttribute.runtime keysWithObject:processingInAttributeObject.targetObjectInAttribute];
                        }
                        for (NSObject *attributeObjectInEnumerator in enumerator) {
                            Class attributeClazzInEnumerator = [attributeObjectInEnumerator class];
                            BZObjectStoreRuntime *attributeRuntimeInEnumerator = [self runtimeWithClazz:attributeClazzInEnumerator db:db error:error];
                            if ([self hadError:db error:error]) {
                                return NO;
                            }
                            if (attributeRuntimeInEnumerator) {
                                attributeObjectInEnumerator.runtime = attributeRuntimeInEnumerator;
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
                                relationshipObject.fromClassName = targetObject.runtime.clazzName;
                                relationshipObject.fromTableName = targetObject.runtime.tableName;
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
                                relationshipObject.attributeToObject.runtime = attributeRuntimeInEnumerator;
                                [relationshipObjects addObject:relationshipObject];
                                [allRelationshipObjects addObject:relationshipObject];
                                attributeSequence++;
                            }
                        }
                        for (BZObjectStoreRelationshipModel *relationshipObject in relationshipObjects) {
                            if (relationshipObject.attributeToObject.runtime.isArrayClazz) {
                                BZProcessingInAttributeModel *processingInAttributeObject = [[BZProcessingInAttributeModel alloc]init];
                                processingInAttributeObject.parentRelationship = relationshipObject;
                                processingInAttributeObject.targetObjectInAttribute = relationshipObject.attributeToObject;
                                [processingInAttributeObjects addObject:processingInAttributeObject];
                                
                            } else if (relationshipObject.attributeToObject.runtime.isObjectClazz) {
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
            relationshipObject.runtime = relationshipRuntime;
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
                        object.runtime = targetRuntime;
                        object.rowid = relationshipObject.toRowid;
                        object = [self refreshObjectSub:object db:db error:error];
                        if ([self hadError:db error:error]) {
                            return NO;
                        }
                        if (object) {
                            [self removeObjectsSub:@[object] db:db error:error];
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
        if (targetObject.runtime.modelDidSave) {
            [targetObject performSelector:@selector(OSModelDidSave) withObject:nil];
        }
    }

    return YES;
}



#pragma mark remove methods

- (BOOL)removeObjects:(Class)clazz condition:(BZObjectStoreConditionModel*)condition db:(FMDatabase*)db error:(NSError**)error
{
    NSArray *objects = [self fetchObjects:clazz condition:condition db:db error:error];
    if ([self hadError:db error:error]) {
        return NO;
    }
    [self removeObjectsSub:objects db:db error:error];
    if ([self hadError:db error:error]) {
        return NO;
    }
    return YES;
}

- (BOOL)removeObjects:(NSArray*)objects db:(FMDatabase*)db error:(NSError**)error
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
    [self removeObjectsSub:objects db:db error:error];
    if ([self hadError:db error:error]) {
        return NO;
    }
    return YES;
}

- (BOOL)removeObjectsSub:(NSArray*)objects db:(FMDatabase*)db error:(NSError**)error
{
    NSMutableDictionary *processedObjects = [NSMutableDictionary dictionary];
    NSMutableArray *targetObjects = [NSMutableArray array];
    for (NSObject *targetObject in objects) {
        if (targetObject.rowid) {
            if (targetObject.runtime.hasRelationshipAttributes) {
                [targetObjects addObject:targetObject];
            } else {
                if (![processedObjects valueForKey:targetObject.objectStoreHashForSave]) {
                    [processedObjects setValue:targetObject forKey:targetObject.objectStoreHashForSave];
                }
            }
        }
    }
    while (targetObjects.count > 0) {
        NSObject *targetObject = [targetObjects lastObject];
        if (![processedObjects valueForKey:targetObject.objectStoreHashForSave]) {
            [processedObjects setValue:targetObject forKey:targetObject.objectStoreHashForSave];
            for (BZObjectStoreRuntimeProperty *attribute in targetObject.runtime.relationshipAttributes) {
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
                            if (tagetObjectInAttribute.runtime.isRelationshipClazz) {
                                NSEnumerator *enumerator = [tagetObjectInAttribute.runtime objectEnumeratorWithObject:tagetObjectInAttribute];
                                for (NSObject *tagetObjectInEnumeratorInAttribute in enumerator) {
                                    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:[tagetObjectInEnumeratorInAttribute class] db:db error:error];
                                    if (runtime.isObjectClazz) {
                                        tagetObjectInEnumeratorInAttribute.runtime = runtime;
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
            // the following code is not needed
            //  because of fetching processed before this remove method
            //} else {
            //  [objectStuck removeObject:targetObject];
            //}
        }
    }
    
    // remove objects
    BZObjectStoreRuntime *relationshipRuntime = [self runtimeWithClazz:[BZObjectStoreRelationshipModel class] db:db error:error];
    if ([self hadError:db error:error]) {
        return NO;
    }
    NSArray *allValues = processedObjects.allValues;
    for (NSObject *targetObject in allValues) {
        [self deleteFrom:targetObject db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
        [self deleteRelationshipObjectsWithObject:targetObject relationshipRuntime:relationshipRuntime db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
    }
    
    for (NSObject *targetObject in allValues) {
        if (targetObject.runtime.modelDidRemove) {
            [targetObject performSelector:@selector(OSModelDidRemove) withObject:nil];
        }
    }

    return YES;
}







#pragma mark common

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
    if (object.runtime) {
        return YES;
    }
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:[object class] db:db error:error];
    if (!runtime) {
        return NO;
    }
    object.runtime = runtime;
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
    BZObjectStoreRuntime *runtime = [BZObjectStoreRuntime runtimeWithClazz:clazz nameBuilder:self.nameBuilder];
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

- (void)setRegistedAllRuntimeFlag
{
    for (NSString *key in self.registedClazzes.allKeys) {
        [self.registedClazzes setObject:@YES forKey:key];
    }
}

- (BOOL)registerRuntime:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db error:(NSError**)error
{
    NSNumber *registed = [self.registedClazzes objectForKey:runtime.clazzName];
    if (registed.boolValue) {
        return YES;
    }

    BZObjectStoreRuntime *attributeRuntime = [self runtime:[BZObjectStoreAttributeModel class]];
    [self createTable2:runtime attributeRuntime:attributeRuntime db:db];
    if ([self hadError:db error:error]) {
        return NO;
    }
    
    
    [self.registedClazzes setObject:@NO forKey:runtime.clazzName];
    return YES;
}


- (BOOL)unRegisterRuntime:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db error:(NSError**)error
{
    NSNumber *registed = [self.registedClazzes objectForKey:runtime.clazzName];
    if (!registed.boolValue) {
        return YES;
    }
    [self removeObjects:runtime.clazz condition:nil db:db error:error];
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


