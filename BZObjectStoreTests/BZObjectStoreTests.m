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

#import <XCTest/XCTest.h>
#import <float.h>
#import <limits.h>
#import <Parse/Parse.h>
#import "ColorUtils.h"
#import <FMDatabase.h>
#import <FMDatabaseQueue.h>
#import <FMDatabaseAdditions.h>
#import "BZObjectStoreOnDisk.h"
#import "BZObjectStoreOnMemory.h"
#import "BZVarietyValuesModel.h"
#import "BZVarietyValuesItemModel.h"
#import "BZInvalidValuesModel.h"
#import "BZRelationshipHeaderModel.h"
#import "BZRelationshipDetailModel.h"
#import "BZRelationshipItemModel.h"
#import "BZInsertResponseModel.h"
#import "BZUpdateResponseModel.h"
#import "BZCircularReferenceModel.h"
#import "BZSQLiteGroupFunctionModel.h"
#import "BZUpdateExistsObjectWithNoRowIdModel.h"
#import "BZOnDemandHeaderModel.h"
#import "BZOnDemandDetailModel.h"
#import "BZOnDemanItemModel.h"
#import "BZExtendModel.h"
#import "BZIgnoreExtendModel.h"
#import "BZUpdateAttributeModel.h"
#import "BZIgnoreAttribute.h"
#import "BZDelegateModel.h"
#import "BZNameModel.h"
#import "BZAttributeIsModel.h"
#import "BZAttributeIsSerializeModel.h"
#import "BZAttributeIsWeakReferenceModel.h"
#import "BZAttributeIsfetchOnRefreshingModel.h"
#import "BZOrderByModel.h"
#import "BZWhereModel.h"
#import "BZOffSetLimitModel.h"
#import "BZFullTextModel.h"
#import "BZReferenceConditionModel.h"
#import "BZReferenceFromConditionModel.h"
#import "BZReferenceToConditionModel.h"
#import "BZOSIdenticalModel.h"
#import "BZOSIdenticalItemModel.h"
#import "BZWeakPropertyModel.h"
#import "BZAddColumnsModel.h"
#import "BZAddColumnsAddModel.h"
#import "BZAddColumnsAddItemModel.h"
#import "BZTypeMissMatchModel.h"
#import "BZTypeMissMatchMissMatchModel.h"
#import "BZTypeMissMatchItemModel.h"
#import "BZObjectStoreConditionModel.h"
#import "BZOSIdenticalAttributeOSSerializeAttributeModel.h"
#import "BZOSIdenticalFirstModel.h"
#import "BZOSIdenticalSecondModel.h"
#import "BZOSIdenticalThirdModel.h"
#import "BZOSIdenticalForthModel.h"
#import "BZDuplicateAttributeModel.h"
#import "BZObjectStoreReferenceModel.h"
#import "BZObjectStoreNameBuilder.h"
#import "BZObjectStoreClazzBZImage.h"
#import "BZImageHolderModel.h"
#import "BZArrayInArrayModel.h"
#import "TKRGuard.h"
#import "BZObjectStoreBackground.h"
#import "BZBackgroundModel.h"
#import "BZTransactionModel.h"
#import "BZParseModel.h"
#import "BZObjectStoreParse.h"
#import "BZActiveRecordModel.h"
#import "BZNotificationModel.h"

#import <Parse/Parse.h>

@interface BZObjectStoreTests : XCTestCase {
}
@end

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


@implementation BZObjectStoreTests

- (void)setUp
{
    [super setUp];
    
    [BZParseModel registerSubclass];
    
    [Parse setApplicationId:@"qNMDT4gO06FhoPafaFOr6iM17FL5MoX2Idd00Mhr"
                  clientKey:@"S3yt2lFSZNHOPE7Z0a6oa451tpecGJ5ysXfR92uO"];
    
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testMigration
//{
//    [BZObjectStoreClazz addClazz:[BZObjectStoreClazzBZImage class]];
//    BZObjectStore *_disk;
//    _disk = [BZObjectStoreOnDisk openWithPath:@"database.sqlite" error:nil];
//    [_disk migrate:nil];
//
//}

- (void)testOnDisk
{
    NSString *path = @"database.sqlite";
    if (path && ![path isEqualToString:@""]) {
        if ([path isEqualToString:[path lastPathComponent]]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *dir = [paths objectAtIndex:0];
            path = [dir stringByAppendingPathComponent:path];
        }
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager removeItemAtPath:path error:nil]) {
    }
    
    BZObjectStore *_disk;
    _disk = [BZObjectStoreOnDisk openWithPath:@"database.sqlite" error:nil];

    [self testNotification:_disk];
    [self testBZActiveRecordModel:_disk];
    [self testBZParseModel:_disk];
    [self testBZVarietyValuesModel:_disk];
    [self testBZInvalidValuesModel:_disk];
    [self testBZRelationshipHeaderModel:_disk];
    [self testBZInsertResponseModel:_disk];
    [self testBZUpdateResponseModel:_disk];
    [self testCircularReference:_disk];
    [self testSQLiteGroupCondition:_disk];
    [self testBZUpdateExistsObjectWithNoRowIdModel:_disk];
    [self testBZOnDemanItemModel:_disk];
    [self testBZExtendModel:_disk];
    [self testBZIgnoreExtendModel:_disk];
    [self testUpdateAttributeModel:_disk];
    [self testBZIgnoreAttribute:_disk];
    [self testBZDelegateModel:_disk];
    [self testBZNameModel:_disk];
    [self testAttributesModel:_disk];
    [self testBZOrderByModel:_disk];
    [self testBZWhereModel:_disk];
    [self testBZOffSetLimitModel:_disk];
    [self testBZFullTextModel:_disk];
    [self testBZReferenceConditionModel:_disk];
    [self testBZOSIdenticalModel:_disk];
    [self testBZWeakPropertyModel:_disk];
    [self testBZAddColumnsModel:_disk];
    [self testBZTypeMissMatchModel:_disk];
    [self testBZOSIdenticalAttributeOSSerializeAttributeModel:_disk];
    [self testBZOSIdenticalFirstModel:_disk];
    [self testBZDuplicateAttributeModel:_disk];
    [self testBZObjectStoreReferenceModel:_disk];
    [self testBZObjectStoreNameBuilder:_disk];
    [self testBZObjectStoreClazzBZImage:_disk];
    [self testBZArrayInArrayModel:_disk];
    [self testBackground:_disk];
    [self testInTransaction:_disk];
    [_disk close];
    _disk = nil;
}

- (void)testOnMemory
{
    BZObjectStore *_memory;
    _memory = [BZObjectStoreOnMemory openWithPath:nil error:nil];
    
    [self testNotification:_memory];
    [self testBZActiveRecordModel:_memory];
    [self testBZParseModel:_memory];
    [self testBZVarietyValuesModel:_memory];
    [self testBZInvalidValuesModel:_memory];
    [self testBZRelationshipHeaderModel:_memory];
    [self testBZInsertResponseModel:_memory];
    [self testBZUpdateResponseModel:_memory];
    [self testCircularReference:_memory];
    [self testSQLiteGroupCondition:_memory];
    [self testBZUpdateExistsObjectWithNoRowIdModel:_memory];
    [self testBZOnDemanItemModel:_memory];
    [self testBZExtendModel:_memory];
    [self testBZIgnoreExtendModel:_memory];
    [self testUpdateAttributeModel:_memory];
    [self testBZIgnoreAttribute:_memory];
    [self testBZDelegateModel:_memory];
    [self testBZNameModel:_memory];
    [self testAttributesModel:_memory];
    [self testBZOrderByModel:_memory];
    [self testBZWhereModel:_memory];
    [self testBZOffSetLimitModel:_memory];
    [self testBZFullTextModel:_memory];
    [self testBZReferenceConditionModel:_memory];
    [self testBZOSIdenticalModel:_memory];
    [self testBZWeakPropertyModel:_memory];
    [self testBZAddColumnsModel:_memory];
    [self testBZTypeMissMatchModel:_memory];
    [self testBZOSIdenticalAttributeOSSerializeAttributeModel:_memory];
    [self testBZOSIdenticalFirstModel:_memory];
    [self testBZDuplicateAttributeModel:_memory];
    [self testBZObjectStoreReferenceModel:_memory];
    [self testBZObjectStoreNameBuilder:_memory];
    [self testBZObjectStoreClazzBZImage:_memory];
    [self testBZArrayInArrayModel:_memory];
    [self testBackground:_memory];
    [self testInTransaction:_memory];
    [_memory close];
    _memory = nil;
}

- (void)testNotification:(BZObjectStore*)os
{
    BZNotificationModel *model = [[BZNotificationModel alloc]init];
    model.objectId = @"test";

    [BZObjectStoreNotificationCenter observerForObject:model target:self completionBlock:^(id target, BZNotificationModel *object) {
        
        if (object) {
            NSLog(@"saved!!");
        } else {
            NSLog(@"deleted!!");
        }
        
        
    } immediately:NO];
    
    
    [os saveObject:model error:nil];
    [os deleteObject:model error:nil];
    
}

