BZObjectStore
=============
[![Build Status](https://travis-ci.org/expensivegasprices/BZObjectStore.svg)](https://travis-ci.org/expensivegasprices/BZObjectStore)

This is an ORM library wrapped FMDB.

## Summary
- Mapping Models to SQLite tables
- Relationships with NSObject, NSArray, NSDictionary, NSSet, NSOrderedSet
- Automatic Schema Creating
- Thread Safe
- Useful functions

## Installation
BZObjectStore can be installed using [CocoaPods](http://cocoapods.org/).
```
pod 'BZObjectStore'
```

## Example Usage
``` objective-c
#import "BZObjectStore.h"

@interface SampleModel : NSObject
@property (nonatomic,strong) NSString name;
@property (nonatomic,assign) NSInteger price;
@end
@implementation SampleModel
@end

- (void)simpleTest
{
    NSError *error = nil;

    SampleModel *sample1 = [[SampleModel alloc]init];
    sample1.name = @"sample1";
    sample1.price = 100;

    SampleModel *sample2 = [[SampleModel alloc]init];
    sample2.name = @"sample2";
    sample1.price = 50;
    
    // open database
    BZObjectStore *os = [BZObjectStore openWithPath:@"database.sqlite" error:&error];

    // save object
    [os saveObject:sample1 error:&error];
    
    // save objects in array
    [os saveObjects:@[sample1,sample2] error:&error];

    // fetch objects
    NSArray *samples = [os fetchObjects:[SampleModel class] condition:nil error:&error];

    // remove object
    [os removeObject:sample1 error:&error];
    
    // remove objects
    [os removeObjects:[SampleModel class] condition:nil error:&error];

    // fetch objects with condition
    BZObjectStoreConditionModel *fetchCondition = [BZObjectStoreConditionModel condition];
    fetchCondition.sqlite.where = @"name = 'sample1' and price > 50";
    fetchCondition.sqlite.orderBy = @"name desc";
    NSArray *samples = [os fetchObjects:[SampleModel class] condition:fetchCondition error:&error];

    // remove objects with condition
    BZObjectStoreConditionModel *removeCondition = [BZObjectStoreConditionModel condition];
    removeCondition.sqlite.where = @"name = 'sample1'";
    [os removeObjects:[SampleModel class] condition:removeCondition error:&error];
    
    // close database
    [os close];
}
```

## Architecture
There are six main classes and one main interface in BZObjectStore:

1. `BZObjectStore` - 
2. `BZObjectStoreBackground` - 
3. `BZObjectStoreConditionModel` - 
4. `BZObjectStoreSQLiteConditionModel` - 
5. `BZObjectStoreReferenceConditionModel` - 
6. `BZObjectStoreReferenceConditionModel` - 
7. `BZObjectStoreModelInterface` - 
