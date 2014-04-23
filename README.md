BZObjectStore
=============
[![Build Status](https://travis-ci.org/expensivegasprices/BZObjectStore.svg)](https://travis-ci.org/expensivegasprices/BZObjectStore)

This is an ORM library wrapped FMDB.

## CocoaPods

BZObjectStore can be installed using [CocoaPods](http://cocoapods.org/).

```
pod 'BZObjectStore'
```

## Example

```objective-c

#import "BZObjectStore.h"

- (void)example
{
    NSError *error = nil;
    BZObjectStore *os = [BZObjectStore openWithPath:@"database.sqlite" error:&error];

    // save object
    [os saveObject:YOUROBJECT error:&error];
    
    // save objects in array
    [os saveObjects:@[YOUROBJECT,YOUROBJECT error:&error];

    // fetch objects
    NSArray *yourobjects = [os fetchObjects:[YOURCLASS class] condition:nil error:&error];

    // remove object
    [os removeObject:yourobject error:&error];
    
    // remove objects by class
    [os removeObjects:[YOURCLASS class] condition:nil error:&error];
}


```



## Example NSArray property

```objective-c
#import "BZObjectStore.h"

@class Item;
@class OrderDetail;

@interface OrderHeader : NSObject
@property (nonatomic,assign) NSInteger orderNo;
@property (nonatomic,strong) NSArray *orderDetails;
@property (nonatomic,strong) NSDate *orderedAt;
@end
@implementation OrderHeader
@end

@interface OrderDetail : NSObject
@property (nonatomic,strong) Item *orderItem;
@property (nonatomic,assign) NSInteger amount;
@end
@implementation OrderDetail
@end

@interface Item : NSObject
@property (nonatomic,assign) NSInteger itemNo;
@property (nonatomic,strong) NSString *itemName;
@property (nonatomic,assign) CGFloat price;
@end
@implementation Item
@end

- (void)save
{
    Item *apple = [[Item alloc]init];
    apple.itemNo = 1;
    apple.itemName = @"apple";
    apple.price = 1.5f;
    
    Item *orange = [[Item alloc]init];
    orange.itemNo = 2;
    orange.itemName = @"orange";
    orange.price = 1.2f;

    OrderDetail *orderApple = [[OrderDetail alloc]init];
    orderApple.orderItem = apple;
    orderApple.amount = 10;

    OrderDetail *orderOrange = [[OrderDetail alloc]init];
    orderOrange.orderItem = orange;
    orderOrange.amount = 10;
    
    OrderHeader *header = [[OrderHeader alloc]init];
    header.orderNo = 1;
    header.orderDetails = @[orderApple,orderOrange];
    header.orderedAt = [NSDate date];
    
    NSError *error = nil;
    BZObjectStore *os = [BZObjectStore openWithPath:@"database.sqlite" error:&error];
    [os saveObject:header error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
}

```




## Usage
There are six main classes and one main interface in BZObjectStore:

1. `BZObjectStore` - 
2. `BZObjectStoreBackground` - 
3. `BZObjectStoreConditionModel` - 
4. `BZObjectStoreSQLiteConditionModel` - 
5. `BZObjectStoreReferenceConditionModel` - 
6. `BZObjectStoreReferenceConditionModel` - 
7. `BZObjectStoreModelInterface` - 
