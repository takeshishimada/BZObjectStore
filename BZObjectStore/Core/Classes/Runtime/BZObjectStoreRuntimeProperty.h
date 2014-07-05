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

@class BZObjectStoreConditionModel;
@class BZObjectStoreRuntime;
@class BZObjectStoreNameBuilder;
@class BZObjectStoreClazz;
@class BZObjectStoreClazzUtil;
@class BZObjectStoreSQLiteColumnModel;
@class BZRuntimeProperty;
@class FMResultSet;

@interface BZObjectStoreRuntimeProperty : NSObject<OSModelInterface>

+ (instancetype)propertyWithBZProperty:(BZRuntimeProperty*)bzproperty runtime:(BZObjectStoreRuntime*)runtime nameBuilder:(BZObjectStoreNameBuilder*)nameBuilder;

// sqlite information
@property (nonatomic,strong) NSString *tableName;
@property (nonatomic,strong) NSString *columnName;
@property (nonatomic,strong) NSArray<OSSerializableAttribute> *sqliteColumns;

// name informations
@property (nonatomic,strong) NSString *clazzName;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *attributeType;

// class type information
@property (nonatomic,assign) Class clazz;
@property (nonatomic,assign) BOOL isSimpleValueClazz;
@property (nonatomic,assign) BOOL isArrayClazz;
@property (nonatomic,assign) BOOL isObjectClazz;
@property (nonatomic,assign) BOOL isPrimaryClazz;
@property (nonatomic,assign) BOOL isValid;

// attribute informations
@property (nonatomic,assign) BOOL identicalAttribute;
@property (nonatomic,assign) BOOL ignoreAttribute;
@property (nonatomic,assign) BOOL weakReferenceAttribute;
@property (nonatomic,assign) BOOL notUpdateIfValueIsNullAttribute;
@property (nonatomic,assign) BOOL serializableAttribute;
@property (nonatomic,assign) BOOL fetchOnRefreshingAttribute;
@property (nonatomic,assign) BOOL onceUpdateAttribute;

// data type information
@property (nonatomic,assign) BOOL isRelationshipClazz;

//
@property (nonatomic,strong) BZObjectStoreClazz<OSSerializableAttribute> *osclazz;

// mapper methods
- (NSArray*)storeValuesWithObject:(NSObject*)object;
- (id)valueWithResultSet:(FMResultSet*)resultSet;

// statement methods
- (NSString*)alterTableAddColumnStatement:(BZObjectStoreSQLiteColumnModel*)sqliteColumn;

@end
