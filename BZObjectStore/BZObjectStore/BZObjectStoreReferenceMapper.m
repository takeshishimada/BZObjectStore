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

#import "BZObjectStoreReferenceMapper.h"
#import "BZObjectStoreAttributeInterface.h"
#import "BZObjectStoreRelationshipModel.h"
#import "BZObjectStoreAttributeModel.h"
#import "BZObjectStoreFetchConditionModel.h"
#import "BZObjectStoreRuntime.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreNameBuilder.h"
#import "BZObjectStoreError.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabase+TemporaryTable.h"
#import "NSObject+BZObjectStore.h"

@interface BZObjectStoreRuntimeMapper (Protected)
- (BZObjectStoreRuntime*)runtime:(Class)clazz;
- (BOOL)registerAllRuntimes:(FMDatabase*)db;
- (void)registedRuntime:(BZObjectStoreRuntime*)runtime;
- (BOOL)registerRuntime:(BZObjectStoreRuntime*)runtime db:(FMDatabase*)db;
@end

@interface BZObjectStoreModelMapper (Protected)
- (NSNumber*)avg:(NSString*)columnName attribute:(BZObjectStoreRuntimeProperty*)attribute condition:(BZObjectStoreFetchConditionModel*)condition db:(FMDatabase*)db;
- (NSNumber*)total:(NSString*)columnName attribute:(BZObjectStoreRuntimeProperty*)attribute condition:(BZObjectStoreFetchConditionModel*)condition db:(FMDatabase*)db;
- (NSNumber*)sum:(NSString*)columnName attribute:(BZObjectStoreRuntimeProperty*)attribute condition:(BZObjectStoreFetchConditionModel*)condition db:(FMDatabase*)db;
- (NSNumber*)min:(NSString*)columnName attribute:(BZObjectStoreRuntimeProperty*)attribute condition:(BZObjectStoreFetchConditionModel*)condition db:(FMDatabase*)db;
- (NSNumber*)max:(NSString*)columnName attribute:(BZObjectStoreRuntimeProperty*)attribute condition:(BZObjectStoreFetchConditionModel*)condition db:(FMDatabase*)db;
- (NSNumber*)groupWithStatement:(NSString*)statement attribute:(BZObjectStoreRuntimeProperty*)attribute condition:(BZObjectStoreFetchConditionModel*)condition db:(FMDatabase*)db;
- (NSNumber*)count:(BZObjectStoreRuntime*)runtime condition:(BZObjectStoreFetchConditionModel*)condition db:(FMDatabase*)db;
- (BOOL)insertOrReplace:(NSObject*)object db:(FMDatabase*)db;
- (BOOL)deleteFrom:(NSObject*)object db:(FMDatabase*)db;
- (BOOL)deleteFrom:(BZObjectStoreRuntime*)runtime condition:(BZObjectStoreFetchConditionModel*)condition db:(FMDatabase*)db;
- (FMResultSet*)resultSet:(BZObjectStoreRuntime*)runtime condition:(BZObjectStoreFetchConditionModel*)condition db:(FMDatabase*)db;
- (FMResultSet*)resultSet:(NSObject*)object db:(FMDatabase*)db;
- (NSNumber*)referencedCount:(NSObject*)object db:(FMDatabase*)db;
- (NSMutableArray*)relationshipObjectsWithObject:(NSObject*)object attribute:(BZObjectStoreRuntimeProperty*)attribute db:(FMDatabase*)db;
- (BOOL)insertRelationshipObjectsWithRelationshipObjects:(NSArray*)relationshipObjects db:(FMDatabase*)db;
- (BOOL)deleteRelationshipObjectsWithObject:(NSObject*)object attribute:(BZObjectStoreRuntimeProperty*)attribute db:(FMDatabase*)db;
- (BOOL)deleteRelationshipObjectsWithRelationshipObject:(BZObjectStoreRelationshipModel*)relationshipObject db:(FMDatabase*)db;
- (BOOL)deleteRelationshipObjectsWithObject:(NSObject*)object db:(FMDatabase*)db;
- (NSMutableArray*)relationshipObjectsWithToObject:(NSObject*)toObject db:(FMDatabase*)db;
- (void)updateRowid:(NSObject*)object db:(FMDatabase*)db;
@end

@interface BZObjectStoreRuntimeMapper()
@property (nonatomic,strong) BZObjectStoreNameBuilder *nameBuilder;
@end

