BZObjectStore
=============
[![Build Status](https://travis-ci.org/expensivegasprices/BZObjectStore.svg?branch=master)](https://travis-ci.org/expensivegasprices/BZObjectStore)

BZObjectStore automatically stores your models to SQLite tables and provides useful options to your application.

## Requirements
- iOS 5.0 or later
- OS X 10.8 or later
- ARC

## Features
- Easy to use
- Mapping Models to SQLite tables
- Relationship in NSObject, NSArray, NSDictionary, NSSet, NSOrderedSet support
- Automatic Schema Creating
- Thread Safety
- Lazy fetching,One time Update and other useful options
- Any super class not required in your model
- ActiveRecord support
- [Parse.com](https://parse.com/docs/ios/api/index.html "Parse.com") support

## Installation
BZObjectStore can be installed using [CocoaPods](http://cocoapods.org/).
```
pod 'BZObjectStore'
pod 'BZObjectStore/CoreLocation' // if needed
pod 'BZObjectStore/ActiveRecord' // if needed
pod 'BZObjectStore/Parse' // if needed
```

## Example
```objective-c
#import "BZObjectStore.h"

NSError *error = nil;

// open datbase
BZObjectStore *os = [BZObjectStore openWithPath:@"database.sqlite" error:&error];

// save a object
[os saveObject:YOUROBJECT error:&error];

// close database
[os close];
```
After processing, you can find 'database path=/XXXX/database.sqlite' in the console.  
Open this file with your SQLite tool and check tables.



## Methods
#### Consider you have models like this.
```objective-c
#import "BZObjectStore.h"

@interface SampleModel : NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) NSInteger price;
@property (nonatomic,strong) SampleModel *sample;
@end

@implementation SampleModel
@end

SampleModel *sample1 = [[SampleModel alloc]init];
sample1.name = @"sample1";
sample1.price = 100;

SampleModel *sample2 = [[SampleModel alloc]init];
sample2.name = @"sample2";
sample2.price = 50;
sample2.sample = sample1;
```
#### Open Database
```objective-c
#import "BZObjectStore.h"

NSError *error = nil;

// default path is NSLibraryDirectory
BZObjectStore *os = [BZObjectStore openWithPath:@"database.sqlite" error:&error];

// open in memory
BZObjectStore *os = [BZObjectStore openWithPath:nil error:&error];
```
#### Save Objects
```objective-c
// save a object
[os saveObject:sample1 error:&error];

// save objects in array
[os saveObjects:@[sample1,sample2] error:&error];
```
#### Fetch Objects
```objective-c
// fetch objects
NSArray *fetchObjects = [os fetchObjects:[SampleModel class] condition:nil error:&error];

// fetch latest data from database
SampleModel *latest = [os refreshObject:sample1 error:&error];

// fetch referencing objects
NSArray *referencingObjects = [os fetchReferencingObjectsTo:sample1 error:&error];
```
#### Delete Objects
```objective-c
// delete a object
[os deleteObject:sample1 error:&error];

// delete objects
[os deleteObjects:[SampleModel class] condition:nil error:&error];

// delete objects in array
[os deleteObject:@[sample1,sample2] error:&error];
```
#### Fetch Objects with condition
```objective-c
BZObjectStoreConditionModel *fetchCondition = [BZObjectStoreConditionModel condition];
fetchCondition.sqlite.where = @"name = 'sample1' and price > 50";
fetchCondition.sqlite.orderBy = @"name desc";

NSArray *objects = [os fetchObjects:[SampleModel class] condition:fetchCondition error:&error];
```
#### Delete Objects with condition
```objective-c
BZObjectStoreConditionModel *deleteCondition = [BZObjectStoreConditionModel condition];
deleteCondition.sqlite.where = @"name = 'sample1'";

[os deleteObjects:[SampleModel class] condition:deleteCondition error:&error];
```
#### Close Database
```objective-c
// close database
[os close];
```
#### Get count value
```objective-c
NSNumber *count = [os count:[SampleModel class] condition:nil error:&error];
```
#### Get maximum value
```objective-c
NSNumber *max = [os max:@"price" class:[SampleModel class] condition:nil error:&error];
```
#### Get minimum value
```objective-c
NSNumber *min = [os min:@"price" class:[SampleModel class] condition:nil error:&error];
```
#### Get sum values
```objective-c
NSNumber *sum = [os sum:@"price" class:[SampleModel class] condition:nil error:&error];
```
#### Get total values
```objective-c
NSNumber *total = [os total:@"price" class:[SampleModel class] condition:nil error:&error];
```
#### Get average value
```objective-c
NSNumber *avg = [os avg:@"price" class:[SampleModel class] condition:nil error:&error];
```
#### Transaction
```objective-c
[os inTransaction:^(BZObjectStore *os, BOOL *rollback) {

    NSError *error = nil;
    [os saveObject:sample1 error:&error];
    [os saveObject:sample2 error:&error];
    
    // rollback if needed
    *rollback = YES;
}];
```
#### Register Class
```objective-c
// Improve response time (Not required but recommended)
[os registerClass:[SampleModel class] error:&error];
```
#### UnRegister Class
```objective-c
[os unRegisterClass:[SampleModel class] error:&error];
```

## Condition Model
There are three classes:

1. `BZObjectStoreConditionModel` - This class contains the following classes. You create a instance and set it to each method when you need.
2. `BZObjectStoreSQLiteConditionModel` - SQLite condition.
3. `BZObjectStoreReferenceConditionModel` - Reference object condition.

#### BZObjectStoreConditionModel
```objective-c
// create insntance
BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];

// access to BZObjectStoreSQLiteConditionModel
condition.sqlite.XXXXX

// access to BZObjectStoreReferenceConditionModel
condition.reference.XXXXX
```

#### BZObjectStoreSQLiteConditionModel
```objective-c

// where condition
condition.sqlite.where = @"name = ?";

// where parameters
condition.sqlite.parameters = @[@"sample1"];

// order By
condition.sqlite.orderBy = @"code desc";

// limit
condition.sqlite.limit = @20;

// offset
condition.sqlite.offset = @20;
```

#### BZObjectStoreReferenceConditionModel
```objective-c

// set object referencing from
condition.reference.from = sample1;

// no object referencing from
condition.reference.from = [NSNull null];

// set object referenced to
condition.reference.to = sample1;

// no object referenced to
condition.reference.from = [NSNull null];

```

## Options
#### OSIdenticalAttribute
define identical attributes

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface OrderModel : NSObject
@property (nonatomic,strong) NSString<OSIdenticalAttribute> *no;
@property (nonatomic,assign) NSArray *items;
@end
```

#### OSIgnoreAttribute
ignore attributes

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface OrderModel : NSObject
@property (nonatomic,strong) NSString<OSIdenticalAttribute> *no;
@property (nonatomic,assign) NSArray *items;
@property (nonatomic,assign) NSIndexPath<OSIgnoreAttribute> *indexPath;
@end
```

#### OSWeakReferenceAttribute
do not delete relationship objects when delete a object.

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface OrderModel : NSObject
@property (nonatomic,strong) NSString<OSIdenticalAttribute> *no;
@property (nonatomic,strong) NSArray<OSWeakReferenceAttribute> *items;
@end

@interface ItemModel : NSObject
@property (nonatomic,strong) NSString<OSIdenticalAttribute> *code;
@property (nonatomic,assign) NSInteger price;
@end
```

#### OSFetchOnRefreshingAttribute
fetch relationship objects only when refreshObject method, does not fetch when fetchObjects method.

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface NodeModel : NSObject
@property (nonatomic,strong) NSArray<OSFetchOnRefreshingAttribute> *children;
@end
```

#### OSNotUpdateIfValueIsNullAttribute
do not update attributes when value is nil.

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface ProfileModel : NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) UIImage<OSNotUpdateIfValueIsNullAttribute> *image;
@end
```

#### OSOnceUpdateAttribute
update attributes only one time.

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface ProfileModel : NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSDate<OSOnceUpdateAttribute> *registAt;
@property (nonatomic,strong) NSDate *updateAt;
@end
```

#### OSIgnoreSuperClass
ignore super class attributes

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface OrderModel : NSObject
@property (nonatomic,strong) NSString *remarks;
@end

@interface DailyOrderModel : OrderModel<OSIgnoreSuperClass>
@property (nonatomic,strong) NSString *no;
@property (nonatomic,assign) NSArray *details;
@end
```

#### OSFullTextSearch3
use sqlite FTS3

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface Address : NSObject<OSFullTextSearch3>
@property (nonatomic,assign) NSString *address;
@end
```

#### OSFullTextSearch4
use sqlite FTS4

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface Address : NSObject<OSFullTextSearch4>
@property (nonatomic,assign) NSString *address;
@end
```

#### OSInsertPerformance
prior insert performance

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface LogModel : NSObject<OSInsertPerformance>
@property (nonatomic,assign) NSString *code;
@property (nonatomic,assign) NSString *description;
@end
```

#### OSUpdatePerformance
prior update performance

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface ProfileModel : NSObject<OSUpdatePerformance>
@property (nonatomic,assign) NSString *name;
@end
```
If primitve type, override attributeIsXXXX methods in your model instead of these options.  
These methods are defined in OSModelInterface protocol.

## OSModelInterface
This interface provides additional functions.  
Import BZObjectStoreModelInterface.h file, implement OSModelInterface protocol in your model  
and override methods you need.

#### Change TableName

```objective-c
+ (NSString*)OSTableName
{
    return @"table_name_you_want";
}
```

#### Change ColumnName
```objective-c
+ (NSString*)OSColumnName:(NSString*)attributeName
{
    if ([attributeName isEqualToString:@"column_name_you_want_to_change"]) {
        return @"column_name_you_want";
    }
    return attributeName;
}
```

#### Hook the event when model loaded.
```objective-c
- (void)OSModelDidLoad
{
    // your operation
}
```

#### Hook the event when model saved.
```objective-c
- (void)OSModelDidSave
{
    // your operation
}
```

#### Hook the event when model deleted.
```objective-c
- (void)OSModelDidDelete
{
    // your operation
}
```

#### Define OSIdenticalAttribute option
```objective-c
+ (BOOL)attributeIsOSIdenticalAttribute:(NSString*)attributeName
{
    if ([attributeName isEqualToString:@"foo"]) {
        return YES;
    }
    return NO;
}
```

#### Define OSIgnoreAttribue option
```objective-c
+ (BOOL)attributeIsOSIgnoreAttribute:(NSString*)attributeName
{
    if ([attributeName isEqualToString:@"foo"]) {
        return YES;
    }
    return NO;
}
```

#### Define OSWeakReferenceAttribute option
```objective-c
+ (BOOL)attributeIsOSWeakReferenceAttribute:(NSString*)attributeName
{
    if ([attributeName isEqualToString:@"foo"]) {
        return YES;
    }
    return NO;
}
```

#### Define OSNotUpdateIfValueIsNullAttribute option
```objective-c
+ (BOOL)attributeIsOSNotUpdateIfValueIsNullAttribute:(NSString*)attributeName
{
    if ([attributeName isEqualToString:@"foo"]) {
        return YES;
    }
    return NO;
}
```

#### Define OSSerializableAttribute option
```objective-c
+ (BOOL)attributeIsOSSerializableAttribute:(NSString*)attributeName
{
    if ([attributeName isEqualToString:@"foo"]) {
        return YES;
    }
    return NO;
}
```

#### Define OSOnceUpdateAttribute option
```objective-c
+ (BOOL)attributeIsOSOnceUpdateAttribute:(NSString*)attributeName
{
    if ([attributeName isEqualToString:@"foo"]) {
        return YES;
    }
    return NO;
}
```


## In Background
You can use background process methods.  
Import BZObjectStoreBackground.h and call each method name + 'InBackground' methods.

```objective-c
#import "BZObjectStore.h"

[os saveObjectInBackground:savedObject completionBlock:^(NSError *error) {
    if (!error) {
        // succeed
    } else {
        // failed
    }
}];

// refer BZObjectStoreBackground.h about other methods
```

## Data Types
|Objective-C and C Data Types|SQLite Data Types|Mapping Column Names|Remarks|
|:-----------|:-----------|:-----------|:-----------|
|char*|INTEGER|attributeName||
|short|INTEGER|attributeName||
|int|INTEGER|attributeName||
|long|INTEGER|attributeName||
|long long|INTEGER|attributeName||
|double|REAL|attributeName||
|float|REAL|attributeName||
|unsigned char*|INTEGER|attributeName||
|unsigned short|INTEGER|attributeName||
|unsigned int|INTEGER|attributeName||
|unsigned long|INTEGER|attributeName||
|NSInteger|INTEGER|attributeName||
|CGFloat|REAL|attributeName||
|CGPoint|REAL|attributeName + '_x',+ '_y'|separated to 2 columns|
|CGSize|REAL|attributeName + '_width',+ '_height'|separated to 2 columns|
|CGRect|REAL|attributeName + '_x', + '_y', + '_width', + '_height'|separated to 4 columns|
|NSRange|INTEGER|attributeName + '_length', + '_location'|separated to 2 columns|
|NSDate|REAL|attributeName|saved as Unix time|
|NSData|BLOB|attributeName||
|NSString|TEXT|attributeName||
|NSMutableString|TEXT|attributeName||
|NSNull|BLOB|attributeName|saved as null|
|NSNumber|INTEGER|attributeName|saved as primitive value|
|NSURL|TEXT|attributeName|saved as absolute URL string|
|NSValue|BLOB|attributeName|saved as serialized|
|UIColor|TEXT|attributeName|saved as RGBA string|
|UIImage|BLOB|attributeName|saved as GIF binary data|
|NSArray|INTEGER|attributeName||
|NSDictionary|INTEGER|attributeName||
|NSSet|INTEGER|attributeName||
|NSOrderedSet|INTEGER|attributeName||
|NSMutableArray|INTEGER|attributeName||
|NSMutableDictionary|INTEGER|attributeName||
|NSMutableSet|INTEGER|attributeName||
|NSMutableOrderedSet|INTEGER|attributeName||
|NSObject|INTEGER|attributeName||
|ID|NONE|attributeName,attributeName + '_attributeType'|separated to 2 columns|
|CLLocationCoordinate2D|REAL|attributeName + '_latitude',+ '_longitude'|separated to 2 columns|
|CLLocation|REAL|attributeName + '_altitude',+ '_latitude',+ '_longitude',+ '_course',+ '_horizontalAccuracy',+ '_speed',+ '_timestamp',+ '_verticalAccuracy'|separated to 8 columns|
Other C structures will be saved as NSValue.


## Relationship
Objects in NSObject, NSArray, NSDictionary, NSSet, NSOrderedSet will be mapped to SQLite table automaticaly.  


## ActiveRecord support
##### setup
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BZObjectStore *os = [BZObjectStore openWithPath:@"database.sqlite" error:&error];
    [BZActiveRecord setupWithObjectStore:os];
}
```

##### import NSObject-ActiveRecord.h in your model
```objective-c
#import "NSObject-ActiveRecord.h"

@interface SampleModel : NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) NSInteger price;
@property (nonatomic,strong) SampleModel *sample;
@end
@implementation SampleModel
@end
```

##### example
```objective-c
- (void)foo
{
    NSError *error = nil;
    SampleModel *sample = [SampleModel alloc]init];
    [sample save:&error];
    NSArray *samples = [SampleModel fetchs:nil error:&error];
    [sample delete:&error];
}
```

##### If you use PFObject, import NSObject-ActiveRecordParse.h in your model.
```objective-c
- (void)foo
{
    NSError *error = nil;
    SampleModel *sample = [SampleModel alloc]init];
    [sample OSSave:&error];
    NSArray *samples = [SampleModel OSFetchs:nil error:&error];
    [sample OSDelete:&error];
}
```

## Parse support
BZObjectStore supports the following Parse objects.  
- PFObject implements PFSubclassing
- PFUser  
- PFFile  
- PFGeoPoint  

|Parse Data Types|SQLite Data Types|Mapping Column Names|Remarks|
|:-----------|:-----------|:-----------|:-----------|
|PFGeoPoint|REAL|attributeName + '_latitude',+ '_longitude'|separated to 2 columns|
|PFFile|TEXT,BLOB|attributeName + '_name',+ '_data'|separated to 2 columns|

## Others

#### Migration

```objective-c
// migrate database
[os migrate error:&error];
```

When models are added attributes only, migration will be run automatically. so do not run 'migrate' method.


#### FMDatabaseQueue and FMDatabase

##### In order to use FMDatabaseQueue, use dbQueue property.
```objective-c
#import "BZObjectStore.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"

- (void)foo
{
    BZObjectStore *os = [BZObjectStore openWithPath:@"database.sqlite" error:nil];
    FMDatabaseQueue *dbQueue = os.dbQueue;
    [dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db getTableSchema:@"SampleModel"];
        while (rs.next) {
            NSString *columnName = [rs stringForColumnIndex:1];
        }
        [rs close];
    }];
    [os close];
}
```

##### In order to use FMDatabase, inherit BZObjectStore class and override the following methods.
```objective-c
#import "FMDatabase.h"

- (void)transactionDidBegin:(FMDatabase *)db
{
    // called when call fetch,delete,save methods 
}

- (void)transactionDidEnd:(FMDatabase *)db
{
    // called when call fetch,delete,save methods 
}
```

### Restricted
- Readonly property always will be ignored.  
- Background process methods can not be used in inTransactionInBackground method.  


## MICS
Author: Takeshi Shimada  
History: https://github.com/expensivegasprices/BZObjectStore/History.md  
Inspired by [AFNetworking](https://github.com/AFNetworking/AFNetworking "AFNetworking"), [JSONModel](https://github.com/icanzilb/JSONModel "JSONModel") and [FMDB](https://github.com/ccgus/fmdb "FMDB").
