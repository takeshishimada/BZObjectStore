BZObjectStore
=============
[![Build Status](https://travis-ci.org/expensivegasprices/BZObjectStore.svg)](https://travis-ci.org/expensivegasprices/BZObjectStore)

This is an ORM library wrapped FMDB.

BZObjectStore automatically stores your models to SQLite tables and provides useful options to your application.

## Requirements
Targeting either iOS 5.0 and above

## Summary
- Easy to use
- Mapping Models to SQLite tables
- Relationship in NSObject, NSArray, NSDictionary, NSSet, NSOrderedSet support
- Automatic Schema Creating
- Thread Safety
- Lazy fetching,One time Update and other useful options
- Not require any super class in your model

## Installation
BZObjectStore can be installed using [CocoaPods](http://cocoapods.org/).
```
pod 'BZObjectStore'
```

## Example
```objective-c
#import "BZObjectStore.h"

NSError *error = nil;

// open datbase
BZObjectStore *os = [BZObjectStore openWithPath:@"database.sqlite" error:&error];

// save object
[os saveObject:YOUROBJECT error:&error];

// close database
[os close];
```
After processed, you can find 'database path=XXXX' in console.  
Open this file with your SQLite tool and check tables.



## Usage
#### Consider you have models like this.
```objective-c
#import "BZObjectStore.h"

@interface SampleModel : NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) NSInteger price;
@end

@implementation SampleModel
@end

SampleModel *sample1 = [[SampleModel alloc]init];
sample1.name = @"sample1";
sample1.price = 100;

SampleModel *sample2 = [[SampleModel alloc]init];
sample2.name = @"sample2";
sample2.price = 50;
```
#### Open Database
```objective-c
#import "BZObjectStore.h"

NSError *error = nil;

// default path is NSApplicationSupportDirectory/bundleIdentifier
BZObjectStore *os = [BZObjectStore openWithPath:@"database.sqlite" error:&error];

// open In memory
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
NSArray *objects = [os fetchObjects:[SampleModel class] condition:nil error:&error];

// fetch latest data from database
SampleModel *latest = [os refreshObject:sample1 error:&error];

// fetch referencing objects
NSArray *objects = [os fetchReferencingObjectsTo:sample1 condition:nil error:&error];
```

#### Remove Objects
```objective-c
// remove a object
[os removeObject:sample1 error:&error];

// remove objects
[os removeObjects:[SampleModel class] condition:nil error:&error];

// remove objects in array
[os removeObject:@[sample1,sample2] error:&error];

```

#### Fetch Objects with condition
```objective-c
BZObjectStoreConditionModel *fetchCondition = [BZObjectStoreConditionModel condition];
fetchCondition.sqlite.where = @"name = 'sample1' and price > 50";
fetchCondition.sqlite.orderBy = @"name desc";

NSArray *objects = [os fetchObjects:[SampleModel class] condition:fetchCondition error:&error];
```

#### Remove Objects with condition
```objective-c
BZObjectStoreConditionModel *removeCondition = [BZObjectStoreConditionModel condition];
removeCondition.sqlite.where = @"name = 'sample1'";

[os removeObjects:[SampleModel class] condition:removeCondition error:&error];
```

#### Close Database
```objective-c
// close database
[os close];
```

#### Get count value
```objective-c
[os count:[SampleModel class] condition:nil error:&error];
```

#### Get maximum value
```objective-c
NSNumber *value = [os max:@"price" class:[SampleModel class] condition:nil error:&error];
```

#### Get minimum value
```objective-c
NSNumber *value = [os min:@"price" class:[SampleModel class] condition:nil error:&error];
```

#### Get sum values
```objective-c
NSNumber *value = [os sum:@"price" class:[SampleModel class] condition:nil error:&error];
```

#### Get total values
```objective-c
NSNumber *value = [os total:@"price" class:[SampleModel class] condition:nil error:&error];
```

#### Get average value
```objective-c
NSNumber *value = [os avg:@"price" class:[SampleModel class] condition:nil error:&error];
```

#### Transaction
```objective-c
[os inTransaction:^(BZObjectStore *os, BOOL *rollback) {

    NSError *error = nil;
    [os saveObject:sample1 error:&error];
    [os saveObject:sample2 error:&error];
    
    // rollback if need
    *rollback = YES;
}];
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
@property (nonatomic,assign) NSIndexPath<OSIgnoreAttribute> indexPath;
@end
```

#### OSWeakReferenceAttribute
do not delete relationship objects when remove a object.

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
@property (nonatomic,string) UIImage<OSNotUpdateIfValueIsNullAttribute> *image;
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
*image;
@end
```

#### OSIgnoreSuperClass
ignore super class attributes

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface DailyOrderModel : OrderModel<OSIgnoreSuperClass>
@property (nonatomic,strong) NSString *no;
@property (nonatomic,assign) NSArray *details;
@end
```

#### OSFullTextSearch
use sqlite FTS3

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface Address : NSObject<OSFullTextSearch>
@property (nonatomic,assign) NSString *address;
@end
```

#### OSPriorInsertPerformance
prior insert performance

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface LogModel : NSObject<OSPriorInsertPerformance>
@property (nonatomic,assign) NSString *code;
@property (nonatomic,assign) NSString *description;
@end
```

#### OSPriorUpdatePerformance
prior update performance

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface ProfileModel : NSObject<OSPriorUpdatePerformance>
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
	if ([attributeName isEqualString:@"column_name_you_want_to_change"]) {
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

#### Hook the event when model removed.
```objective-c
- (void)OSModelDidRemove
{
	// your operation
}
```

#### Define OSIdenticalAttribute option
```objective-c
+ (BOOL)attributeIsOSIdenticalAttribute:(NSString*)attributeName
{
	if ([attributeName isEqualString:@"foo"]) {
		return YES;
	}
	return NO;
}
```

#### Define OSIgnoreAttribue option
```objective-c
+ (BOOL)attributeIsOSIgnoreAttribute:(NSString*)attributeName
{
	if ([attributeName isEqualString:@"foo"]) {
		return YES;
	}
	return NO;
}
```

#### Define OSWeakReferenceAttribute option
```objective-c
+ (BOOL)attributeIsOSWeakReferenceAttribute:(NSString*)attributeName
{
	if ([attributeName isEqualString:@"foo"]) {
		return YES;
	}
	return NO;
}
```

#### Define OSNotUpdateIfValueIsNullAttribute option
```objective-c
+ (BOOL)attributeIsOSNotUpdateIfValueIsNullAttribute:(NSString*)attributeName
{
	if ([attributeName isEqualString:@"foo"]) {
		return YES;
	}
	return NO;
}
```

#### Define OSSerializableAttribute option
```objective-c
+ (BOOL)attributeIsOSSerializableAttribute:(NSString*)attributeName
{
	if ([attributeName isEqualString:@"foo"]) {
		return YES;
	}
	return NO;
}
```

#### Define OSOnceUpdateAttribute option
```objective-c
+ (BOOL)attributeIsOSOnceUpdateAttribute:(NSString*)attributeName
{
	if ([attributeName isEqualString:@"foo"]) {
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
```

## Data Types
|Objective-C Data Types|SQLite Data Types|Mapping Column Names|Remarks|
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
|unsigned long long|INTEGER|attributeName||
|CGPoint|REAL|attributeName + '_x',+ '_y'|separated to 2 columns|
|CGSize|REAL|attributeName + '_width',+ '_height'|separated to 2 columns|
|CGRect|REAL|attributeName + '_x', + '_y', + '_width', + '_height'|separated to 4 columns|
|NSRange|INTEGER|attributeName + '_length', + '_location'|separated to 2 columns|
|NSDate|INTEGER|attributeName|saved as Unix time|
|NSData|BLOB|attributeName||
|NSString|TEXT|attributeName||
|NSMutableString|TEXT|attributeName||
|NSNull|BLOB|attributeName||
|NSNumber|INTEGER|attributeName||
|NSURL|TEXT|attributeName|saved as absolute URL string|
|NSValue|BLOB|attributeName|saved as serialized|
|UIColor|TEXT|attributeName|saved as RGBA string|
|UIImage|BLOB|attributeName|saved as GIF binary data|
|NSArray|INTEGER|attributeName|saved number of Objects|
|NSDictionary|INTEGER|attributeName|saved number of Objects|
|NSSet|INTEGER|attributeName|saved number of Objects|
|NSOrderedSet|INTEGER|attributeName|saved number of Objects|
|NSMutableArray|INTEGER|attributeName|saved number of Objects|
|NSMutableDictionary|INTEGER|attributeName|saved number of Objects|
|NSMutableSet|INTEGER|attributeName|save numberd of Objects|
|NSMutableOrderedSet|INTEGER|attributeName|saved number of Objects|
|NSObject|INTEGER|attributeName|saved number of Objects|

Other C structures will be saved as NSValue.


## Features
- CLLocation, NSHashTable, NSMapTable support  
- Parse Objects support

