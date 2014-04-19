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

#import <Foundation/Foundation.h>
#import "BZObjectStoreModelInterface.h"
#import "AutoCoding.h"

@class BZAddColumnsAddItemModel;

@interface BZTypeMissMatchMissMatchModel : NSObject<OSModelInterface>
@property (nonatomic,strong) NSURL *vdouble_min;
@property (nonatomic,strong) NSArray *vbool_min;
@property (nonatomic,strong) NSSet *vchar_min;
@property (nonatomic,strong) NSOrderedSet *vint_min;
@property (nonatomic,strong) NSDictionary *vfloat_min;
@property (nonatomic,strong) NSMutableArray *vshort_min;
@property (nonatomic,strong) NSMutableSet *vlong_min;
@property (nonatomic,strong) NSMutableDictionary *vlonglong_min;
@property (nonatomic,strong) NSMutableOrderedSet *vunsignedchar_min;
@property (nonatomic,assign) CGPoint vunsignedint_min;
@property (nonatomic,assign) CGRect vunsignedshort_min;
@property (nonatomic,assign) CGSize vunsignedlong_min;
@property (nonatomic,assign) NSRange vunsignedlonglong_min;
@property (nonatomic,strong) NSNull *vdouble_max;
@property (nonatomic,strong) NSValue *vbool_max;
@property (nonatomic,strong) NSString *vfoo;
@property (nonatomic,strong) NSMutableString *vnull;
@property (nonatomic,strong) NSDate *vchar_max;
@property (nonatomic,strong) UIImage *vint_max;
@property (nonatomic,strong) NSData *vfloat_max;
@property (nonatomic,assign) char vdata;
@property (nonatomic,assign) int vcolor;
@property (nonatomic,strong) BZAddColumnsAddItemModel *vmodel;
//@property (nonatomic,strong) NSNumber *vshort_max;
//@property (nonatomic,strong) NSNumber *vlong_max;
//@property (nonatomic,strong) NSNumber *vlonglong_max;
//@property (nonatomic,strong) NSNumber *vunsignedchar_max;
//@property (nonatomic,strong) NSNumber *vunsignedint_max;
//@property (nonatomic,strong) NSNumber *vunsignedshort_max;
//@property (nonatomic,strong) NSNumber *vunsignedlong_max;
//@property (nonatomic,strong) NSNumber *vunsignedlonglong_max;
//@property (nonatomic,strong) NSNumber *vnsinteger;
//@property (nonatomic,strong) NSNumber *vrange;
//@property (nonatomic,strong) NSNumber *vstring;
//@property (nonatomic,strong) NSNumber *vmutableString;
//@property (nonatomic,strong) NSNumber *vnumber;
//@property (nonatomic,strong) NSNumber *vurl;
//@property (nonatomic,strong) NSNumber *vimage;
//@property (nonatomic,strong) NSNumber *vid;
//@property (nonatomic,strong) NSNumber *vvalue;
//@property (nonatomic,strong) NSNumber *vcgfloat;
//@property (nonatomic,strong) NSNumber *vrect;
//@property (nonatomic,strong) NSNumber *vpoint;
//@property (nonatomic,strong) NSNumber *vsize;
//@property (nonatomic,strong) NSNumber *vnilrect;
//@property (nonatomic,strong) NSNumber *vSet;
//@property (nonatomic,strong) NSNumber *vArray;
//@property (nonatomic,strong) NSNumber *vdictionary;
//@property (nonatomic,strong) NSNumber *vOrderedSet;
//@property (nonatomic,strong) NSNumber *vmutableSet;
//@property (nonatomic,strong) NSNumber *vmutableArray;
//@property (nonatomic,strong) NSNumber *vmutabledictionary;
//@property (nonatomic,strong) NSNumber *vmutableOrderedSet;
@end