@interface BZObjectStoreObjectAttributeModel : NSObject
@property (nonatomic,strong) NSObject *object;
@property (nonatomic,strong) BZObjectStoreRuntimeProperty *attribute;
@property (nonatomic,strong) NSMutableArray *relationshipObjects;
@end
@implementation BZObjectStoreObjectAttributeModel
@end

@interface BZObjectStoreObjectAttributeStuckObject : NSObject
@property (nonatomic,strong) NSObject *attributeObject;
@property (nonatomic,strong) BZObjectStoreRelationshipModel* parentRelationship;
@end
@implementation BZObjectStoreObjectAttributeStuckObject
@end

@implementation BZObjectStoreReferenceMapper

#pragma mark group methods

- (NSNumber*)max:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreFetchConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error
{
    BZObjectStoreRuntimeProperty *attribute = [self groupFunctionAttributeWithColumnName:columnName clazz:clazz db:db error:error];
    if (*error) {
        return nil;
    }
    id value = [self max:columnName attribute:attribute condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return value;
}

- (NSNumber*)min:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreFetchConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error
{
    BZObjectStoreRuntimeProperty *attribute = [self groupFunctionAttributeWithColumnName:columnName clazz:clazz db:db error:error];
    if (*error) {
        return nil;
    }
    id value = [self min:columnName attribute:attribute condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return value;
}

- (NSNumber*)avg:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreFetchConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error
{
    BZObjectStoreRuntimeProperty *attribute = [self groupFunctionAttributeWithColumnName:columnName clazz:clazz db:db error:error];
    if (*error) {
        return nil;
    }
    id value = [self avg:columnName attribute:attribute condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return value;
}

- (NSNumber*)total:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreFetchConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error
{
    BZObjectStoreRuntimeProperty *attribute = [self groupFunctionAttributeWithColumnName:columnName clazz:clazz db:db error:error];
    if (*error) {
        return nil;
    }
    id value = [self total:columnName attribute:attribute condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return value;
}

- (NSNumber*)sum:(NSString*)columnName class:(Class)clazz condition:(BZObjectStoreFetchConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error
{
    BZObjectStoreRuntimeProperty *attribute = [self groupFunctionAttributeWithColumnName:columnName clazz:clazz db:db error:error];
    if (*error) {
        return nil;
    }
    id value = [self sum:columnName attribute:attribute condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return value;
}


#pragma mark exists method

- (NSNumber*)existsObject:(NSObject*)object db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateRuntime:object db:db]) {
        return nil;
    }
    [self isValidRuntime:object.runtime error:error];
    if (*error) {
        return nil;
    }
    BZObjectStoreFetchConditionModel *condition = nil;
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

- (NSNumber*)count:(Class)clazz condition:(BZObjectStoreFetchConditionModel*)condition  db:(FMDatabase*)db error:(NSError**)error
{
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:clazz db:db];
    [self isValidRuntime:runtime error:error];
    if (*error) {
        return nil;
    }
    NSNumber *count = [self count:runtime condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    return count;
}

- (NSNumber*)referencedCount:(NSObject*)object db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateRuntime:object db:db]) {
        return NO;
    }
    [self isValidRuntime:object.runtime error:error];
    if (*error) {
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
    if (![self updateRuntime:object db:db]) {
        return NO;
    }
    return [self refreshObjectSub:object db:db error:error];
}

- (NSObject*)refreshObjectSub:(NSObject*)object db:(FMDatabase*)db error:(NSError**)error
{
    BZObjectStoreFetchConditionModel *condition = nil;
    if (object.rowid) {
        condition = [object.runtime rowidCondition:object];
    } else if (object.runtime.hasIdentificationAttributes) {
        condition = [object.runtime uniqueCondition:object];
    } else {
        // toerror
        return nil;
    }
    NSMutableArray *list = [NSMutableArray array];
    FMResultSet *rs = [self resultSet:object.runtime condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    while ([rs next]) {
        NSObject *targetObject = [object.runtime object];
        targetObject.runtime = object.runtime;
        for (BZObjectStoreRuntimeProperty *attribute in targetObject.runtime.notRelationshipAttributes) {
            NSObject *value = [attribute valueWithResultSet:rs];
            [targetObject setValue:value forKey:attribute.name];
        }
        [list addObject:targetObject];
    }
    list = [self fetchObjectsSub:list refreshing:YES db:db error:error];
    return list.firstObject;
}

- (NSMutableArray*)fetchObjects:(Class)clazz condition:(BZObjectStoreFetchConditionModel*)condition db:(FMDatabase*)db error:(NSError**)error
{
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:clazz db:db];
    [self isValidRuntime:runtime error:error];
    if ( *error ) {
        return NO;
    }
    
    NSMutableArray *list = [NSMutableArray array];
    FMResultSet *rs = [self resultSet:runtime condition:condition db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    while ([rs next]) {
        NSObject *object = [runtime object];
        object.runtime = runtime;
        for (BZObjectStoreRuntimeProperty *attribute in runtime.notRelationshipAttributes) {
            NSObject *value = [attribute valueWithResultSet:rs];
            [object setValue:value forKey:attribute.name];
        }
        [list addObject:object];
    }
    return [self fetchObjectsSub:list refreshing:NO db:db error:error];
}

- (NSMutableArray*)fetchReferencingObjectsWithToObject:(NSObject*)object db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateRuntime:object db:db]) {
        return NO;
    }
    [self isValidRuntime:object.runtime error:error];
    if (*error) {
        return nil;
    }
    [self updateRowid:object db:db];
    if ([db hadError]) {
        return nil;
    }
    if (!object.rowid) {
        return nil;
    }
    NSMutableArray *relationshipObjects = [self relationshipObjectsWithToObject:object db:db];
    if ([self hadError:db error:error]) {
        return nil;
    }
    NSMutableArray *list = [NSMutableArray array];
    for (BZObjectStoreRelationshipModel *relationshipObject in relationshipObjects) {
        Class targetClazz = NSClassFromString(relationshipObject.fromClassName);
        if (targetClazz) {
            BZObjectStoreRuntime *runtime = [self runtimeWithClazz:targetClazz db:db];
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
    NSMutableArray *objectStuck = [NSMutableArray array];
    for (NSObject *object in objects) {
        if (![processedObjects valueForKey:object.objectStoreHashForSave]) {
            [processedObjects setValue:object forKey:object.objectStoreHashForSave];
            if (object.runtime.hasRelationshipAttributes) {
                [objectStuck addObject:object];
            }
        }
    }
    while (objectStuck.count > 0) {
        
        // each object
        NSObject *targetObject = [objectStuck lastObject];
        // each object-attribute
        for (BZObjectStoreRuntimeProperty *attribute in targetObject.runtime.relationshipAttributes) {
            BOOL ignoreFetch = NO;
            if (attribute.fetchOnRefreshingAttribute) {
                if (!(refreshing && [objects containsObject:targetObject])) {
                    ignoreFetch = YES;
                }
            }
            if (!ignoreFetch) {
                BZObjectStoreObjectAttributeModel *objectAttibute = [[BZObjectStoreObjectAttributeModel alloc]init];
                objectAttibute.object = targetObject;
                objectAttibute.attribute = attribute;
                objectAttibute.relationshipObjects = [self relationshipObjectsWithObject:targetObject attribute:attribute db:db];
                for (BZObjectStoreRelationshipModel *relationshipObject in objectAttibute.relationshipObjects) {
                    Class attributeClazz = NSClassFromString(relationshipObject.toClassName);
                    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:attributeClazz db:db];
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
                                [objectStuck addObject:object];
                            }
                            [processedObjects setValue:object forKey:object.objectStoreHashForFetch];
                        }
                        
                    } else if (runtime.isArrayClazz) {
                        NSMutableArray *objects = [NSMutableArray array];
                        NSMutableArray *keys = [NSMutableArray array];
                        for (BZObjectStoreRelationshipModel *child in objectAttibute.relationshipObjects) {
                            if ([child.attributeParentLevel isEqualToNumber:relationshipObject.attributeLevel]) {
                                if ([child.attributeParentSequence isEqualToNumber:relationshipObject.attributeSequence]) {
                                    if (child.attributeKey) {
                                        [keys addObject:child.attributeKey];
                                    } else {
                                        [keys addObject:[NSNull null]];
                                    }
                                    if (child.attributeValue) {
                                        [objects addObject:child.attributeValue];
                                    } else {
                                        [objects addObject:[NSNull null]];
                                    }
                                }
                            }
                        }
                        NSObject *value = [runtime objectWithObjects:objects keys:keys initializingOptions:relationshipObject.attributeKey];
                        relationshipObject.attributeFromObject = targetObject;
                        relationshipObject.attributeValue = value;
                    }
                    if (runtime) {
                        if (relationshipObject == objectAttibute.relationshipObjects.lastObject) {
                            [targetObject setValue:relationshipObject.attributeValue forKey:attribute.name];
                        }
                    }
                }
            }
        }
        [objectStuck removeObject:targetObject];
    }

    
    // fetch objects
    NSArray *targetObjects = processedObjects.allValues;
    for (NSObject *targetObject in targetObjects) {
        FMResultSet *rs = [self resultSet:targetObject db:db];
        if ([self hadError:db error:error]) {
            return nil;
        }
        while ([rs next]) {
            for (BZObjectStoreRuntimeProperty *attribute in targetObject.runtime.notRelationshipAttributes) {
                NSObject *value = [attribute valueWithResultSet:rs];
                [targetObject setValue:value forKey:attribute.name];
            }
        }
        [rs close];
    }
    
    return [NSMutableArray arrayWithArray:objects];
}


