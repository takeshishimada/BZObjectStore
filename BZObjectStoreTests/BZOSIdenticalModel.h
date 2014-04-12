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
#import "BZObjectStoreModelInterface.h"

@class BZOSIdenticalItemModel;

@interface BZOSIdenticalModel : NSObject
@property (nonatomic,strong) NSString<OSIdenticalAttribute> *vstring;
@property (nonatomic,strong) NSMutableString<OSIdenticalAttribute> *vmutableString;
@property (nonatomic,strong) NSNumber<OSIdenticalAttribute> *vnumber;
@property (nonatomic,strong) NSNull<OSIdenticalAttribute> *vnull;
@property (nonatomic,strong) NSURL<OSIdenticalAttribute> *vurl;
@property (nonatomic,strong) NSData<OSIdenticalAttribute> *vdata;
@property (nonatomic,strong) UIColor<OSIdenticalAttribute> *vcolor;
@property (nonatomic,strong) UIImage *vimage;
@property (nonatomic,strong) id<OSIdenticalAttribute> vid;
@property (nonatomic,strong) BZOSIdenticalItemModel<OSIdenticalAttribute> *vmodel;
@property (nonatomic,strong) NSValue<OSIdenticalAttribute> *vvalue;
@property (nonatomic,strong) NSSet<OSIdenticalAttribute> *vSet;
@property (nonatomic,strong) NSArray<OSIdenticalAttribute> *vArray;
@property (nonatomic,strong) NSDictionary<OSIdenticalAttribute> *vdictionary;
@property (nonatomic,strong) NSOrderedSet<OSIdenticalAttribute> *vOrderedSet;
@property (nonatomic,strong) NSMutableSet<OSIdenticalAttribute> *vmutableSet;
@property (nonatomic,strong) NSMutableArray<OSIdenticalAttribute> *vmutableArray;
@property (nonatomic,strong) NSMutableDictionary<OSIdenticalAttribute> *vmutabledictionary;
@property (nonatomic,strong) NSMutableOrderedSet<OSIdenticalAttribute> *vmutableOrderedSet;
@end