- (void)testBZVarietyValuesModel:(BZObjectStore*)os
{
    // setup models
    BZVarietyValuesItemModel *item1 = [[BZVarietyValuesItemModel alloc]init];
    item1.code = @"01";
    item1.name = @"apple";
    
    BZVarietyValuesItemModel *item2 = [[BZVarietyValuesItemModel alloc]init];
    item2.code = @"02";
    item2.name = @"orange";
    
    BZVarietyValuesItemModel *item3 = [[BZVarietyValuesItemModel alloc]init];
    item3.code = @"03";
    item3.name = @"banana";
    
    BZVarietyValuesModel *savedObject = [[BZVarietyValuesModel alloc]init];
    
    foo vvalue = {2,"name",1.23456788f};
    
    // POD types
    savedObject.vcharstring = "test";
    savedObject.vbool_max = YES;
    savedObject.vdouble_max = DBL_MAX;
    savedObject.vfloat_max = FLT_MAX;
    savedObject.vchar_max = CHAR_MAX;
    savedObject.vint_max = INT_MAX;
    savedObject.vshort_max = SHRT_MAX;
    savedObject.vlong_max = LONG_MAX;
    savedObject.vlonglong_max = LLONG_MAX;
    savedObject.vunsignedchar_max = UCHAR_MAX;
    savedObject.vunsignedint_max = UINT_MAX;
    savedObject.vunsignedshort_max = USHRT_MAX;
    savedObject.vunsignedlong_max = ULONG_MAX;
    savedObject.vunsignedlonglong_max = ULLONG_MAX;
    savedObject.vbool_min = NO;
    savedObject.vdouble_min = DBL_MIN;
    savedObject.vfloat_min = FLT_MIN;
    savedObject.vchar_min = CHAR_MIN;
    savedObject.vint_min = INT_MIN;
    savedObject.vshort_min = SHRT_MIN;
    savedObject.vlong_min = LONG_MIN;
    savedObject.vlonglong_min = LLONG_MIN;
    savedObject.vunsignedchar_min = 0;
    savedObject.vunsignedint_min = 0;
    savedObject.vunsignedshort_min = 0;
    savedObject.vunsignedlong_min = 0;
    savedObject.vunsignedlonglong_min = 0;
    savedObject.vfoo = vvalue;
    
    // objective-c
    savedObject.vnsinteger = 99;
    savedObject.vstring = @"string";
    savedObject.vrange = NSMakeRange(1, 2);
    savedObject.vmutableString = [NSMutableString stringWithString:@"mutableString"];
    savedObject.vnumber = [NSNumber numberWithBool:YES];
    savedObject.vdecimalnumber = [NSDecimalNumber decimalNumberWithString:@"100.0123456789"];
    savedObject.vurl = [NSURL URLWithString:@"http://wwww.yahoo.com"];
    savedObject.vnull = [NSNull null];
    savedObject.vcolor = [UIColor redColor];
    savedObject.vimage = [UIImage imageNamed:@"AppleLogo.png"];
    savedObject.vdata = [NSData dataWithData:UIImagePNGRepresentation(savedObject.vimage)];
    savedObject.vid = item2;
    savedObject.vidSimple = @999;
    savedObject.vmodel = item3;
    savedObject.vvalue = [NSValue value:&vvalue withObjCType:@encode(foo)];
    
    // objective-c core graphics
    savedObject.vcgfloat = 44.342334f;
    savedObject.vrect = CGRectMake(4.123456f,1.123456f,2.123456f,3.123456f);
    savedObject.vpoint = CGPointMake(4.123456f, 5.123456f);
    savedObject.vsize = CGSizeMake(6.123456f, 7.123456f);
    
    // objective-c core location
    savedObject.vlocation = [[CLLocation alloc]initWithCoordinate:CLLocationCoordinate2DMake(1.1234567890123456789,1.1234567890123456789) altitude:1.1234567890123456789 horizontalAccuracy:1.1234567890123456789 verticalAccuracy:1.1234567890123456789 course:1.1234567890123456789 speed:1.1234567890123456789 timestamp:[NSDate date]];
    savedObject.vcoordinate2D = CLLocationCoordinate2DMake(1.1234567890123456789,1.1234567890123456789);
    
    // objective-c array,set,dictionary,orderedset
    savedObject.vArray = [NSArray arrayWithObjects:item1,item2,item3, nil];
    NSValue *pointSaved = [NSValue valueWithCGPoint:CGPointMake(1, 2)];
    NSValue *sizeSaved = [NSValue valueWithCGSize:CGSizeMake(3,4)];
    NSValue *rectSaved = [NSValue valueWithCGRect:CGRectMake(5, 6, 7, 8)];
    savedObject.vArrayWithCGRectCGPointCGSize = @[pointSaved,sizeSaved,rectSaved];
    savedObject.vSet = [NSSet setWithObjects:item1,item2,item3, nil];
    savedObject.vdictionary = [NSDictionary dictionaryWithObjectsAndKeys:item1,item1.name,item3,item3.name, nil];
    savedObject.vOrderedSet = [NSOrderedSet orderedSetWithObjects:item1,item3, nil];
    savedObject.vmutableArray = [NSMutableArray arrayWithObjects:item1,item2,item3, nil];
    savedObject.vmutableSet = [NSMutableSet setWithObjects:item1,item2,item3, nil];
    savedObject.vmutabledictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:item1,item1.name,item3,item3.name, nil];
    savedObject.vmutableOrderedSet = [NSMutableOrderedSet orderedSetWithObjects:item1,item3, nil];
    
    // save object
    NSError *error = nil;
    [os saveObject:savedObject error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    // fetch object
    NSArray *fetchedObjects = [os fetchObjects:[BZVarietyValuesModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(fetchedObjects.count == 1, @"fetch objects count is invalid");
    
    
    
    
    // variable simple value tests
    BZVarietyValuesModel *fetchedObject = fetchedObjects.firstObject;
    XCTAssertTrue(![fetchedObject isEqual:savedObject],"object error");
    
    
    // class type
    XCTAssertTrue([[savedObject.vstring class] isSubclassOfClass:[NSString class]], @"nsstring class");
    XCTAssertTrue([[savedObject.vmutableString class] isSubclassOfClass:[NSMutableString class]], @"vmutableString class");
    XCTAssertTrue([[savedObject.vvalue class] isSubclassOfClass:[NSValue class]], @"vvalue class");
    XCTAssertTrue([[savedObject.vnumber class] isSubclassOfClass:[NSNumber class]], @"vnumber class");
    XCTAssertTrue([[savedObject.vdecimalnumber class] isSubclassOfClass:[NSDecimalNumber class]], @"vnumber class");
    XCTAssertTrue([[savedObject.vurl class] isSubclassOfClass:[NSURL class]], @"vurl class");
    XCTAssertTrue([[savedObject.vnull class] isSubclassOfClass:[NSNull class]], @"vnull class");
    XCTAssertTrue([[savedObject.vcolor class] isSubclassOfClass:[UIColor class]], @"vcolor class");
    XCTAssertTrue([[savedObject.vimage class] isSubclassOfClass:[UIImage class]], @"vimage class");
    XCTAssertTrue([[savedObject.vdata class] isSubclassOfClass:[NSData class]], @"vdata class");
    XCTAssertTrue([[savedObject.vArray class] isSubclassOfClass:[NSArray class]], @"vArray class");
    XCTAssertTrue([[savedObject.vArrayWithCGRectCGPointCGSize class] isSubclassOfClass:[NSArray class]], @"vArray class");
    XCTAssertTrue([[savedObject.vSet class] isSubclassOfClass:[NSSet class]], @"vSet class");
    XCTAssertTrue([[savedObject.vdictionary class] isSubclassOfClass:[NSDictionary class]], @"vdictionary class");
    XCTAssertTrue([[savedObject.vOrderedSet class] isSubclassOfClass:[NSOrderedSet class]], @"vOrderedSet class");
    XCTAssertTrue([[savedObject.vmutableArray class] isSubclassOfClass:[NSArray class]], @"vmutableArray class");
    XCTAssertTrue([[savedObject.vmutableSet class] isSubclassOfClass:[NSSet class]], @"vmutableSet class");
    XCTAssertTrue([[savedObject.vmutabledictionary class] isSubclassOfClass:[NSDictionary class]], @"vmutabledictionary class");
    XCTAssertTrue([[savedObject.vmutableOrderedSet class] isSubclassOfClass:[NSOrderedSet class]], @"vmutableOrderedSet class");
    
    
    // POD types
    XCTAssertTrue(fetchedObject.vdouble_max == savedObject.vdouble_max,"vdouble_max error");
    XCTAssertTrue(fetchedObject.vbool_max == savedObject.vbool_max,"vdouble_max error");
    XCTAssertTrue(fetchedObject.vfloat_max == savedObject.vfloat_max,"vfloat_max error");
    XCTAssertTrue(fetchedObject.vchar_max == savedObject.vchar_max,"vchar_max error");
    XCTAssertTrue(fetchedObject.vint_max == savedObject.vint_max,"vint_max error");
    XCTAssertTrue(fetchedObject.vshort_max == savedObject.vshort_max,"vshort_max error");
    XCTAssertTrue(fetchedObject.vlong_max == savedObject.vlong_max,"vlong_max error");
    XCTAssertTrue(fetchedObject.vlonglong_max == savedObject.vlonglong_max,"vlonglong_max error");
    XCTAssertTrue(fetchedObject.vunsignedchar_max == savedObject.vunsignedchar_max,"vunsignedchar_max error");
    XCTAssertTrue(fetchedObject.vunsignedint_max == savedObject.vunsignedint_max,"vunsignedint_max error");
    XCTAssertTrue(fetchedObject.vunsignedshort_max == savedObject.vunsignedshort_max,"vunsignedshort_max error");
    XCTAssertTrue(fetchedObject.vunsignedlong_max == savedObject.vunsignedlong_max,"vunsignedlong_max error");
    XCTAssertTrue(fetchedObject.vunsignedlonglong_max == savedObject.vunsignedlonglong_max,"vunsignedlonglong_max error");
    XCTAssertTrue(fetchedObject.vdouble_min == savedObject.vdouble_min,"vdouble_min error");
    XCTAssertTrue(fetchedObject.vbool_min == savedObject.vbool_min,"vbool_min error");
    XCTAssertTrue(fetchedObject.vfloat_min == savedObject.vfloat_min,"vfloat_min error");
    XCTAssertTrue(fetchedObject.vchar_min == savedObject.vchar_min,"vchar_min error");
    XCTAssertTrue(fetchedObject.vint_min == savedObject.vint_min,"vint_min error");
    XCTAssertTrue(fetchedObject.vshort_min == savedObject.vshort_min,"vshort_min error");
    XCTAssertTrue(fetchedObject.vlong_min == savedObject.vlong_min,"vlong_min error");
    XCTAssertTrue(fetchedObject.vlonglong_min == savedObject.vlonglong_min,"vlonglong_min error");
    XCTAssertTrue(fetchedObject.vunsignedchar_min == savedObject.vunsignedchar_min,"vunsignedchar_min error");
    XCTAssertTrue(fetchedObject.vunsignedint_min == savedObject.vunsignedint_min,"vunsignedint_min error");
    XCTAssertTrue(fetchedObject.vunsignedshort_min == savedObject.vunsignedshort_min,"vunsignedshort_min error");
    XCTAssertTrue(fetchedObject.vunsignedlong_min == savedObject.vunsignedlong_min,"vunsignedlong_min error");
    XCTAssertTrue(fetchedObject.vunsignedlonglong_min == savedObject.vunsignedlonglong_min,"vunsignedlonglong_min error");
    XCTAssertTrue(fetchedObject.vfoo.no == 2, @"struct int error");
    XCTAssertTrue(strcmp(fetchedObject.vfoo.name, "name") == 0, @"struct int error");
    XCTAssertTrue(fetchedObject.vfoo.average == 1.23456788f, @"struct double error");
    
    // objective-c
    XCTAssertTrue(fetchedObject.vnsinteger == savedObject.vnsinteger,"vinteger error");
    XCTAssertTrue([fetchedObject.vstring isEqualToString:savedObject.vstring],"vstring error");
    XCTAssertTrue(fetchedObject.vrange.length == savedObject.vrange.length,"vrange error");
    XCTAssertTrue(fetchedObject.vrange.location == savedObject.vrange.location,"vrange error");
    XCTAssertTrue([fetchedObject.vmutableString isEqualToString:savedObject.vmutableString],"vmutableString error");
    XCTAssertTrue([fetchedObject.vnumber isEqualToNumber:savedObject.vnumber],"vnumber error");
    XCTAssertTrue([fetchedObject.vdecimalnumber isEqualToNumber:savedObject.vdecimalnumber],"vdecimalnumber error");
    XCTAssertTrue([fetchedObject.vcolor RGBAValue] == [[UIColor redColor] RGBAValue],@"vcolor error");
    XCTAssertTrue([[fetchedObject.vurl absoluteString] isEqualToString:[savedObject.vurl absoluteString]],@"vurl error");
    XCTAssertTrue(fetchedObject.vnull == [NSNull null],@"vmutableSet error");
    XCTAssertTrue([fetchedObject.vdata isEqualToData:[NSData dataWithData:UIImagePNGRepresentation(fetchedObject.vimage)]],@"vdata,vimage error");
    foo fetchedvvalue;
    [fetchedObject.vvalue getValue:&fetchedvvalue];
    XCTAssertTrue(fetchedvvalue.no == 2, @"struct int error");
    XCTAssertTrue(strcmp(fetchedvvalue.name, "name") == 0, @"struct int error");
    XCTAssertTrue(fetchedvvalue.average == 1.23456788f, @"struct double error");
    NSNumber *number = fetchedObject.vidSimple;
    XCTAssertTrue(number.integerValue == 999,@"vmutableSet error");
    
    BZVarietyValuesItemModel *vidfrom = (BZVarietyValuesItemModel*)fetchedObject.vid;
    BZVarietyValuesItemModel *vidto = (BZVarietyValuesItemModel*)savedObject.vid;
    XCTAssertTrue([vidfrom.code isEqualToString:vidto.code] ,@"vdictionary error");
    XCTAssertTrue([vidfrom.name isEqualToString:vidto.name] ,@"vdictionary error");
    
    BZVarietyValuesItemModel *vmodelfrom = (BZVarietyValuesItemModel*)fetchedObject.vmodel;
    BZVarietyValuesItemModel *vmodelto = (BZVarietyValuesItemModel*)savedObject.vmodel;
    XCTAssertTrue([vmodelfrom.code isEqualToString:vmodelto.code] ,@"vdictionary error");
    XCTAssertTrue([vmodelfrom.name isEqualToString:vmodelto.name] ,@"vdictionary error");
    
    // objective-c corelocation
    XCTAssertTrue(fetchedObject.vcoordinate2D.latitude == savedObject.vcoordinate2D.latitude,@"vcoordinate2D error");
    XCTAssertTrue(fetchedObject.vcoordinate2D.longitude == savedObject.vcoordinate2D.longitude,@"vcoordinate2D error");

    XCTAssertTrue(fetchedObject.vlocation.coordinate.latitude == savedObject.vlocation.coordinate.latitude,@"vlocation error");
    XCTAssertTrue(fetchedObject.vlocation.coordinate.longitude == savedObject.vlocation.coordinate.longitude,@"vlocation error");

    XCTAssertTrue(fetchedObject.vlocation.timestamp.timeIntervalSince1970 == savedObject.vlocation.timestamp.timeIntervalSince1970,@"vlocation error");
    XCTAssertTrue(fetchedObject.vlocation.speed == savedObject.vlocation.speed,@"vlocation error");
    XCTAssertTrue(fetchedObject.vlocation.course == savedObject.vlocation.course,@"vlocation error");
    XCTAssertTrue(fetchedObject.vlocation.altitude == savedObject.vlocation.altitude,@"vlocation error");
    XCTAssertTrue(fetchedObject.vlocation.horizontalAccuracy == savedObject.vlocation.horizontalAccuracy,@"vlocation error");

    // objective-c core graphics
    XCTAssertTrue(fetchedObject.vcgfloat == savedObject.vcgfloat,"vfloat error");
    XCTAssertTrue(CGRectEqualToRect(fetchedObject.vrect,savedObject.vrect),@"vrect error");
    XCTAssertTrue(CGPointEqualToPoint(fetchedObject.vpoint,savedObject.vpoint),@"vpoint error");
    XCTAssertTrue(CGSizeEqualToSize(fetchedObject.vsize,savedObject.vsize),@"vsize error");
    
    // set,array,dictionary,orderedset count test
    XCTAssertTrue(fetchedObject.vmutableSet.count == 3,@"vmutableSet error");
    XCTAssertTrue(fetchedObject.vmutableArray.count == 3,@"vmutableArray error");
    XCTAssertTrue(fetchedObject.vmutabledictionary.count == 2,@"vmutabledictionary error");
    XCTAssertTrue(fetchedObject.vmutableOrderedSet.count == 2,@"vmutableOrderedSet error");
    XCTAssertTrue(fetchedObject.vSet.count == 3,@"vSet error");
    XCTAssertTrue(fetchedObject.vArray.count == 3,@"vArray error");
    XCTAssertTrue(fetchedObject.vArrayWithCGRectCGPointCGSize.count == 3,@"vArray error");
    XCTAssertTrue(fetchedObject.vdictionary.count == 2,@"vdictionary error");
    XCTAssertTrue(fetchedObject.vOrderedSet.count == 2,@"vOrderedSet error");
    
    {
        if (fetchedObject.vArrayWithCGRectCGPointCGSize.count > 3) {
            NSValue *pointFetched = fetchedObject.vArrayWithCGRectCGPointCGSize[0];
            NSValue *sizeFetched = fetchedObject.vArrayWithCGRectCGPointCGSize[1];
            NSValue *rectFetched = fetchedObject.vArrayWithCGRectCGPointCGSize[2];
            XCTAssertTrue([pointFetched isEqualToValue:pointSaved] ,@"vArray error");
            XCTAssertTrue([sizeFetched isEqualToValue:sizeSaved] ,@"vArray error");
            XCTAssertTrue([rectFetched isEqualToValue:rectSaved] ,@"vArray error");
        }
    }
    
    //  array test
    {
        NSArray *fromList = fetchedObject.vArray;
        NSArray *toList = savedObject.vArray;
        for (NSInteger i = 0; i < fromList.count; i++ ) {
            BZVarietyValuesItemModel *from = fromList[i];
            BZVarietyValuesItemModel *to = toList[i];
            XCTAssertTrue([from.code isEqualToString:to.code] ,@"vArray error");
            XCTAssertTrue([from.name isEqualToString:to.name] ,@"vArray error");
        }
    }
    
    // dictionary test
    {
        NSArray *keys = fetchedObject.vdictionary.allKeys;
        for (NSString *key in keys) {
            BZVarietyValuesItemModel *from = [fetchedObject.vdictionary objectForKey:key];
            BZVarietyValuesItemModel *to = [savedObject.vdictionary objectForKey:key];
            XCTAssertTrue([from.code isEqualToString:to.code] ,@"vdictionary error");
            XCTAssertTrue([from.name isEqualToString:to.name] ,@"vdictionary error");
        }
    }
    
    // set test
    {
        NSArray *fromList = fetchedObject.vSet.allObjects;
        NSArray *toList = savedObject.vSet.allObjects;
        fromList = [fromList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            BZVarietyValuesItemModel *from = (BZVarietyValuesItemModel*)obj1;
            BZVarietyValuesItemModel *to = (BZVarietyValuesItemModel*)obj2;
            return [from.code compare:to.code];
        }];
        toList = [toList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            BZVarietyValuesItemModel *from = (BZVarietyValuesItemModel*)obj1;
            BZVarietyValuesItemModel *to = (BZVarietyValuesItemModel*)obj2;
            return [from.code compare:to.code];
        }];
        for (NSInteger i = 0; i < fromList.count; i++ ) {
            BZVarietyValuesItemModel *from = fromList[i];
            BZVarietyValuesItemModel *to = toList[i];
            XCTAssertTrue([from.code isEqualToString:to.code] ,@"vSet error");
            XCTAssertTrue([from.name isEqualToString:to.name] ,@"vSet error");
        }
    }
    
    // OrderedSet test
    {
        NSOrderedSet *fromList = fetchedObject.vOrderedSet;
        NSOrderedSet *toList = savedObject.vOrderedSet;
        for (NSInteger i = 0; i < fromList.count; i++ ) {
            BZVarietyValuesItemModel *from = fromList[i];
            BZVarietyValuesItemModel *to = toList[i];
            XCTAssertTrue([from.code isEqualToString:to.code] ,@"OrderedSet error");
            XCTAssertTrue([from.name isEqualToString:to.name] ,@"OrderedSet error");
        }
    }
    
    // mutable array test
    {
        NSArray *fromList = fetchedObject.vmutableArray;
        NSArray *toList = savedObject.vmutableArray;
        for (NSInteger i = 0; i < fromList.count; i++ ) {
            BZVarietyValuesItemModel *from = fromList[i];
            BZVarietyValuesItemModel *to = toList[i];
            XCTAssertTrue([from.code isEqualToString:to.code] ,@"vmutableArray error");
            XCTAssertTrue([from.name isEqualToString:to.name] ,@"vmutableArray error");
        }
    }
    
    // mutabledictionary test
    {
        NSArray *keys = fetchedObject.vmutabledictionary.allKeys;
        for (NSString *key in keys) {
            BZVarietyValuesItemModel *from = [fetchedObject.vmutabledictionary objectForKey:key];
            BZVarietyValuesItemModel *to = [savedObject.vmutabledictionary objectForKey:key];
            XCTAssertTrue([from.code isEqualToString:to.code] ,@"vmutabledictionary error");
            XCTAssertTrue([from.name isEqualToString:to.name] ,@"vmutabledictionary error");
        }
    }
    
    // mutableset test
    {
        NSArray *fromList = fetchedObject.vmutableSet.allObjects;
        NSArray *toList = savedObject.vmutableSet.allObjects;
        fromList = [fromList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            BZVarietyValuesItemModel *from = (BZVarietyValuesItemModel*)obj1;
            BZVarietyValuesItemModel *to = (BZVarietyValuesItemModel*)obj2;
            return [from.code compare:to.code];
        }];
        toList = [toList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            BZVarietyValuesItemModel *from = (BZVarietyValuesItemModel*)obj1;
            BZVarietyValuesItemModel *to = (BZVarietyValuesItemModel*)obj2;
            return [from.code compare:to.code];
        }];
        for (NSInteger i = 0; i < fromList.count; i++ ) {
            BZVarietyValuesItemModel *from = fromList[i];
            BZVarietyValuesItemModel *to = toList[i];
            XCTAssertTrue([from.code isEqualToString:to.code] ,@"vmutableSet error");
            XCTAssertTrue([from.name isEqualToString:to.name] ,@"vmutableSet error");
        }
    }
    
    // mutableOrderedSet test
    {
        NSMutableOrderedSet *fromList = fetchedObject.vmutableOrderedSet;
        NSMutableOrderedSet *toList = savedObject.vmutableOrderedSet;
        for (NSInteger i = 0; i < fromList.count; i++ ) {
            BZVarietyValuesItemModel *from = fromList[i];
            BZVarietyValuesItemModel *to = toList[i];
            XCTAssertTrue([from.code isEqualToString:to.code] ,@"mutableOrderedSet error");
            XCTAssertTrue([from.name isEqualToString:to.name] ,@"mutableOrderedSet error");
        }
    }
    
    // empty
    BZVarietyValuesModel *empty = [[BZVarietyValuesModel alloc]init];
    [os saveObject:empty error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSArray *emptyObjects = [os fetchObjects:[BZVarietyValuesModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(emptyObjects.count == 2,@"emptyObjects count error");
}

- (void)testBZInvalidValuesModel:(BZObjectStore*)os
{
    BZInvalidValuesModel *savedObject = [[BZInvalidValuesModel alloc]init];
    savedObject.vclass = [BZInvalidValuesModel class];
    savedObject.vsel = @selector(testBZInvalidValuesModel:);
    
    NSError *error = nil;
    [os saveObject:savedObject error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSArray *fetchedObjects = [os fetchObjects:[BZInvalidValuesModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    XCTAssertTrue(fetchedObjects.count == 1, @"count error");
}

- (void)testBZRelationshipHeaderModel:(BZObjectStore*)os
{
    BZRelationshipItemModel *item1 = [[BZRelationshipItemModel alloc]init];
    item1.code = @"item1";
    item1.price = 100;
    
    BZRelationshipItemModel *item2 = [[BZRelationshipItemModel alloc]init];
    item2.code = @"item2";
    item2.price = 200;
    item2.items = @[item1,item1];
    
    BZRelationshipDetailModel *detail1 = [[BZRelationshipDetailModel alloc]init];
    detail1.code = @"detail01";
    detail1.item = item1;
    detail1.count = 2;
    
    BZRelationshipDetailModel *detail2 = [[BZRelationshipDetailModel alloc]init];
    detail2.code = @"detail02";
    detail2.item = item2;
    detail2.count = 2;
    
    BZRelationshipHeaderModel *header = [[BZRelationshipHeaderModel alloc]init];
    header.code = @"header01";
    header.details = @[detail1,detail2];
    
    
    NSError *error = nil;
    [os saveObject:header error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSArray *fetchedObjects = [os fetchObjects:[BZRelationshipHeaderModel class] condition:nil error:&error];
    XCTAssertTrue(fetchedObjects.count == 1, @"relationship count error");
    
    BZRelationshipHeaderModel *fetchedHeader = fetchedObjects.firstObject;
    XCTAssertTrue(fetchedHeader.details.count == 2, @"sub array count error");
    
    BZRelationshipDetailModel *fetchedDetail = fetchedHeader.details.lastObject;
    XCTAssertTrue(fetchedDetail.item.items.count == 2, @"sub sub array count error");
    
    fetchedHeader.details = [NSArray array];
    [os saveObject:fetchedHeader error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    [os deleteObject:fetchedHeader error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSNumber *headerCount = [os count:[BZRelationshipHeaderModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue([headerCount integerValue] == 0, @"header count error");
    
    NSNumber *detailCount = [os count:[BZRelationshipDetailModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue([detailCount integerValue] == 0, @"header count error");
    
    NSNumber *itemCount = [os count:[BZRelationshipItemModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue([itemCount integerValue] == 0, @"header count error");
    
}

- (void)testBZInsertResponseModel:(BZObjectStore*)os
{
    NSError *error = nil;
    [os registerClass:[BZInsertResponseModel class] error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSMutableArray *list = [NSMutableArray array];
    for (NSInteger i = 0; i < 20000; i++ ) {
        BZInsertResponseModel *model = [[BZInsertResponseModel alloc]init];
        model.code = [NSString stringWithFormat:@"%ld",(long)i];
        model.name = [NSString stringWithFormat:@"name %ld",(long)i];
        model.address = [NSString stringWithFormat:@"address %ld",(long)i];
        model.birthday = [NSDate date];
        [list addObject:model];
    }
    
    NSDate *savenow = [NSDate date];
    [os saveObjects:list error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    NSDate *savethen = [NSDate date];
    NSLog(@"save reponse then - now: %1.3fsec", [savethen timeIntervalSinceDate:savenow]);
    
    NSDate *fetchnow = [NSDate date];
    NSArray *fetchObjects = [os fetchObjects:[BZInsertResponseModel class] condition:nil error:&error];
    XCTAssertTrue(fetchObjects.count == 20000, @"fetch error");
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    NSDate *fetchthen = [NSDate date];
    NSLog(@"fetch reponse then - now: %1.3fsec", [fetchthen timeIntervalSinceDate:fetchnow]);
    
    NSDate *removenow = [NSDate date];
    [os deleteObjects:[BZInsertResponseModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    NSDate *removethen = [NSDate date];
    NSLog(@"remove reponse then - now: %1.3fsec", [removethen timeIntervalSinceDate:removenow]);
    
    NSNumber *count = [os count:[BZInsertResponseModel class] condition:nil error:&error];
    XCTAssertTrue([count integerValue] == 0, @"fetch error");
    
    [os unRegisterClass:[BZInsertResponseModel class] error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
}

- (void)testBZUpdateResponseModel:(BZObjectStore*)os
{
    NSError *error = nil;
    [os registerClass:[BZInsertResponseModel class] error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSMutableArray *list = [NSMutableArray array];
    for (NSInteger i = 0; i < 1; i++ ) {
        BZUpdateResponseModel *model = [[BZUpdateResponseModel alloc]init];
        model.code = [NSString stringWithFormat:@"%ld",(long)i];
        model.name = [NSString stringWithFormat:@"name %ld",(long)i];
        model.address = [NSString stringWithFormat:@"address %ld",(long)i];
        model.birthday = [NSDate date];
        [list addObject:model];
    }
    for (NSInteger i = 0; i < 20000; i++ ) {
        BZUpdateResponseModel *model = [[BZUpdateResponseModel alloc]init];
        model.code = [NSString stringWithFormat:@"%ld",(long)i];
        model.name = [NSString stringWithFormat:@"name %ld",(long)i];
        model.address = [NSString stringWithFormat:@"address %ld",(long)i];
        model.birthday = [NSDate date];
        [list addObject:model];
    }
    
    NSDate *savenow = [NSDate date];
    [os saveObjects:list error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    NSDate *savethen = [NSDate date];
    NSLog(@"save reponse then - now: %1.3fsec", [savethen timeIntervalSinceDate:savenow]);
    
    NSDate *fetchnow = [NSDate date];
    NSArray *fetchObjects = [os fetchObjects:[BZUpdateResponseModel class] condition:nil error:&error];
    XCTAssertTrue(fetchObjects.count == 20000, @"fetch error");
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    NSDate *fetchthen = [NSDate date];
    NSLog(@"fetch reponse then - now: %1.3fsec", [fetchthen timeIntervalSinceDate:fetchnow]);
    
    NSDate *removenow = [NSDate date];
    [os deleteObjects:[BZUpdateResponseModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    NSDate *removethen = [NSDate date];
    NSLog(@"remove reponse then - now: %1.3fsec", [removethen timeIntervalSinceDate:removenow]);
    
    NSNumber *count = [os count:[BZUpdateResponseModel class] condition:nil error:&error];
    XCTAssertTrue([count integerValue] == 0, @"fetch error");
    
}

- (void)testCircularReference:(BZObjectStore*)os
{
    NSError *error = nil;
    
    BZCircularReferenceModel *p1 = [[BZCircularReferenceModel alloc]initWithId:@"10" name:@"Yamada Taro" birthday:[NSDate date]];
    BZCircularReferenceModel *p2 = [[BZCircularReferenceModel alloc]initWithId:@"20" name:@"Yamada Hanako" birthday:[NSDate date]];
    BZCircularReferenceModel *p3 = [[BZCircularReferenceModel alloc]initWithId:@"30" name:@"Yamada Ichiro" birthday:[NSDate date]];
    BZCircularReferenceModel *p4 = [[BZCircularReferenceModel alloc]initWithId:@"40" name:@"Yamada Jiro" birthday:[NSDate date]];
    BZCircularReferenceModel *p5 = [[BZCircularReferenceModel alloc]initWithId:@"50" name:@"Yamada Saburo" birthday:[NSDate date]];
    BZCircularReferenceModel *p6 = [[BZCircularReferenceModel alloc]initWithId:@"60" name:@"Yamada Shiro" birthday:[NSDate date]];
    BZCircularReferenceModel *p7 = [[BZCircularReferenceModel alloc]initWithId:@"70" name:@"Yamada Goro" birthday:[NSDate date]];
    p1.family = @[p2,p3];
    p1.familyReference = @[p4,p5];
    p1.familySerialize = @[p6,p7];
    p3.father = p1;
    p3.mother = p2;
    p4.father = p4;
    
    [os saveObjects:@[p4] error:nil];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    [os saveObjects:@[p5] error:nil];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    [os saveObject:p1 error:nil];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSArray *list = [os fetchObjects:[BZCircularReferenceModel class] condition:nil error:nil];
    XCTAssertTrue(list.count == 5,"object error");
    
    [os deleteObject:p3 error:nil];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSNumber *count1 = [os count:[BZCircularReferenceModel class] condition:nil error:nil];
    XCTAssertTrue([count1 isEqualToNumber:@4],"object error");
    
    [os deleteObject:p1 error:nil];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSNumber *count2 = [os count:[BZCircularReferenceModel class] condition:nil error:nil];
    XCTAssertTrue([count2 isEqualToNumber:@2],"object error");
    
}

- (void)testSQLiteGroupCondition:(BZObjectStore*)os
{
    NSError *error = nil;
    
    BZSQLiteGroupFunctionModel *item1 = [[BZSQLiteGroupFunctionModel alloc]initWithNo:@"10" name:@"apple" price:100];
    BZSQLiteGroupFunctionModel *item2 = [[BZSQLiteGroupFunctionModel alloc]initWithNo:@"20" name:@"banana" price:140];
    BZSQLiteGroupFunctionModel *item3 = [[BZSQLiteGroupFunctionModel alloc]initWithNo:@"30" name:@"orange" price:200];
    BZSQLiteGroupFunctionModel *item4 = [[BZSQLiteGroupFunctionModel alloc]initWithNo:@"40" name:@"pineapple" price:400];
    
    [os saveObjects:@[item1,item2,item3,item4] error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSNumber *max = [os max:@"price" class:[BZSQLiteGroupFunctionModel class] condition:nil error:nil];
    if (error) {
        XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    } else {
        XCTAssertTrue([max isEqualToNumber:@400],"error");
    }
    
    NSNumber *min = [os min:@"price" class:[BZSQLiteGroupFunctionModel class] condition:nil error:nil];
    if (error) {
        XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    } else {
        XCTAssertTrue([min isEqualToNumber:@100],"error");
    }
    
    NSNumber *avg = [os avg:@"price" class:[BZSQLiteGroupFunctionModel class] condition:nil error:nil];
    if (error) {
        XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    } else {
        XCTAssertTrue([avg isEqualToNumber:@210],"error");
    }
    
    NSNumber *sum = [os sum:@"price" class:[BZSQLiteGroupFunctionModel class] condition:nil error:nil];
    if (error) {
        XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    } else {
        XCTAssertTrue([sum integerValue] == 840,"error");
    }
    
    NSNumber *total = [os total:@"price" class:[BZSQLiteGroupFunctionModel class] condition:nil error:nil];
    if (error) {
        XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    } else {
        XCTAssertTrue([total integerValue] == 840,"error");
    }
    
    NSNumber *count = [os count:[BZSQLiteGroupFunctionModel class] condition:nil error:nil];
    if (error) {
        XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    } else {
        XCTAssertTrue([count integerValue] == 4,"error");
    }
    
}

- (void)testBZUpdateExistsObjectWithNoRowIdModel:(BZObjectStore*)os
{
    NSError *error = nil;
    
    BZUpdateExistsObjectWithNoRowIdModel *first = [[BZUpdateExistsObjectWithNoRowIdModel alloc]init];
    first.no1 = @"01";
    first.no2 = @"01";
    first.name = @"first";
    
    BZUpdateExistsObjectWithNoRowIdModel *second = [[BZUpdateExistsObjectWithNoRowIdModel alloc]init];
    second.no1 = @"01";
    second.no2 = @"01";
    second.name = @"second";
    
    BZUpdateExistsObjectWithNoRowIdModel *third = [[BZUpdateExistsObjectWithNoRowIdModel alloc]init];
    third.no1 = @"03";
    third.no2 = @"03";
    third.name = @"third";
    
    [os saveObject:first error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    [os saveObject:second error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    [os saveObject:third error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    second.name = @"";
    [os saveObject:second error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSArray *objects = [os fetchObjects:[BZUpdateExistsObjectWithNoRowIdModel class] condition:nil error:&error];
    BZUpdateExistsObjectWithNoRowIdModel *object = objects.firstObject;
    XCTAssertTrue([object.name isEqualToString:@""],"error");
    
}


- (void)testBZOnDemanItemModel:(BZObjectStore*)os
{
    NSError *error = nil;
    
    BZOnDemanItemModel *item = [[BZOnDemanItemModel alloc]init];
    item.code = @"01";
    item.name = @"itemname";
    
    BZOnDemandDetailModel *detail = [[BZOnDemandDetailModel alloc]init];
    detail.code = @"01";
    detail.items = [NSMutableArray array];
    [detail.items addObject:item];
    
    BZOnDemandHeaderModel *header = [[BZOnDemandHeaderModel alloc]init];
    header.code = @"01";
    header.details = [NSMutableArray array];
    [header.details addObject:detail];
    
    [os saveObject:header error:nil];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSMutableArray *headers = [os fetchObjects:[BZOnDemandHeaderModel class] condition:nil error:nil];
    if (error) {
        XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    } else {
        XCTAssertTrue(headers.count == 1,"object error");
    }
    
    BZOnDemandHeaderModel *headerLatest = headers.firstObject;
    XCTAssertTrue(!headerLatest.details,"object error");
    
    headerLatest = [os refreshObject:headerLatest error:nil];
    if (error) {
        XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    } else {
        XCTAssertTrue(headerLatest.details.count == 1,"object error");
    }
    
    
    
}

- (void)testBZExtendModel:(BZObjectStore*)os
{
    NSError *error = nil;
    
    BZExtendModel *saveObject = [[BZExtendModel alloc]init];
    saveObject.code = @"01";
    saveObject.name = @"name";
    
    [os saveObject:saveObject error:nil];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSArray *objects = [os fetchObjects:[BZExtendModel class] condition:nil error:&error];
    if (error) {
        XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    } else {
        BZExtendModel *fetchObject = objects.firstObject;
        XCTAssertTrue([fetchObject.code isEqualToString:@"01"],"object error");
    }
}

- (void)testBZIgnoreExtendModel:(BZObjectStore*)os
{
    NSError *error = nil;
    
    BZIgnoreExtendModel *saveObject = [[BZIgnoreExtendModel alloc]init];
    saveObject.code = @"01";
    saveObject.name = @"name";
    
    [os saveObject:saveObject error:nil];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSArray *objects = [os fetchObjects:[BZIgnoreExtendModel class] condition:nil error:&error];
    if (error) {
        XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    } else {
        BZIgnoreExtendModel *fetchObject = objects.firstObject;
        XCTAssertTrue(fetchObject.code == nil,"object error");
    }
}

- (void)testUpdateAttributeModel:(BZObjectStore*)os
{
    BZUpdateAttributeModel *saveObject = [[BZUpdateAttributeModel alloc]init];
    saveObject.onceUpdateAttribute = @"onceUpdateAttribute 1";
    saveObject.notUpdateIfValueIsNullAttribute = @"notUpdateIfValueIsNullAttribute 1";
    
    NSError *error = nil;
    [os saveObject:saveObject error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    saveObject.onceUpdateAttribute = @"onceUpdateAttribute 2";
    saveObject.notUpdateIfValueIsNullAttribute = nil;
    [os saveObject:saveObject error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    BZUpdateAttributeModel *fetchObject = [os refreshObject:saveObject error:&error];
    if (error) {
        XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    } else {
        XCTAssertTrue([fetchObject.onceUpdateAttribute isEqualToString:@"onceUpdateAttribute 1"],"object error");
        XCTAssertTrue([fetchObject.notUpdateIfValueIsNullAttribute isEqualToString:@"notUpdateIfValueIsNullAttribute 1"],"object error");
    }
}

- (void)testBZIgnoreAttribute:(BZObjectStore*)os
{
    BZIgnoreAttribute *saveObject = [[BZIgnoreAttribute alloc]init];
    saveObject.ignoreNo = @01;
    saveObject.notIgnoreNo = @02;
    
    NSError *error = nil;
    [os saveObject:saveObject error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    [os.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db getTableSchema:@"BZIgnoreAttribute"];
        while (rs.next) {
            NSString *columnName = [rs stringForColumnIndex:1];
            XCTAssertTrue(![columnName isEqualToString:@"ignoreNo"],"object error");
        }
        [rs close];
    }];
    
}

- (void)testBZDelegateModel:(BZObjectStore*)os
{
    BZDelegateModel *saveObject = [[BZDelegateModel alloc]init];
    XCTAssertTrue(!saveObject.modelDidLoad,"object error");
    XCTAssertTrue(!saveObject.modelDidDelete,"object error");
    XCTAssertTrue(!saveObject.modelDidSave,"object error");
    
    NSError *error = nil;
    [os saveObject:saveObject error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(saveObject.modelDidSave,"object error");
    
    NSArray *objects = [os fetchObjects:[BZDelegateModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    saveObject = objects.firstObject;
    XCTAssertTrue(saveObject.modelDidLoad,"object error");
    
    [os deleteObject:saveObject error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(saveObject.modelDidDelete,"object error");
    
}

- (void)testBZNameModel:(BZObjectStore*)os
{
    BZNameModel *saveObject = [[BZNameModel alloc]init];
    saveObject.group = 100;
    
    NSError *error = nil;
    [os saveObject:saveObject error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testAttributesModel:(BZObjectStore*)os
{
    NSError *error = nil;
    
    BZAttributeIsSerializeModel *serializeObject = [[BZAttributeIsSerializeModel alloc]init];
    BZAttributeIsWeakReferenceModel *weakReferenceObject = [[BZAttributeIsWeakReferenceModel alloc]init];
    BZAttributeIsfetchOnRefreshingModel *fetchOnRefreshingModel = [[BZAttributeIsfetchOnRefreshingModel alloc]init];
    
    BZAttributeIsModel *saveObject1 = [[BZAttributeIsModel alloc]init];
    saveObject1.identicalAttribute = @"01";
    saveObject1.ignoreAttribute = @"01";
    saveObject1.notUpdateIfValueIsNullAttribute = @"01";
    saveObject1.onceUpdateAttribute = @"01";
    saveObject1.name = @"name1";
    saveObject1.weakReferenceAttribute = weakReferenceObject;
    saveObject1.serializableAttribute = serializeObject;
    saveObject1.fetchOnRefreshingAttribute = fetchOnRefreshingModel;
    
    [os saveObject:saveObject1 error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    BZAttributeIsModel *saveObject2 = [[BZAttributeIsModel alloc]init];
    saveObject2.identicalAttribute = @"01";
    saveObject2.name = @"name2";
    saveObject2.notUpdateIfValueIsNullAttribute = nil;
    saveObject2.onceUpdateAttribute = @"02";
    [os saveObject:saveObject2 error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSArray *objects = [os fetchObjects:[BZAttributeIsModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(objects.count == 1,"object error");
    
    BZAttributeIsModel *fetchObject = objects.firstObject;
    XCTAssertTrue([fetchObject.name isEqualToString:@"name2"],"object error");
    XCTAssertTrue([fetchObject.notUpdateIfValueIsNullAttribute isEqualToString:@"01"],"object error");
    XCTAssertTrue([fetchObject.onceUpdateAttribute isEqualToString:@"01"],"object error");
    XCTAssertTrue(fetchObject.fetchOnRefreshingAttribute == nil,@"error") ;
    
    BZAttributeIsModel *refreshObject = [os refreshObject:fetchObject error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(refreshObject.fetchOnRefreshingAttribute != nil,@"error") ;
    
    [os.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db getTableSchema:@"BZAttributeIsModel"];
        while (rs.next) {
            NSString *columnName = [rs stringForColumnIndex:1];
            XCTAssertTrue(![columnName isEqualToString:@"ignoreAttribute"],"object error");
        }
        [rs close];
    }];
    
    
    BZAttributeIsModel *refreshingObjectNoRowid = [[BZAttributeIsModel alloc]init];
    refreshingObjectNoRowid.identicalAttribute = @"01";
    refreshingObjectNoRowid = [os refreshObject:refreshingObjectNoRowid error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue([refreshingObjectNoRowid.name isEqualToString:@"name2"],"refreshingObjectNoRowid error");
    XCTAssertTrue([refreshingObjectNoRowid.notUpdateIfValueIsNullAttribute isEqualToString:@"01"],"refreshingObjectNoRowid error");
    XCTAssertTrue([refreshingObjectNoRowid.onceUpdateAttribute isEqualToString:@"01"],"refreshingObjectNoRowid error");
    XCTAssertTrue(refreshingObjectNoRowid.fetchOnRefreshingAttribute != nil,@"refreshingObjectNoRowid") ;
    
    
    NSNumber *count = [os count:[BZAttributeIsSerializeModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(count.integerValue == 0,"object error");
    
    count = [os count:[BZAttributeIsWeakReferenceModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(count.integerValue == 1,"object error");
    
    [os deleteObjects:@[saveObject1,saveObject2] error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    count = [os count:[BZAttributeIsWeakReferenceModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(count.integerValue == 1,"object error");
    
    
}

- (void)testBZOrderByModel:(BZObjectStore*)os
{
    NSError *error = nil;
    
    BZOrderByModel *first = [[BZOrderByModel alloc]initWithCode:@"01" name:@"name1" price:10.12345f point:CGPointMake(59.87654321f, 1.23456789f)];
    BZOrderByModel *second = [[BZOrderByModel alloc]initWithCode:@"01" name:@"name1" price:10.12345f point:CGPointMake(19.87654321f, 11.23456789f)];
    BZOrderByModel *third = [[BZOrderByModel alloc]initWithCode:@"01" name:@"name2" price:30.12345f point:CGPointMake(49.87654321f, 12.23456789f)];
    BZOrderByModel *fourth = [[BZOrderByModel alloc]initWithCode:@"01" name:@"name2" price:24.12345f point:CGPointMake(39.87654321f, 13.23456789f)];
    BZOrderByModel *fifth = [[BZOrderByModel alloc]initWithCode:@"02" name:@"name2" price:26.12345f point:CGPointMake(19.87654321f, 14.23456789f)];
    BZOrderByModel *sixth = [[BZOrderByModel alloc]initWithCode:@"02" name:@"name2" price:27.12345f point:CGPointMake(19.87654321f, 14.23456789f)];
    BZOrderByModel *seventh = [[BZOrderByModel alloc]initWithCode:@"02" name:@"name2" price:27.12345f point:CGPointMake(39.87654321f, 14.23456789f)];
    [os saveObjects:@[first,second,third,fourth,fifth,sixth,seventh] error:&error];
    
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.orderBy = @"code desc,name desc,price desc,point_x desc";
    NSArray *objects = [os fetchObjects:[BZOrderByModel class] condition:condition error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    BZOrderByModel *firstFetch = objects.firstObject;
    BZOrderByModel *lastFetch = objects.lastObject;
    XCTAssertTrue([firstFetch.code isEqualToString:seventh.code],"object error");
    XCTAssertTrue(CGPointEqualToPoint(firstFetch.point,seventh.point) ,"object error");
    XCTAssertTrue([lastFetch.code isEqualToString:second.code],"object error");
    XCTAssertTrue(CGPointEqualToPoint(lastFetch.point,second.point) ,"object error");
    
}

- (void)testBZWhereModel:(BZObjectStore*)os
{
    NSError *error = nil;
    
    BZWhereModel *item01 = [[BZWhereModel alloc]initWithCode:@"01" name:@"item01"];
    BZWhereModel *item02 = [[BZWhereModel alloc]initWithCode:@"02" name:@"item02"];
    BZWhereModel *item03 = [[BZWhereModel alloc]initWithCode:@"03" name:@"item03"];
    BZWhereModel *item04 = [[BZWhereModel alloc]initWithCode:@"04" name:@"item04"];
    BZWhereModel *item05 = [[BZWhereModel alloc]initWithCode:@"05" name:@"item05"];
    
    [os saveObjects:@[item01,item02,item03,item04,item05] error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"code in ('03','04')";
    condition.sqlite.orderBy = @"code desc";
    
    NSArray *objects = [os fetchObjects:[BZWhereModel class] condition:condition error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    BZWhereModel *fetchObject = objects.firstObject;
    XCTAssertTrue([fetchObject.code isEqualToString:item04.code],"object error");
    XCTAssertTrue([fetchObject.name isEqualToString:item04.name],"object error");
    
}

- (void)testBZOffSetLimitModel:(BZObjectStore*)os
{
    NSError *error = nil;
    
    BZOffSetLimitModel *item01 = [[BZOffSetLimitModel alloc]initWithCode:@"01" name:@"name01" price:1.0f];
    BZOffSetLimitModel *item02 = [[BZOffSetLimitModel alloc]initWithCode:@"02" name:@"name02" price:2.0f];
    BZOffSetLimitModel *item03 = [[BZOffSetLimitModel alloc]initWithCode:@"03" name:@"name03" price:3.0f];
    BZOffSetLimitModel *item04 = [[BZOffSetLimitModel alloc]initWithCode:@"04" name:@"name04" price:4.0f];
    BZOffSetLimitModel *item05 = [[BZOffSetLimitModel alloc]initWithCode:@"05" name:@"name05" price:5.0f];
    BZOffSetLimitModel *item06 = [[BZOffSetLimitModel alloc]initWithCode:@"06" name:@"name06" price:6.0f];
    
    [os saveObjects:@[item01,item02,item03,item04,item05,item06] error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.orderBy = @"price desc";
    condition.sqlite.limit = @3;
    condition.sqlite.offset = @2;
    
    NSArray *objects = [os fetchObjects:[BZOffSetLimitModel class] condition:condition error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(objects.count == 3,"object error");
    
    BZOffSetLimitModel *first = objects.firstObject;
    XCTAssertTrue([first.code isEqualToString:@"04"],"object error");
    
}

- (void)testBZFullTextModel:(BZObjectStore*)os
{
    NSError *error = nil;
    
    NSMutableArray *objects = [NSMutableArray array];
    for (NSInteger i = 0; i < 2000; i++) {
        BZFullTextModel *saveObject = [[BZFullTextModel alloc]init];
        saveObject.address = [NSString stringWithFormat:@"test address%ld test",(long)i];
        [objects addObject:saveObject];
    }
    
    [os saveObjects:objects error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"address MATCH 'address5555'";
    
    NSDate *now = [NSDate date];
    objects = [os fetchObjects:[BZFullTextModel class] condition:condition error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    NSDate *then = [NSDate date];
    NSLog(@"fulltext fetch reponse then - now: %1.3fsec", [then timeIntervalSinceDate:now]);
    
    
}

- (void)testBZReferenceConditionModel:(BZObjectStore*)os
{
    NSError *error = nil;
    
    BZReferenceToConditionModel *to1 = [[BZReferenceToConditionModel alloc]init];
    to1.code = @1;
    to1.name = @"to1";
    to1.price = 10;
    
    BZReferenceToConditionModel *to2 = [[BZReferenceToConditionModel alloc]init];
    to2.code = @2;
    to2.name = @"to2";
    to2.price = 20;
    
    BZReferenceToConditionModel *to3 = [[BZReferenceToConditionModel alloc]init];
    to3.code = @3;
    to3.name = @"to3";
    to3.price = 30;
    
    BZReferenceConditionModel *item1 = [[BZReferenceConditionModel alloc]init];
    item1.code = @1;
    item1.name = @"item 1";
    item1.price = 10;
    item1.to = to1;
    item1.tos = @[to1,to2];
    
    BZReferenceConditionModel *item2 = [[BZReferenceConditionModel alloc]init];
    item2.code = @2;
    item2.name = @"item 2";
    item1.price = 20;
    item2.to = to2;
    
    BZReferenceConditionModel *item3 = [[BZReferenceConditionModel alloc]init];
    item3.code = @3;
    item3.name = @"item 3";
    item1.price = 30;
    
    BZReferenceFromConditionModel *from1 = [[BZReferenceFromConditionModel alloc]init];
    from1.code = @1;
    from1.name = @"from1";
    item1.price = 10;
    from1.to = item1;
    
    BZReferenceFromConditionModel *from2 = [[BZReferenceFromConditionModel alloc]init];
    from2.code = @2;
    from2.name = @"from2";
    item2.price = 20;
    from2.to = item2;
    
    BZReferenceFromConditionModel *from3 = [[BZReferenceFromConditionModel alloc]init];
    from3.code = @3;
    from3.name = @"from3";
    item3.price = 30;
    from3.to = item2;
    
    [os saveObjects:@[to1,to2,to3,item1,item2,item3,from1,from2] error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    BZObjectStoreConditionModel *fromCondition = [BZObjectStoreConditionModel condition];
    fromCondition.reference.from = from1;
    
    NSArray *fromObjects = [os fetchObjects:[BZReferenceConditionModel class] condition:fromCondition error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(fromObjects.count == 1, @"error");
    
    BZObjectStoreConditionModel *toCondition = [BZObjectStoreConditionModel condition];
    toCondition.reference.to = to2;
    
    NSArray *toObjects = [os fetchObjects:[BZReferenceConditionModel class] condition:toCondition error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(toObjects.count == 2, @"error");
    
    NSNumber *referencedCount = [os referencedCount:to2 error:&error];
    XCTAssertTrue(referencedCount.integerValue == 2, @"error");
    
    NSNumber *existsObject1 = [os existsObject:item1 error:&error];
    XCTAssertTrue(existsObject1.boolValue, @"error");
    
    NSNumber *existsObject2 = [os existsObject:from3 error:&error];
    XCTAssertTrue(!existsObject2.boolValue, @"error");
    
    NSArray *referencingObjects = [os fetchReferencingObjectsTo:item1 error:&error];
    BZReferenceConditionModel *referencingObject = referencingObjects.firstObject;
    XCTAssertTrue([referencingObject.name isEqualToString:@"from1"], @"error");
    
    
    BZObjectStoreConditionModel *fromNullCondition = [BZObjectStoreConditionModel condition];
    fromNullCondition.reference.from = [NSNull null];
    fromNullCondition.sqlite.where = @"price > 0";
    NSArray *fromNullReferencedObjects = [os fetchObjects:[BZReferenceToConditionModel class] condition:fromNullCondition error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    BZReferenceToConditionModel *fromNullReferencedObject = fromNullReferencedObjects.firstObject;
    XCTAssertTrue([fromNullReferencedObject.name isEqualToString:@"to3"], @"error");
    
    BZObjectStoreConditionModel *toNullCondition = [BZObjectStoreConditionModel condition];
    toNullCondition.reference.to = [NSNull null];
    toNullCondition.sqlite.where = @"price > 0";
    NSArray *toNullReferencedObjects = [os fetchObjects:[BZReferenceConditionModel class] condition:toNullCondition error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    BZReferenceToConditionModel *toNullReferencedObject = toNullReferencedObjects.firstObject;
    XCTAssertTrue([toNullReferencedObject.name isEqualToString:@"item 3"], @"error");
    
}

- (void)testBZOSIdenticalModel:(BZObjectStore*)os
{
    NSError *error = nil;
    
    BZOSIdenticalItemModel *item1 = [[BZOSIdenticalItemModel alloc]init];
    item1.code = @"01";
    item1.name = @"apple";
    
    BZOSIdenticalItemModel *item2 = [[BZOSIdenticalItemModel alloc]init];
    item2.code = @"02";
    item2.name = @"orange";
    
    BZOSIdenticalItemModel *item3 = [[BZOSIdenticalItemModel alloc]init];
    item3.code = @"03";
    item3.name = @"banana";
    
    
    hoo vvalue = {2,"name",1.23456788f};
    
    BZOSIdenticalModel *savedObject = [[BZOSIdenticalModel alloc]init];
    // POD types
    savedObject.vbool_max = YES;
    savedObject.vdouble_max = DBL_MAX;
    savedObject.vfloat_max = FLT_MAX;
    savedObject.vchar_max = CHAR_MAX;
    savedObject.vint_max = INT_MAX;
    savedObject.vshort_max = SHRT_MAX;
    savedObject.vlong_max = LONG_MAX;
    savedObject.vlonglong_max = LLONG_MAX;
    savedObject.vunsignedchar_max = UCHAR_MAX;
    savedObject.vunsignedint_max = UINT_MAX;
    savedObject.vunsignedshort_max = USHRT_MAX;
    savedObject.vunsignedlong_max = ULONG_MAX;
    savedObject.vunsignedlonglong_max = ULLONG_MAX;
    savedObject.vbool_min = NO;
    savedObject.vdouble_min = DBL_MIN;
    savedObject.vfloat_min = FLT_MIN;
    savedObject.vchar_min = CHAR_MIN;
    savedObject.vint_min = INT_MIN;
    savedObject.vshort_min = SHRT_MIN;
    savedObject.vlong_min = LONG_MIN;
    savedObject.vlonglong_min = LLONG_MIN;
    savedObject.vunsignedchar_min = 0;
    savedObject.vunsignedint_min = 0;
    savedObject.vunsignedshort_min = 0;
    savedObject.vunsignedlong_min = 0;
    savedObject.vunsignedlonglong_min = 0;
    savedObject.vfoo = vvalue;
    
    // objective-c
    savedObject.vnsinteger = 99;
    savedObject.vstring = @"string";
    savedObject.vrange = NSMakeRange(1, 2);
    savedObject.vmutableString = [NSMutableString stringWithString:@"mutableString"];
    savedObject.vnumber = [NSNumber numberWithBool:YES];
    savedObject.vurl = [NSURL URLWithString:@"http://wwww.yahoo.com"];
    savedObject.vnull = [NSNull null];
    savedObject.vcolor = [UIColor redColor];
    savedObject.vimage = [UIImage imageNamed:@"AppleLogo.png"];
    savedObject.vdata = [NSData dataWithData:UIImagePNGRepresentation(savedObject.vimage)];
    savedObject.vid = item2;
    savedObject.vmodel = item3;
    savedObject.vvalue = [NSValue value:&vvalue withObjCType:@encode(foo)];
    
    // objective-c core graphics
    savedObject.vcgfloat = 44.342334f;
    savedObject.vrect = CGRectMake(4.123456f,1.123456f,2.123456f,3.123456f);
    savedObject.vpoint = CGPointMake(4.123456f, 5.123456f);
    savedObject.vsize = CGSizeMake(6.123456f, 7.123456f);
    
    // objective-c array,set,dictionary,orderedset
    savedObject.vArray = [NSArray arrayWithObjects:item1,item2,item3, nil];
    savedObject.vSet = [NSSet setWithObjects:item1,item2,item3, nil];
    savedObject.vdictionary = [NSDictionary dictionaryWithObjectsAndKeys:item1,item1.name,item3,item3.name, nil];
    savedObject.vOrderedSet = [NSOrderedSet orderedSetWithObjects:item1,item3, nil];
    savedObject.vmutableArray = [NSMutableArray arrayWithObjects:item1,item2,item3, nil];
    savedObject.vmutableSet = [NSMutableSet setWithObjects:item1,item2,item3, nil];
    savedObject.vmutabledictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:item1,item1.name,item3,item3.name, nil];
    savedObject.vmutableOrderedSet = [NSMutableOrderedSet orderedSetWithObjects:item1,item3, nil];
    
    
    [os saveObject:savedObject error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    
    BZOSIdenticalModel *savedObject2 = [[BZOSIdenticalModel alloc]init];
    savedObject2.vstring = @"string";
    savedObject2.vmutableString = [NSMutableString stringWithString:@"mutableString"];
    savedObject2.vnumber = [NSNumber numberWithBool:YES];
    savedObject2.vurl = [NSURL URLWithString:@"http://wwww.yahoo.com"];
    savedObject2.vcolor = [UIColor redColor];
    
    [os saveObject:savedObject2 error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSNumber *count2 = [os count:[BZOSIdenticalModel class] condition:nil error:&error];
    XCTAssertTrue(count2.integerValue == 1, @"error");
    
    
    
    
    BZOSIdenticalModel *savedObject3 = [[BZOSIdenticalModel alloc]init];
    savedObject3.vstring = @"string3";
    savedObject3.vmutableString = [NSMutableString stringWithString:@"mutableString"];
    savedObject3.vnumber = [NSNumber numberWithBool:YES];
    savedObject3.vurl = [NSURL URLWithString:@"http://wwww.yahoo.com"];
    savedObject3.vcolor = [UIColor redColor];
    [os saveObject:savedObject3 error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    NSNumber *count3 = [os count:[BZOSIdenticalModel class] condition:nil error:&error];
    XCTAssertTrue(count3.integerValue == 2, @"error");
    
    
    
    BZOSIdenticalModel *savedObject4 = [[BZOSIdenticalModel alloc]init];
    savedObject4.vstring = @"string";
    savedObject4.vmutableString = [NSMutableString stringWithString:@"mutableString4"];
    savedObject4.vnumber = [NSNumber numberWithBool:YES];
    savedObject4.vurl = [NSURL URLWithString:@"http://wwww.yahoo.com"];
    savedObject4.vcolor = [UIColor redColor];
    [os saveObject:savedObject4 error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    NSNumber *count4 = [os count:[BZOSIdenticalModel class] condition:nil error:&error];
    XCTAssertTrue(count4.integerValue == 3, @"error");
    
    
    
    BZOSIdenticalModel *savedObject5 = [[BZOSIdenticalModel alloc]init];
    savedObject5.vstring = @"string";
    savedObject5.vmutableString = [NSMutableString stringWithString:@"mutableString"];
    savedObject5.vnumber = [NSNumber numberWithBool:NO];
    savedObject5.vurl = [NSURL URLWithString:@"http://wwww.yahoo.com"];
    savedObject5.vcolor = [UIColor redColor];
    
    [os saveObject:savedObject5 error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSNumber *count5 = [os count:[BZOSIdenticalModel class] condition:nil error:&error];
    XCTAssertTrue(count5.integerValue == 4, @"error");
    
    BZOSIdenticalModel *savedObject6 = [[BZOSIdenticalModel alloc]init];
    savedObject6.vstring = @"string";
    savedObject6.vmutableString = [NSMutableString stringWithString:@"mutableString"];
    savedObject6.vnumber = [NSNumber numberWithBool:YES];
    savedObject6.vurl = [NSURL URLWithString:@"http://wwww.yahoo.com2"];
    savedObject6.vcolor = [UIColor redColor];
    
    [os saveObject:savedObject6 error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSNumber *count6 = [os count:[BZOSIdenticalModel class] condition:nil error:&error];
    XCTAssertTrue(count6.integerValue == 5, @"error");
    
    BZOSIdenticalModel *savedObject7 = [[BZOSIdenticalModel alloc]init];
    savedObject7.vstring = @"string";
    savedObject7.vmutableString = [NSMutableString stringWithString:@"mutableString"];
    savedObject7.vnumber = [NSNumber numberWithBool:YES];
    savedObject7.vurl = [NSURL URLWithString:@"http://wwww.yahoo.com"];
    savedObject7.vcolor = [UIColor clearColor];
    
    [os saveObject:savedObject7 error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSNumber *count7 = [os count:[BZOSIdenticalModel class] condition:nil error:&error];
    XCTAssertTrue(count7.integerValue == 6, @"error");
    
    BZOSIdenticalModel *savedObject8 = [[BZOSIdenticalModel alloc]init];
    savedObject8.vstring = @"string";
    savedObject8.vmutableString = [NSMutableString stringWithString:@"mutableString"];
    savedObject8.vnumber = [NSNumber numberWithBool:YES];
    savedObject8.vurl = [NSURL URLWithString:@"http://wwww.yahoo.com"];
    savedObject8.vcolor = [UIColor clearColor];
    
    [os deleteObject:savedObject8 error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSNumber *count8 = [os count:[BZOSIdenticalModel class] condition:nil error:&error];
    XCTAssertTrue(count8.integerValue == 5, @"error");
    
}

- (void)testBZWeakPropertyModel:(BZObjectStore*)os
{
    NSError *error = nil;
    
    BZWeakPropertyModel *item1 = [[BZWeakPropertyModel alloc]init];
    BZWeakPropertyModel *item2 = [[BZWeakPropertyModel alloc]init];
    NSArray *objects = @[item1,item2];
    item1.objects = objects;
    
    [os saveObject:item1 error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    [os deleteObject:item1 error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSNumber *count = [os count:[BZWeakPropertyModel class] condition:nil error:&error];
    XCTAssertTrue(count.integerValue == 1, @"error");
    
}

- (void)testBZAddColumnsModel:(BZObjectStore*)os
{
    NSError *error = nil;
    
    // setup models
    BZAddColumnsAddItemModel *item1 = [[BZAddColumnsAddItemModel alloc]init];
    item1.code = @"01";
    item1.name = @"apple";
    
    BZAddColumnsAddItemModel *item2 = [[BZAddColumnsAddItemModel alloc]init];
    item2.code = @"02";
    item2.name = @"orange";
    
    BZAddColumnsAddItemModel *item3 = [[BZAddColumnsAddItemModel alloc]init];
    item3.code = @"03";
    item3.name = @"banana";
    
    
    //
    BZAddColumnsModel *noColumnObject = [[BZAddColumnsModel alloc]init];
    noColumnObject.code = @"01";
    [os saveObject:noColumnObject error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    NSNumber *count = [os count:[BZAddColumnsModel class] condition:nil error:&error];
    XCTAssertTrue(count.integerValue == 1, @"error");
    
    
    poo vvalue = {2,"name",1.23456788f};
    BZAddColumnsAddModel *columnObject = [[BZAddColumnsAddModel alloc]init];
    // POD types
    columnObject.code = @"01";
    columnObject.vbool_max = YES;
    columnObject.vdouble_max = DBL_MAX;
    columnObject.vfloat_max = FLT_MAX;
    columnObject.vchar_max = CHAR_MAX;
    columnObject.vint_max = INT_MAX;
    columnObject.vshort_max = SHRT_MAX;
    columnObject.vlong_max = LONG_MAX;
    columnObject.vlonglong_max = LLONG_MAX;
    columnObject.vunsignedchar_max = UCHAR_MAX;
    columnObject.vunsignedint_max = UINT_MAX;
    columnObject.vunsignedshort_max = USHRT_MAX;
    columnObject.vunsignedlong_max = ULONG_MAX;
    columnObject.vunsignedlonglong_max = ULLONG_MAX;
    columnObject.vbool_min = NO;
    columnObject.vdouble_min = DBL_MIN;
    columnObject.vfloat_min = FLT_MIN;
    columnObject.vchar_min = CHAR_MIN;
    columnObject.vint_min = INT_MIN;
    columnObject.vshort_min = SHRT_MIN;
    columnObject.vlong_min = LONG_MIN;
    columnObject.vlonglong_min = LLONG_MIN;
    columnObject.vunsignedchar_min = 0;
    columnObject.vunsignedint_min = 0;
    columnObject.vunsignedshort_min = 0;
    columnObject.vunsignedlong_min = 0;
    columnObject.vunsignedlonglong_min = 0;
    columnObject.vpoo = vvalue;
    
    // objective-c
    columnObject.vnsinteger = 99;
    columnObject.vstring = @"string";
    columnObject.vrange = NSMakeRange(1, 2);
    columnObject.vmutableString = [NSMutableString stringWithString:@"mutableString"];
    columnObject.vnumber = [NSNumber numberWithBool:YES];
    columnObject.vurl = [NSURL URLWithString:@"http://wwww.yahoo.com"];
    columnObject.vnull = [NSNull null];
    columnObject.vcolor = [UIColor redColor];
    columnObject.vimage = [UIImage imageNamed:@"AppleLogo.png"];
    columnObject.vdata = [NSData dataWithData:UIImagePNGRepresentation(columnObject.vimage)];
    columnObject.vid = item2;
    columnObject.vmodel = item3;
    columnObject.vvalue = [NSValue value:&vvalue withObjCType:@encode(foo)];
    
    // objective-c core graphics
    columnObject.vcgfloat = 44.342334f;
    columnObject.vrect = CGRectMake(4.123456f,1.123456f,2.123456f,3.123456f);
    columnObject.vpoint = CGPointMake(4.123456f, 5.123456f);
    columnObject.vsize = CGSizeMake(6.123456f, 7.123456f);
    
    // objective-c array,set,dictionary,orderedset
    columnObject.vArray = [NSArray arrayWithObjects:item1,item2,item3, nil];
    columnObject.vSet = [NSSet setWithObjects:item1,item2,item3, nil];
    columnObject.vdictionary = [NSDictionary dictionaryWithObjectsAndKeys:item1,item1.name,item3,item3.name, nil];
    columnObject.vOrderedSet = [NSOrderedSet orderedSetWithObjects:item1,item3, nil];
    columnObject.vmutableArray = [NSMutableArray arrayWithObjects:item1,item2,item3, nil];
    columnObject.vmutableSet = [NSMutableSet setWithObjects:item1,item2,item3, nil];
    columnObject.vmutabledictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:item1,item1.name,item3,item3.name, nil];
    columnObject.vmutableOrderedSet = [NSMutableOrderedSet orderedSetWithObjects:item1,item3, nil];
    
    
    [os saveObject:columnObject error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSNumber *count2 = [os count:[BZAddColumnsAddModel class] condition:nil error:&error];
    XCTAssertTrue(count2.integerValue == 1, @"error");
    
    NSArray *objects = [os fetchObjects:[BZAddColumnsModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    noColumnObject = objects.firstObject;
    XCTAssertTrue(objects.count == 1, @"error");
    
    objects = [os fetchObjects:[BZAddColumnsAddModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    BZAddColumnsAddModel *fetchedObject = objects.firstObject;
    XCTAssertTrue(objects.count == 1, @"error");
    
    BZAddColumnsAddModel *savedObject = columnObject;
    XCTAssertTrue(fetchedObject.vdouble_max == savedObject.vdouble_max,"vdouble_max error");
    XCTAssertTrue(fetchedObject.vbool_max == savedObject.vbool_max,"vdouble_max error");
    XCTAssertTrue(fetchedObject.vfloat_max == savedObject.vfloat_max,"vfloat_max error");
    XCTAssertTrue(fetchedObject.vchar_max == savedObject.vchar_max,"vchar_max error");
    XCTAssertTrue(fetchedObject.vint_max == savedObject.vint_max,"vint_max error");
    XCTAssertTrue(fetchedObject.vshort_max == savedObject.vshort_max,"vshort_max error");
    XCTAssertTrue(fetchedObject.vlong_max == savedObject.vlong_max,"vlong_max error");
    XCTAssertTrue(fetchedObject.vlonglong_max == savedObject.vlonglong_max,"vlonglong_max error");
    XCTAssertTrue(fetchedObject.vunsignedchar_max == savedObject.vunsignedchar_max,"vunsignedchar_max error");
    XCTAssertTrue(fetchedObject.vunsignedint_max == savedObject.vunsignedint_max,"vunsignedint_max error");
    XCTAssertTrue(fetchedObject.vunsignedshort_max == savedObject.vunsignedshort_max,"vunsignedshort_max error");
    XCTAssertTrue(fetchedObject.vunsignedlong_max == savedObject.vunsignedlong_max,"vunsignedlong_max error");
    XCTAssertTrue(fetchedObject.vunsignedlonglong_max == savedObject.vunsignedlonglong_max,"vunsignedlonglong_max error");
    XCTAssertTrue(fetchedObject.vdouble_min == savedObject.vdouble_min,"vdouble_min error");
    XCTAssertTrue(fetchedObject.vbool_min == savedObject.vbool_min,"vbool_min error");
    XCTAssertTrue(fetchedObject.vfloat_min == savedObject.vfloat_min,"vfloat_min error");
    XCTAssertTrue(fetchedObject.vchar_min == savedObject.vchar_min,"vchar_min error");
    XCTAssertTrue(fetchedObject.vint_min == savedObject.vint_min,"vint_min error");
    XCTAssertTrue(fetchedObject.vshort_min == savedObject.vshort_min,"vshort_min error");
    XCTAssertTrue(fetchedObject.vlong_min == savedObject.vlong_min,"vlong_min error");
    XCTAssertTrue(fetchedObject.vlonglong_min == savedObject.vlonglong_min,"vlonglong_min error");
    XCTAssertTrue(fetchedObject.vunsignedchar_min == savedObject.vunsignedchar_min,"vunsignedchar_min error");
    XCTAssertTrue(fetchedObject.vunsignedint_min == savedObject.vunsignedint_min,"vunsignedint_min error");
    XCTAssertTrue(fetchedObject.vunsignedshort_min == savedObject.vunsignedshort_min,"vunsignedshort_min error");
    XCTAssertTrue(fetchedObject.vunsignedlong_min == savedObject.vunsignedlong_min,"vunsignedlong_min error");
    XCTAssertTrue(fetchedObject.vunsignedlonglong_min == savedObject.vunsignedlonglong_min,"vunsignedlonglong_min error");
    XCTAssertTrue(fetchedObject.vpoo.no == 2, @"struct int error");
    XCTAssertTrue(strcmp(fetchedObject.vpoo.name, "name") == 0, @"struct int error");
    XCTAssertTrue(fetchedObject.vpoo.average == 1.23456788f, @"struct double error");
    
    // objective-c
    XCTAssertTrue(fetchedObject.vnsinteger == savedObject.vnsinteger,"vinteger error");
    XCTAssertTrue([fetchedObject.vstring isEqualToString:savedObject.vstring],"vstring error");
    XCTAssertTrue(fetchedObject.vrange.length == savedObject.vrange.length,"vrange error");
    XCTAssertTrue(fetchedObject.vrange.location == savedObject.vrange.location,"vrange error");
    XCTAssertTrue([fetchedObject.vmutableString isEqualToString:savedObject.vmutableString],"vmutableString error");
    XCTAssertTrue([fetchedObject.vnumber isEqualToNumber:savedObject.vnumber],"vnumber error");
    XCTAssertTrue([fetchedObject.vcolor RGBAValue] == [[UIColor redColor] RGBAValue],@"vcolor error");
    XCTAssertTrue([[fetchedObject.vurl absoluteString] isEqualToString:[savedObject.vurl absoluteString]],@"vurl error");
    XCTAssertTrue(fetchedObject.vnull == [NSNull null],@"vmutableSet error");
    XCTAssertTrue([fetchedObject.vdata isEqualToData:[NSData dataWithData:UIImagePNGRepresentation(fetchedObject.vimage)]],@"vdata,vimage error");
    
}

- (void)testBZTypeMissMatchModel:(BZObjectStore*)os
{
    // setup models
    BZTypeMissMatchItemModel *item1 = [[BZTypeMissMatchItemModel alloc]init];
    item1.code = @"01";
    item1.name = @"apple";
    
    BZTypeMissMatchItemModel *item2 = [[BZTypeMissMatchItemModel alloc]init];
    item2.code = @"02";
    item2.name = @"orange";
    
    BZTypeMissMatchItemModel *item3 = [[BZTypeMissMatchItemModel alloc]init];
    item3.code = @"03";
    item3.name = @"banana";
    
    BZTypeMissMatchModel *savedObject = [[BZTypeMissMatchModel alloc]init];
    
    qoo vvalue = {2,"name",1.23456788f};
    
    // POD types
    savedObject.vbool_max = YES;
    savedObject.vdouble_max = DBL_MAX;
    savedObject.vfloat_max = FLT_MAX;
    savedObject.vchar_max = CHAR_MAX;
    savedObject.vint_max = INT_MAX;
    savedObject.vshort_max = SHRT_MAX;
    savedObject.vlong_max = LONG_MAX;
    savedObject.vlonglong_max = LLONG_MAX;
    savedObject.vunsignedchar_max = UCHAR_MAX;
    savedObject.vunsignedint_max = UINT_MAX;
    savedObject.vunsignedshort_max = USHRT_MAX;
    savedObject.vunsignedlong_max = ULONG_MAX;
    savedObject.vunsignedlonglong_max = ULLONG_MAX;
    savedObject.vbool_min = NO;
    savedObject.vdouble_min = DBL_MIN;
    savedObject.vfloat_min = FLT_MIN;
    savedObject.vchar_min = CHAR_MIN;
    savedObject.vint_min = INT_MIN;
    savedObject.vshort_min = SHRT_MIN;
    savedObject.vlong_min = LONG_MIN;
    savedObject.vlonglong_min = LLONG_MIN;
    savedObject.vunsignedchar_min = 0;
    savedObject.vunsignedint_min = 0;
    savedObject.vunsignedshort_min = 0;
    savedObject.vunsignedlong_min = 0;
    savedObject.vunsignedlonglong_min = 0;
    savedObject.vqoo = vvalue;
    
    // objective-c
    savedObject.vnsinteger = 99;
    savedObject.vstring = @"string";
    savedObject.vrange = NSMakeRange(1, 2);
    savedObject.vmutableString = [NSMutableString stringWithString:@"mutableString"];
    savedObject.vnumber = [NSNumber numberWithBool:YES];
    savedObject.vurl = [NSURL URLWithString:@"http://wwww.yahoo.com"];
    savedObject.vnull = [NSNull null];
    savedObject.vcolor = [UIColor redColor];
    savedObject.vimage = [UIImage imageNamed:@"AppleLogo.png"];
    savedObject.vdata = [NSData dataWithData:UIImagePNGRepresentation(savedObject.vimage)];
    savedObject.vid = item2;
    savedObject.vmodel = item3;
    savedObject.vvalue = [NSValue value:&vvalue withObjCType:@encode(foo)];
    
    // objective-c core graphics
    savedObject.vcgfloat = 44.342334f;
    savedObject.vrect = CGRectMake(4.123456f,1.123456f,2.123456f,3.123456f);
    savedObject.vpoint = CGPointMake(4.123456f, 5.123456f);
    savedObject.vsize = CGSizeMake(6.123456f, 7.123456f);
    
    // objective-c array,set,dictionary,orderedset
    savedObject.vArray = [NSArray arrayWithObjects:item1,item2,item3, nil];
    savedObject.vSet = [NSSet setWithObjects:item1,item2,item3, nil];
    savedObject.vdictionary = [NSDictionary dictionaryWithObjectsAndKeys:item1,item1.name,item3,item3.name, nil];
    savedObject.vOrderedSet = [NSOrderedSet orderedSetWithObjects:item1,item3, nil];
    savedObject.vmutableArray = [NSMutableArray arrayWithObjects:item1,item2,item3, nil];
    savedObject.vmutableSet = [NSMutableSet setWithObjects:item1,item2,item3, nil];
    savedObject.vmutabledictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:item1,item1.name,item3,item3.name, nil];
    savedObject.vmutableOrderedSet = [NSMutableOrderedSet orderedSetWithObjects:item1,item3, nil];
    
    // save object
    NSError *error = nil;
    [os saveObject:savedObject error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSArray *objects = [os fetchObjects:[BZTypeMissMatchMissMatchModel class] condition:nil error:&error];
    BZTypeMissMatchMissMatchModel *fetchedObject = objects.firstObject;
    
    XCTAssertTrue(fetchedObject.vdouble_max == [NSNull null],"vdouble_max error");
    XCTAssertTrue(!fetchedObject.vbool_max,"vdouble_max error");
    XCTAssertTrue(fetchedObject.vfloat_max,"vfloat_max error");
    XCTAssertTrue(fetchedObject.vchar_max,"vchar_max error");
    XCTAssertTrue(!fetchedObject.vint_max,"vint_max error");
    XCTAssertTrue(fetchedObject.vdouble_min,"vdouble_min error");
    XCTAssertTrue(!fetchedObject.vbool_min,"vbool_min error");
    XCTAssertTrue(!fetchedObject.vfloat_min,"vfloat_min error");
    XCTAssertTrue(!fetchedObject.vchar_min,"vchar_min error");
    XCTAssertTrue(!fetchedObject.vint_min,"vint_min error");
    XCTAssertTrue(!fetchedObject.vshort_min,"vshort_min error");
    XCTAssertTrue(!fetchedObject.vlong_min,"vlong_min error");
    XCTAssertTrue(!fetchedObject.vlonglong_min,"vlonglong_min error");
    XCTAssertTrue(!fetchedObject.vunsignedchar_min,"vunsignedchar_min error");
    XCTAssertTrue(CGPointEqualToPoint(fetchedObject.vunsignedint_min, CGPointZero),"vunsignedint_min error");
    XCTAssertTrue(CGRectEqualToRect(fetchedObject.vunsignedshort_min, CGRectZero),"vunsignedshort_min error");
    XCTAssertTrue(CGSizeEqualToSize(fetchedObject.vunsignedlong_min, CGSizeZero),"vunsignedlong_min error");
    XCTAssertTrue(NSEqualRanges(fetchedObject.vunsignedlonglong_min, NSMakeRange(0, 0)),"vunsignedlonglong_min error");
    XCTAssertTrue(!fetchedObject.vfoo, @"struct int error");
    XCTAssertTrue(!fetchedObject.vcolor,@"vcolor error");
    XCTAssertTrue(!fetchedObject.vnull,@"vmutableSet error");
    XCTAssertTrue(!fetchedObject.vdata,@"vdata,vimage error");
    
}

- (void)testBZOSIdenticalAttributeOSSerializeAttributeModel:(BZObjectStore*)os
{
    NSError *error = nil;
    BZOSIdenticalAttributeOSSerializeAttributeModel *savedObject01 = [[BZOSIdenticalAttributeOSSerializeAttributeModel alloc]init];
    savedObject01.code = @"01";
    savedObject01.name = @"name01";
    [os saveObject:savedObject01 error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    BZOSIdenticalAttributeOSSerializeAttributeModel *savedObject02 = [[BZOSIdenticalAttributeOSSerializeAttributeModel alloc]init];
    savedObject02.code = @"01";
    savedObject02.name = @"name02";
    [os saveObject:savedObject02 error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSNumber *count = [os count:[BZOSIdenticalAttributeOSSerializeAttributeModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(count.integerValue == 2,@"vdata,vimage error");
    
}

- (void)testBZOSIdenticalFirstModel:(BZObjectStore*)os
{
    NSError *error = nil;
    
    BZOSIdenticalFirstModel *first = [[BZOSIdenticalFirstModel alloc]init];
    first.code1 = @"01";
    first.name = @"first";
    
    BZOSIdenticalSecondModel *second = [[BZOSIdenticalSecondModel alloc]init];
    second.code1 = @"01";
    second.name = @"second";
    
    BZOSIdenticalThirdModel *third = [[BZOSIdenticalThirdModel alloc]init];
    third.code1 = @"01";
    third.code2 = nil;
    third.name = @"third";
    
    BZOSIdenticalForthModel *forth = [[BZOSIdenticalForthModel alloc]init];
    forth.code1 = @"01";
    forth.code2 = nil;
    forth.name = @"forth";
    
    [os saveObject:first error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    [os saveObject:second error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    [os saveObject:third error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSArray *objects = [os fetchObjects:[BZOSIdenticalThirdModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(objects.count == 2,@"vdata,vimage error");
    
    [os saveObject:forth error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    
}

- (NSString*)testBZDuplicateAttributeModel:(BZObjectStore*)os
{
    NSError *error = nil;
    BZDuplicateAttributeModel *savedObject = [[BZDuplicateAttributeModel alloc]init];
    savedObject.code = @"01";
    [os saveObject:savedObject error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
}

- (void)testBZObjectStoreReferenceModel:(BZObjectStore*)os
{
    BZObjectStoreReferenceModel *object = [[BZObjectStoreReferenceModel alloc]init];
    object.rowid = @100;
    XCTAssertTrue(object.rowid.integerValue == 100,@"testBZObjectStoreReferenceModel error");
}

- (void)testBZObjectStoreNameBuilder:(BZObjectStore*)os
{
    BZObjectStoreNameBuilder *builder = [[BZObjectStoreNameBuilder alloc]init];
    NSString *tableName = [builder tableName:[BZObjectStoreNameBuilder class]];
    XCTAssertTrue([tableName isEqualToString:@"BZObjectStoreNameBuilder"],@"BZObjectStoreNameBuilder error");
}

- (void)testBZObjectStoreClazzBZImage:(BZObjectStore*)os
{
    NSError *error = nil;
    
    [BZObjectStoreClazz addClazz:[BZObjectStoreClazzBZImage class]];
    [BZObjectStoreClazz addClazz:[NSString class]];
    
    BZImage *image = [[BZImage alloc]init];
    image.url = @"http://wwww.yahoo.co.jp";
    image.gif = nil;
    
    BZImageHolderModel *holder = [[BZImageHolderModel alloc]init];
    holder.code = @"10";
    holder.image = image;
    
    [os saveObject:holder error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    holder.code = @"20";
    holder.image.url = @"http://www.google.com/";
    
    [os saveObject:holder error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSNumber *count = [os count:[BZImageHolderModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    XCTAssertTrue(count.integerValue == 1,@"testBZObjectStoreClazzBZImage error");
    
    NSArray *objects = [os fetchObjects:[BZImageHolderModel class] condition:nil error:&error];
    BZImageHolderModel *object = objects.firstObject;
    XCTAssertTrue([object.code isEqualToString:@"10"],@"testBZObjectStoreClazzBZImage error");
    XCTAssertTrue([object.image.url isEqualToString:@"http://www.google.com/"],@"testBZObjectStoreClazzBZImage error");
    
    
}

// todo
- (void)testBZArrayInArrayModel:(BZObjectStore*)os
{
    NSError *error = nil;
    BZArrayInArrayModel *savedObject1 = [[BZArrayInArrayModel alloc]init];
    savedObject1.arrayInArray = @[[NSArray arrayWithObjects:@10,@"10",nil]];
    
    BZArrayInArrayModel *savedObject2 = [[BZArrayInArrayModel alloc]init];
    savedObject2.arrayInArray = @[[NSArray arrayWithObjects:@10,@"10",savedObject1, nil]];
    savedObject2.dictionaryInArray = @[@{@"null": [NSNull null],@"object1": savedObject1}];
    
    [os saveObject:savedObject2 error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    [os deleteObjects:@[savedObject2,savedObject2] error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
}

- (void)testInTransaction:(BZObjectStore*)os
{
    [os inTransaction:^(BZObjectStore *os, BOOL *rollback) {
        NSError *error = nil;
        BZTransactionModel *saveObject = [[BZTransactionModel alloc]init];
        saveObject.code = @1;
        [os saveObject:saveObject error:&error];
        XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
        NSNumber *count = [os count:[BZTransactionModel class] condition:nil error:&error];
        XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
        XCTAssertTrue(count.intValue == 1,@"testInTransaction error");
    }];
    
    [os inTransaction:^(BZObjectStore *os, BOOL *rollback) {
        NSError *error = nil;
        BZTransactionModel *saveObject = [[BZTransactionModel alloc]init];
        saveObject.code = @1;
        [os saveObject:saveObject error:&error];
        XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
        NSNumber *count = [os count:[BZTransactionModel class] condition:nil error:&error];
        XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
        XCTAssertTrue(count.intValue == 2,@"testInTransaction error");
        *rollback = YES;
    }];
    
    NSError *error = nil;
    NSNumber *count = [os count:[BZTransactionModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(count.intValue == 1,@"testInTransaction error");
    
}

- (void)testBackground:(BZObjectStore*)os
{
    BZBackgroundModel *savedObject = [[BZBackgroundModel alloc]init];
    savedObject.code = @10;
    savedObject.name = @"test";
    savedObject.price = 1.234567890009;
    
    __block NSError *err = nil;
    __block NSNumber *val = nil;
    __block NSArray *list = nil;
    __block BZBackgroundModel *obj = nil;
    
    [os saveObjectInBackground:savedObject completionBlock:^(NSError *error) {
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"saveObjectInBackground \"%s\"", __PRETTY_FUNCTION__);
    
    val = nil;
    [os countInBackground:[BZBackgroundModel class] condition:nil completionBlock:^(NSNumber *value, NSError *error) {
        val = value;
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"error \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(val.integerValue == 1,@"countInBackground error");
    
    val = nil;
    [os referencedCountInBackground:savedObject completionBlock:^(NSNumber *value, NSError *error) {
        val = value;
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"error \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(val.integerValue == 0,@"referencedCountInBackground error");
    
    obj = nil;
    [os refreshObjectInBackground:savedObject completionBlock:^(NSObject *object, NSError *error) {
        obj = (BZBackgroundModel*)object;
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"error \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue([obj.code isEqualToNumber:savedObject.code],@"refreshObjectInBackground error");
    
    list = nil;
    [os fetchReferencingObjectsToInBackground:savedObject completionBlock:^(NSArray *objects, NSError *error) {
        list = objects;
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"fetchReferencingObjectsToInBackground \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(list.count == 0,@"fetchReferencingObjectsToInBackground error");
    
    
    val = nil;
    [os sumInBackground:@"price" class:[BZBackgroundModel class] condition:nil completionBlock:^(NSNumber *value, NSError *error) {
        val = value;
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"error \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(val.doubleValue == 1.234567890009,@"sumInBackground error");
    
    val = nil;
    [os totalInBackground:@"price" class:[BZBackgroundModel class] condition:nil completionBlock:^(NSNumber *value, NSError *error) {
        val = value;
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"error \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(val.doubleValue == 1.234567890009,@"totalInBackground error");
    
    val = nil;
    [os avgInBackground:@"price" class:[BZBackgroundModel class] condition:nil completionBlock:^(NSNumber *value, NSError *error) {
        val = value;
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"error \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(val.doubleValue == 1.234567890009,@"avgInBackground error");
    
    val = nil;
    [os minInBackground:@"price" class:[BZBackgroundModel class] condition:nil completionBlock:^(NSNumber *value, NSError *error) {
        val = value;
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"error \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(val.doubleValue == 1.234567890009,@"minInBackground error");
    
    val = nil;
    [os maxInBackground:@"price" class:[BZBackgroundModel class] condition:nil completionBlock:^(NSNumber *value, NSError *error) {
        val = value;
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"error \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(val.doubleValue == 1.234567890009,@"maxInBackground error");
    
    val = nil;
    [os saveObjectsInBackground:@[savedObject] completionBlock:^(NSError *error) {
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"saveObjectsInBackground \"%s\"", __PRETTY_FUNCTION__);
    
    list = nil;
    [os fetchObjectsInBackground:[BZBackgroundModel class] condition:nil completionBlock:^(NSArray *objects, NSError *error) {
        list = objects;
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"fetchObjectsInBackground \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(list.count == 1,@"fetchObjectsInBackground error");
    
    [os deleteObjectInBackground:list.firstObject completionBlock:^(NSError *error) {
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"removeObjectInBackground \"%s\"", __PRETTY_FUNCTION__);
    
    [os saveObjectInBackground:savedObject completionBlock:^(NSError *error) {
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"saveObjectInBackground \"%s\"", __PRETTY_FUNCTION__);
    
    [os deleteObjectsInBackground:@[list.firstObject] completionBlock:^(NSError *error) {
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"removeObjectsInBackground \"%s\"", __PRETTY_FUNCTION__);
    
    [os saveObjectInBackground:savedObject completionBlock:^(NSError *error) {
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"saveObjectInBackground \"%s\"", __PRETTY_FUNCTION__);
    
    [os deleteObjectsInBackground:[BZBackgroundModel class] condition:nil completionBlock:^(NSError *error) {
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"deleteObjectsInBackground \"%s\"", __PRETTY_FUNCTION__);
    
    list = nil;
    [os fetchObjectsInBackground:[BZBackgroundModel class] condition:nil completionBlock:^(NSArray *objects, NSError *error) {
        list = objects;
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"fetchObjectsInBackground \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(list.count == 0,@"fetchObjectsInBackground error");
    
    [os inTransactionInBackground:^(BZObjectStore *os, BOOL *rollback) {
        NSError *error = nil;
        NSNumber *count = [os count:[BZBackgroundModel class] condition:nil error:&error];
        err = error;
        val = count;
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            RESUME;
        }];
    }];
    WAIT;
    XCTAssert(!err, @"inTransactionInBackground \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(val.integerValue == 0,@"countInBackground error");
    
    [os registerClassInBackground:[BZBackgroundModel class] completionBlock:^(NSError *error) {
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"registerClassInBackground \"%s\"", __PRETTY_FUNCTION__);
    
    [os unRegisterClassInBackground:[BZBackgroundModel class] completionBlock:^(NSError *error) {
        err = error;
        RESUME;
    }];
    WAIT;
    XCTAssert(!err, @"unRegisterClassInBackground \"%s\"", __PRETTY_FUNCTION__);
    
}

- (void)testBZActiveRecordModel:(BZObjectStore*)os
{
    [BZActiveRecord setupWithObjectStore:os];
    
    NSError *error = nil;
    for (NSInteger i = 0; i < 10; i++) {
        BZActiveRecordModel *save = [[BZActiveRecordModel alloc]init];
        save.code = [NSString stringWithFormat:@"%ld",(long)i];
        save.price = i * 10;
        [save save:&error];
        XCTAssert(!error, @"activerecord save \"%s\"", __PRETTY_FUNCTION__);
    }
    
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"code IN ( ?,? )";
    condition.sqlite.parameters = @[@"1",@"2"];
    
    NSNumber *count = [BZActiveRecordModel count:condition error:&error];
    XCTAssertTrue(count.integerValue == 2,@"activerecord count error");
    
    NSNumber *total = [BZActiveRecordModel total:@"price" condition:condition error:&error];
    XCTAssertTrue(total.integerValue == 30,@"activerecord total error");
    
    NSNumber *sum = [BZActiveRecordModel sum:@"price" condition:condition error:&error];
    XCTAssertTrue(sum.integerValue == 30,@"activerecord sum error");

    NSNumber *avg = [BZActiveRecordModel avg:@"price" condition:condition error:&error];
    XCTAssertTrue(avg.integerValue == 15,@"activerecord avg error");

    NSNumber *max = [BZActiveRecordModel max:@"price" condition:nil error:&error];
    XCTAssertTrue(max.integerValue ==90,@"activerecord max error");

    NSNumber *min = [BZActiveRecordModel min:@"price" condition:nil error:&error];
    XCTAssertTrue(min.integerValue ==0,@"activerecord max error");

}

- (void)testBZParseModel:(BZObjectStore*)os
{
    NSError *error = nil;

    PFUser *user = [PFUser user];
    user.username = @"my name";
    user.password = @"my pass";
    user.email = @"email@example.com";
    BOOL ret = [user signUp];
    if (ret) {
        [user save];
    }
    [os saveObject:user error:&error];

    for (NSInteger i = 0; i < 10; i++) {
        BZParseModel *parseModel = [[BZParseModel alloc]init];
        parseModel.code = [NSString stringWithFormat:@"%ld",(long)i];
        parseModel.price = i * 10;
        parseModel.string = @"string";
        parseModel.mutableString = [NSMutableString stringWithString:@"mutableString"];
        parseModel.date = [NSDate date];
        PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:1.23456789f longitude:9.87654321f];
        [parseModel setValue:point forKeyPath:@"point"];
        [os saveObject:parseModel error:&error];
    }
    NSArray *objects = [os fetchObjects:[BZParseModel class] condition:nil error:&error];
    XCTAssertTrue(objects.count == 10,@"count error");
    
    for (BZParseModel *object in objects) {
        [object save:&error];
        XCTAssert(!error, @"parse \"%s\"", __PRETTY_FUNCTION__);
        [os saveObject:object error:&error];
        XCTAssert(!error, @"parse \"%s\"", __PRETTY_FUNCTION__);
    }
    NSNumber *count = [os count:[BZParseModel class] condition:nil error:&error];
    XCTAssertTrue(count.integerValue == 10,@"count error");

    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = @"code IN ( ?,? )";
    condition.sqlite.parameters = @[@"1",@"2"];
    
    NSNumber *count2 = [BZParseModel OSCount:condition error:&error];
    XCTAssertTrue(count2.integerValue == 2,@"activerecord count error");
    
    NSNumber *total = [BZParseModel OSTotal:@"price" condition:condition error:&error];
    XCTAssertTrue(total.integerValue == 30,@"activerecord total error");
    
    NSNumber *sum = [BZParseModel OSSum:@"price" condition:condition error:&error];
    XCTAssertTrue(sum.integerValue == 30,@"activerecord sum error");
    
    NSNumber *avg = [BZParseModel OSAvg:@"price" condition:condition error:&error];
    XCTAssertTrue(avg.integerValue == 15,@"activerecord avg error");
    
    NSNumber *max = [BZParseModel OSMax:@"price" condition:nil error:&error];
    XCTAssertTrue(max.integerValue ==90,@"activerecord max error");
    
    NSNumber *min = [BZParseModel OSMin:@"price" condition:nil error:&error];
    XCTAssertTrue(min.integerValue ==0,@"activerecord max error");

    
}

@end
