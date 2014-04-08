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
#import "BZObjectStoreAttributeInterface.h"

@class BZObjectStoreRuntimeProperty;
@class BZObjectStoreRuntime;

@interface BZObjectStoreRelationshipModel : NSObject<BZObjectStoreModelInterface>
@property (nonatomic,strong) NSString *fromClassName;
@property (nonatomic,strong) NSString *fromTableName;
@property (nonatomic,strong) NSString *fromAttributeName;
@property (nonatomic,strong) NSNumber *fromRowid;
@property (nonatomic,strong) NSString *toClassName;
@property (nonatomic,strong) NSString *toTableName;
@property (nonatomic,strong) NSNumber *toRowid;
@property (nonatomic,strong) NSNumber *attributeLevel;
@property (nonatomic,assign) NSNumber *attributeSequence;
@property (nonatomic,strong) NSNumber *attributeParentLevel;
@property (nonatomic,strong) NSNumber *attributeParentSequence;
@property (nonatomic,strong) NSString *attributeKey;
@property (nonatomic,strong) NSObject *attributeValue;
@property (nonatomic,strong) NSObject<OSIgnoreAttribute> *attributeFromObject;
@property (nonatomic,strong) NSObject<OSIgnoreAttribute> *attributeToObject;
//@property (nonatomic,strong) ObjectStoreRuntime<OSIgnoreAttribute> *attributeRuntime;
+ (NSString*)OSTableName;
@end
