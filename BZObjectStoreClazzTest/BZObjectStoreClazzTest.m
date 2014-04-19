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

#import <XCTest/XCTest.h>
#import "BZObjectStoreClazz.h"
#import "BZObjectStoreClazzID.h"
#import "BZObjectStoreClazzNSObject.h"
#import "BZObjectStoreClazzNSDate.h"
#import "BZObjectStoreClazzNSURL.h"
#import "BZObjectStoreClazzNSMutableString.h"
#import "BZObjectStoreClazzNSString.h"
#import "BZObjectStoreClazzNSNumber.h"
#import "BZObjectStoreClazzNSData.h"
#import "BZObjectStoreClazzUIColor.h"
#import "BZObjectStoreClazzUIImage.h"
#import "BZObjectStoreClazzNSValue.h"
#import "BZObjectStoreClazzNSNull.h"
#import "BZObjectStoreClazzPrimitive.h"
#import "BZObjectStoreClazzInt.h"
#import "BZObjectStoreClazzChar.h"
#import "BZObjectStoreClazzFloat.h"
#import "BZObjectStoreClazzDouble.h"
#import "BZObjectStoreClazzCGRect.h"
#import "BZObjectStoreClazzCGSize.h"
#import "BZObjectStoreClazzCGPoint.h"
#import "BZObjectStoreClazzNSRange.h"
#import "BZObjectStoreClazzNSMutableArray.h"
#import "BZObjectStoreClazzNSMutableDictionary.h"
#import "BZObjectStoreClazzNSMutableSet.h"
#import "BZObjectStoreClazzNSMutableOrderedSet.h"
#import "BZObjectStoreClazzNSArray.h"
#import "BZObjectStoreClazzNSDictionary.h"
#import "BZObjectStoreClazzNSSet.h"
#import "BZObjectStoreClazzNSOrderedSet.h"
#import "BZObjectStoreClazzSerialize.h"

@interface BZTestObject : NSObject
@property (nonatomic,strong) NSValue *value;
@end
@implementation BZTestObject
@end

@interface BZObjectStoreClazzTest : XCTestCase
@end

@implementation BZObjectStoreClazzTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBZObjectStoreClazzCGRect
{
    BZTestObject *test = [[BZTestObject alloc]init];
    test.value = nil;
    
    BZObjectStoreClazzCGRect *clazz = [[BZObjectStoreClazzCGRect alloc]init];
    NSArray *array = [clazz storeValuesWithObject:test attributeName:@"value"];
    XCTAssertTrue(array[0] == [NSNull null],@"BZObjectStoreClazzCGRect error");
    XCTAssertTrue(array[1] == [NSNull null],@"BZObjectStoreClazzCGRect error");
    XCTAssertTrue(array[2] == [NSNull null],@"BZObjectStoreClazzCGRect error");
    XCTAssertTrue(array[3] == [NSNull null],@"BZObjectStoreClazzCGRect error");

}

- (void)testBZObjectStoreClazzCGPoint
{
    BZTestObject *test = [[BZTestObject alloc]init];
    test.value = nil;
    
    BZObjectStoreClazzCGPoint *clazz = [[BZObjectStoreClazzCGPoint alloc]init];
    NSArray *array = [clazz storeValuesWithObject:test attributeName:@"value"];
    XCTAssertTrue(array[0] == [NSNull null],@"BZObjectStoreClazzCGRect error");
    XCTAssertTrue(array[1] == [NSNull null],@"BZObjectStoreClazzCGRect error");
    
}

- (void)testBZObjectStoreClazzCGSize
{
    BZTestObject *test = [[BZTestObject alloc]init];
    test.value = nil;
    
    BZObjectStoreClazzCGSize *clazz = [[BZObjectStoreClazzCGSize alloc]init];
    NSArray *array = [clazz storeValuesWithObject:test attributeName:@"value"];
    XCTAssertTrue(array[0] == [NSNull null],@"BZObjectStoreClazzCGRect error");
    XCTAssertTrue(array[1] == [NSNull null],@"BZObjectStoreClazzCGRect error");
    
}

- (void)testBZObjectStoreClazzInt
{
    BZTestObject *test = [[BZTestObject alloc]init];
    test.value = nil;
    
    BZObjectStoreClazzInt *clazz = [[BZObjectStoreClazzInt alloc]init];
    NSArray *array = [clazz storeValuesWithObject:test attributeName:@"value"];
    XCTAssertTrue(array[0] == [NSNull null],@"BZObjectStoreClazzCGRect error");
    
}

- (void)testBZObjectStoreClazzNSDate
{
    BZObjectStoreClazzNSDate *clazz = [[BZObjectStoreClazzNSDate alloc]init];
    NSObject *storeValue = [clazz storeValueWithValue:nil];
    NSObject *value = [clazz valueWithStoreValue:nil];
    XCTAssertTrue(storeValue == [NSNull null],@"BZObjectStoreClazzNSDate error");
    XCTAssertTrue(!value,@"BZObjectStoreClazzNSDate error");
}

- (void)testBZObjectStoreClazzNSRange
{
    BZObjectStoreClazzNSRange *clazz = [[BZObjectStoreClazzNSRange alloc]init];
    NSObject *storeValue = [clazz storeValueWithValue:nil];
    NSValue *value = [clazz valueWithStoreValue:nil];
    XCTAssertTrue(storeValue == [NSNull null],@"BZObjectStoreClazzNSDate error");
    XCTAssertTrue(NSEqualRanges([value rangeValue], NSMakeRange(0, 0)),@"BZObjectStoreClazzNSDate error");
}

- (void)testBZObjectStoreClazzFloat
{
    BZObjectStoreClazzFloat *clazz = [[BZObjectStoreClazzFloat alloc]init];
    NSObject *storeValue = [clazz storeValueWithValue:nil];
    NSNumber *value = [clazz valueWithStoreValue:nil];
    XCTAssertTrue(storeValue == [NSNull null],@"BZObjectStoreClazzFloat error");
    XCTAssertTrue(value.floatValue == 0.0f,@"BZObjectStoreClazzFloat error");
}

- (void)testBZObjectStoreClazzDouble
{
    BZObjectStoreClazzDouble *clazz = [[BZObjectStoreClazzDouble alloc]init];
    NSObject *storeValue = [clazz storeValueWithValue:nil];
    NSNumber *value = [clazz valueWithStoreValue:nil];
    XCTAssertTrue(storeValue == [NSNull null],@"BZObjectStoreClazzDouble error");
    XCTAssertTrue(value.doubleValue == 0.0f,@"BZObjectStoreClazzDouble error");
}

@end
