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

#import <Foundation/Foundation.h>

@class BZObjectStoreRuntime;
@class BZObjectStoreRuntimeProperty;
@class BZObjectStoreFetchConditionModel;
@class BZObjectStoreNameBuilder;

@interface BZObjectStoreQueryBuilder : NSObject

+ (NSString*)selectStatement:(BZObjectStoreRuntime*)runtime;
+ (NSString*)selectRowidStatement:(BZObjectStoreRuntime*)runtime;
+ (NSString*)updateStatement:(BZObjectStoreRuntime*)runtime;
+ (NSString*)updateStatement:(BZObjectStoreRuntime*)runtime attributes:(NSArray*)attributes;
+ (NSString*)insertIntoStatement:(BZObjectStoreRuntime*)runtime;
+ (NSString*)insertOrReplaceIntoStatement:(BZObjectStoreRuntime*)runtime;
+ (NSString*)insertOrIgnoreIntoStatement:(BZObjectStoreRuntime*)runtime;
+ (NSString*)deleteFromStatement:(BZObjectStoreRuntime*)runtime;
+ (NSString*)createTableStatement:(BZObjectStoreRuntime*)runtime;
+ (NSString*)dropTableStatement:(BZObjectStoreRuntime*)runtime;
+ (NSString*)createUniqueIndexStatement:(BZObjectStoreRuntime*)runtime;
+ (NSString*)createIndexStatement:(BZObjectStoreRuntime*)runtime;
+ (NSString*)dropIndexStatement:(BZObjectStoreRuntime*)runtime;
+ (NSString*)referencedCountStatement:(BZObjectStoreRuntime*)runtime;
+ (NSString*)countStatement:(BZObjectStoreRuntime*)runtime;

+ (NSString*)selectConditionStatement:(BZObjectStoreFetchConditionModel*)condition;
+ (NSString*)selectConditionStatement:(BZObjectStoreFetchConditionModel*)condition runtime:(BZObjectStoreRuntime*)runtime;
+ (NSString*)selectConditionOptionStatement:(BZObjectStoreFetchConditionModel*)condition;
+ (NSString*)deleteConditionStatement:(BZObjectStoreFetchConditionModel*)condition;
+ (NSString*)updateConditionStatement:(BZObjectStoreFetchConditionModel*)condition;

+ (NSString*)rowidConditionStatement;
+ (NSString*)uniqueConditionStatement:(BZObjectStoreRuntime*)runtime;

+ (NSString*)alterTableAddColumnStatement:(BZObjectStoreRuntime*)runtime attribute:(BZObjectStoreRuntimeProperty*)attribute;
+ (NSString*)maxStatement:(BZObjectStoreRuntime*)runtime attribute:(BZObjectStoreRuntimeProperty*)attribute;
+ (NSString*)minStatement:(BZObjectStoreRuntime*)runtime attribute:(BZObjectStoreRuntimeProperty*)attribute;
+ (NSString*)avgStatement:(BZObjectStoreRuntime*)runtime attribute:(BZObjectStoreRuntimeProperty*)attribute;
+ (NSString*)totalStatement:(BZObjectStoreRuntime*)runtime attribute:(BZObjectStoreRuntimeProperty*)attribute;
+ (NSString*)sumStatement:(BZObjectStoreRuntime*)runtime attribute:(BZObjectStoreRuntimeProperty*)attribute;


@end