#pragma mark save methods

- (BOOL)saveObjects:(NSArray*)objects db:(FMDatabase*)db error:(NSError**)error
{
    if (![self updateRuntimes:objects db:db]) {
        return NO;
    }
    if (![self isValidObjects:objects error:error]) {
        return NO;
    }
    return [self saveObjectsSub:objects db:db error:error];
}

- (BOOL)saveObjectsSub:(NSArray*)objects db:(FMDatabase*)db error:(NSError**)error
{
    NSMutableArray *attributeObjects = [NSMutableArray array];
    NSMutableDictionary *processedObjects = [NSMutableDictionary dictionary];
    NSMutableArray *objectStuck = [NSMutableArray array];
    for (NSObject *object in objects) {
        if (object.runtime.hasRelationshipAttributes) {
            [objectStuck addObjectsFromArray:objects];
        } else {
            if (![processedObjects valueForKey:object.objectStoreHashForSave]) {
                [processedObjects setValue:object forKey:object.objectStoreHashForSave];
            }
        }
    }
    while (objectStuck.count > 0) {
        NSObject *targetObject = [objectStuck lastObject];
        if (![processedObjects valueForKey:targetObject.objectStoreHashForSave]) {
            [processedObjects setValue:targetObject forKey:targetObject.objectStoreHashForSave];
            for (BZObjectStoreRuntimeProperty *attribute in targetObject.runtime.relationshipAttributes) {
                NSObject *firstStuckAttributeObject = [targetObject valueForKey:attribute.name];
                if (firstStuckAttributeObject) {
                    BZObjectStoreObjectAttributeModel *objectAttribute = [[BZObjectStoreObjectAttributeModel alloc]init];
                    objectAttribute.object = targetObject;
                    objectAttribute.attribute = attribute;
                    
                    NSMutableArray *objectAttributeStuck = [NSMutableArray array];
                    NSMutableArray *allRelationshipObjects = [NSMutableArray array];
                    
                    if (attribute.clazz == NULL) {
                        attribute.clazz = [firstStuckAttributeObject class];
                        attribute.clazzName = NSStringFromClass(attribute.clazz);
                    }
                    
                    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:attribute.clazz db:db];
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
                        
                        BZObjectStoreObjectAttributeStuckObject *firstStuck = [[BZObjectStoreObjectAttributeStuckObject alloc]init];
                        firstStuck.parentRelationship = topRelationshipObject;
                        firstStuck.attributeObject = firstStuckAttributeObject;
                        [objectAttributeStuck addObject:firstStuck];
                        
                    } else if (runtime.isObjectClazz) {
                        BZObjectStoreObjectAttributeStuckObject *firstStuck = [[BZObjectStoreObjectAttributeStuckObject alloc]init];
                        firstStuck.parentRelationship = nil;
                        firstStuck.attributeObject = firstStuckAttributeObject;
                        [objectAttributeStuck addObject:firstStuck];
                        
                    }
                    
                    while (objectAttributeStuck.count > 0) {
                        BZObjectStoreObjectAttributeStuckObject *stuck = [objectAttributeStuck lastObject];
                        [objectAttributeStuck removeLastObject];
                        
                        NSMutableArray *relationshipObjects = [NSMutableArray array];
                        NSEnumerator *enumerator = nil;
                        NSArray *keys = nil;
                        NSInteger attributeSequence = 1;
                        NSNumber *attributeLevel = [NSNumber numberWithInteger:[stuck.parentRelationship.attributeLevel integerValue] + 1];
                        NSNumber *attributeParentLevel = stuck.parentRelationship.attributeLevel;
                        NSNumber *attributeParentSequence = stuck.parentRelationship.attributeSequence;
                        if (!attributeParentLevel) {
                            attributeParentLevel = @0;
                        }
                        if (!attributeParentSequence) {
                            attributeParentSequence = @0;
                        }
                        
                        [self updateRuntime:stuck.attributeObject db:db];
                        if ([self hadError:db error:error]) {
                            return NO;
                        }
                        if (stuck.attributeObject.runtime.isRelationshipClazz) {
                            enumerator = [stuck.attributeObject.runtime objectEnumeratorWithObject:stuck.attributeObject];
                            keys = [stuck.attributeObject.runtime keysWithObject:stuck.attributeObject];
                        }
                        
                        for (NSObject *attributeObjectInEnumerator in enumerator) {
                            Class attributeClazzInEnumerator = [attributeObjectInEnumerator class];
                            BZObjectStoreRuntime *attributeRuntimeInEnumerator = [self runtimeWithClazz:attributeClazzInEnumerator db:db];
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
                                BZObjectStoreObjectAttributeStuckObject *newStuck = [[BZObjectStoreObjectAttributeStuckObject alloc]init];
                                newStuck.parentRelationship = relationshipObject;
                                newStuck.attributeObject = relationshipObject.attributeToObject;
                                [objectAttributeStuck addObject:newStuck];
                                
                            } else if (relationshipObject.attributeToObject.runtime.isObjectClazz) {
                                [objectStuck addObject:relationshipObject.attributeToObject];
                            }
                        }
                    }
                    objectAttribute.relationshipObjects = allRelationshipObjects;
                    [attributeObjects addObject:objectAttribute];
                }
            }
            [objectStuck removeObject:targetObject];
        } else {
            [objectStuck removeObject:targetObject];
        }
    }
    
    // save objects
    NSArray *allValues = processedObjects.allValues;
    for (NSObject *targetObject in allValues) {
        [self insertOrReplace:targetObject db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
    }
    
    // save relationship
    BZObjectStoreRuntime *relationshipObjectRuntime = [self runtimeWithClazz:[BZObjectStoreRelationshipModel class] db:db];
    for (BZObjectStoreObjectAttributeModel *objectAttribute in attributeObjects) {
        for (BZObjectStoreRelationshipModel *relationshipObject in objectAttribute.relationshipObjects) {
            relationshipObject.runtime = relationshipObjectRuntime;
            relationshipObject.fromRowid = relationshipObject.attributeFromObject.rowid;
            if (relationshipObject.attributeToObject) {
                if (relationshipObject.toTableName) {
                    relationshipObject.toRowid = relationshipObject.attributeToObject.rowid;
                }
            }
        }
    }
    for (BZObjectStoreObjectAttributeModel *objectAttribute in attributeObjects) {
        for (BZObjectStoreRelationshipModel *relationshipObject in objectAttribute.relationshipObjects) {
            [self deleteRelationshipObjectsWithRelationshipObject:relationshipObject db:db];
            if ([self hadError:db error:error]) {
                return NO;
            }
        }
        NSMutableArray *relationshipObjects = [self relationshipObjectsWithObject:objectAttribute.object attribute:objectAttribute.attribute db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
        if (!objectAttribute.attribute.weakReferenceAttribute) {
            for (BZObjectStoreRelationshipModel *relationshipObject in relationshipObjects) {
                if (relationshipObject.toTableName) {
                    Class targetClazz = NSClassFromString(relationshipObject.toClassName);
                    BZObjectStoreRuntime *targetRuntime = [self runtimeWithClazz:targetClazz db:db];
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
        [self deleteRelationshipObjectsWithObject:objectAttribute.object attribute:objectAttribute.attribute db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
        [self insertRelationshipObjectsWithRelationshipObjects:objectAttribute.relationshipObjects db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
    }
    
    return YES;
}



#pragma mark remove methods

- (BOOL)removeObjects:(Class)clazz condition:(BZObjectStoreFetchConditionModel*)condition db:(FMDatabase*)db error:(NSError**)error
{
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:clazz db:db];
    [self isValidRuntime:runtime error:error];
    if ( *error ) {
        return NO;
    }
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
    if (![self updateRuntimes:objects db:db]) {
        return NO;
    }
    if (![self isValidObjects:objects error:error]) {
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
    NSMutableArray *objectStuck = [NSMutableArray array];
    for (NSObject *object in objects) {
        if (object.runtime.hasRelationshipAttributes) {
            [objectStuck addObjectsFromArray:objects];
        } else {
            if (![processedObjects valueForKey:object.objectStoreHashForSave]) {
                [processedObjects setValue:object forKey:object.objectStoreHashForSave];
            }
        }
    }
    while (objectStuck.count > 0) {
        
        // each object
        NSObject *targetObject = [objectStuck lastObject];
        if (![processedObjects valueForKey:targetObject.objectStoreHashForSave]) {
            [processedObjects setValue:targetObject forKey:targetObject.objectStoreHashForSave];
            
            // each object-attribute
            for (BZObjectStoreRuntimeProperty *attribute in targetObject.runtime.relationshipAttributes) {
                NSObject *firstAttributeObject = [targetObject valueForKey:attribute.name];
                if (firstAttributeObject) {
                    NSMutableArray *objectAttributeStuck = [NSMutableArray array];
                    [objectAttributeStuck addObject:firstAttributeObject];
                    
                    while (objectAttributeStuck.count > 0) {
                        NSObject *attributeObject = [objectAttributeStuck lastObject];
                        [objectAttributeStuck removeLastObject];
                        [self updateRuntime:attributeObject db:db];
                        if ([self hadError:db error:error]) {
                            return NO;
                        }
                        if (attributeObject.runtime.isRelationshipClazz) {
                            NSEnumerator *enumerator = [attributeObject.runtime objectEnumeratorWithObject:attributeObject];
                            for (NSObject *attributeObjectInEnumerator in enumerator) {
                                BZObjectStoreRuntime *runtime = [self runtimeWithClazz:[attributeObjectInEnumerator class] db:db];
                                if (runtime.isObjectClazz) {
                                    attributeObjectInEnumerator.runtime = runtime;
                                    [objectStuck addObject:attributeObjectInEnumerator];
                                } else if (runtime.isArrayClazz) {
                                    [objectAttributeStuck addObject:attributeObjectInEnumerator];
                                }
                            }
                        }
                    }
                }
            }
            [objectStuck removeObject:targetObject];
        } else {
            [objectStuck removeObject:targetObject];
        }
    }
    
    // remove objects
    NSArray *allValues = processedObjects.allValues;
    for (NSObject *targetObject in allValues) {
        [self deleteFrom:targetObject db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
        [self deleteRelationshipObjectsWithObject:targetObject db:db];
        if ([self hadError:db error:error]) {
            return NO;
        }
    }
    
    return YES;
}







#pragma mark common

- (BOOL)updateRuntimes:(NSArray*)objects db:(FMDatabase*)db
{
    for (NSObject *object in objects) {
        if (![self updateRuntime:object db:db]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)updateRuntime:(NSObject*)object db:(FMDatabase*)db
{
    if (object.runtime) {
        return YES;
    }
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:[object class] db:db];
    if (!runtime) {
        return NO;
    }
    object.runtime = runtime;
    return YES;
}


- (BZObjectStoreRuntime*)runtimeWithClazz:(Class)clazz db:(FMDatabase*)db
{
    BZObjectStoreRuntime *runtime = [super runtime:clazz];
    if (!runtime) {
        return nil;
    }
    if (runtime.isObjectClazz) {
        [super registerRuntime:runtime db:db];
        if ([self hadError:db error:nil]) {
            return nil;
        }
    }
    return runtime;
}

- (BOOL)isValidObjects:(NSArray*)objects error:(NSError**)error
{
    for (NSObject *object in objects) {
        if (![self isValidRuntime:object.runtime error:error]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isValidRuntime:(BZObjectStoreRuntime*)runtime error:(NSError**)error
{
    if (!runtime.isObjectClazz) {
        if (error != NULL) {
            NSString *message = [NSString stringWithFormat:@"%@",[runtime.clazz description]];
            *error = [BZObjectStoreError errorInvalidObject:message];
        }
        return NO;
    }
    return YES;
}

- (BZObjectStoreRuntimeProperty*)groupFunctionAttributeWithColumnName:(NSString*)columnName clazz:(Class)clazz db:(FMDatabase*)db error:(NSError**)error
{
    BZObjectStoreRuntime *runtime = [self runtimeWithClazz:clazz db:db];
    BZObjectStoreRuntimeProperty *attribute = [runtime attributeWithColumnName:columnName];
    if (attribute.isGroupFunctionClazz) {
        return attribute;
    } else {
        NSString *message = [NSString stringWithFormat:@"%@ %@",columnName,NSStringFromClass(runtime.clazz)];
        *error = [BZObjectStoreError errorInvalidColumnName:message];
        return nil;
    }
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

@end


