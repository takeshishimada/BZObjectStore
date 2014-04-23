BZObjectStore
=============
[![Build Status](https://travis-ci.org/expensivegasprices/BZObjectStore.svg)](https://travis-ci.org/expensivegasprices/BZObjectStore)

This is an ORM library wrapped FMDB.

## Summary
- Mapping Models to SQLite tables
- Relationship with NSObject, NSArray, NSDictionary, NSSet, NSOrderedSet
- Automatic Schema Creating
- Strong and weak referencing
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
@end

@implementation SampleModel
@end

- (void)test
{
    NSError *error = nil;

    SampleModel *sample1 = [[SampleModel alloc]init];
    sample1.name = @"sample1";

    SampleModel *sample2 = [[SampleModel alloc]init];
    sample2.name = @"sample2";
    
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
