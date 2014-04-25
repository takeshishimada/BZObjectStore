BZObjectStore
=============
[![Build Status](https://travis-ci.org/expensivegasprices/BZObjectStore.svg)](https://travis-ci.org/expensivegasprices/BZObjectStore)

BZObjectStore is an ORM library wrapped FMDB.

BZObjectStore automatically store your model into SQLite and provide useful options to your application.

## Requirements
Targeting either iOS 5.0 and above

## Summary
- Mapping Models to SQLite tables
- Relationship in NSObject, NSArray, NSDictionary, NSSet, NSOrderedSet support
- Automatic Schema Creating
- Thread Safety
- Lazy fetching,One time Update and other useful options

## Installation
BZObjectStore can be installed using [CocoaPods](http://cocoapods.org/).
```
pod 'BZObjectStore'
```

## Basic Usage
#### Consider you have a model like this.
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
BZObjectStore *os = [BZObjectStore openWithPath:@"database.sqlite" error:&error];
```
#### Save Objects
```objective-c
// save object
[os saveObject:sample1 error:&error];

// save objects in array
[os saveObjects:@[sample1,sample2] error:&error];
```
#### Fetch Objects
```objective-c
// fetch objects
NSArray *objects = [os fetchObjects:[SampleModel class] condition:nil error:&error];
```

#### Remove Objects
```objective-c
// remove object
[os removeObject:sample1 error:&error];

// remove objects
[os removeObjects:[SampleModel class] condition:nil error:&error];
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
ignore attributes.

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface OrderModel : NSObject
@property (nonatomic,strong) NSString<OSIdenticalAttribute> *no;
@property (nonatomic,assign) NSArray *items;
@property (nonatomic,assign) NSIndexPath<OSIgnoreAttribute> indexPath;
@end
```

#### OSWeakReferenceAttribute
do not delete objects in attributes when remove a object.

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
fetch objects in attributes only when refreshObject method, does not fetch when fetchObjects method.

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
ignore super class attribute.

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface DailyOrderModel : OrderModel<OSIgnoreSuperClass>
@property (nonatomic,strong) NSString *no;
@property (nonatomic,assign) NSArray *details;
@end
```

#### OSFullTextSearch
use sqlite FTS3.

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface Address : NSObject<OSFullTextSearch>
@property (nonatomic,assign) NSString *address;
@end
```

#### OSPriorInsertPerformance
prior insert performance. 

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface LogModel : NSObject<OSPriorInsertPerformance>
@property (nonatomic,assign) NSString *code;
@property (nonatomic,assign) NSString *description;
@end
```

#### OSPriorUpdatePerformance
prior update performance. 

```objective-c
#import "BZObjectStoreModelInterface.h"

@interface ProfileModel : NSObject<OSPriorUpdatePerformance>
@property (nonatomic,assign) NSString *name;
@end
```

## In Background


## Condition


## Model Interface


