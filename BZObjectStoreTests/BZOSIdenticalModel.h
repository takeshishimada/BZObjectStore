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

typedef struct {
	int no;
	char name[20];
	double average;
} hoo;

@interface BZOSIdenticalModel : NSObject<OSModelInterface>
// POD types
@property (nonatomic,assign) double vdouble_min;
@property (nonatomic,assign) BOOL vbool_min;
@property (nonatomic,assign) char vchar_min;
@property (nonatomic,assign) int vint_min;
@property (nonatomic,assign) float vfloat_min;
@property (nonatomic,assign) short vshort_min;
@property (nonatomic,assign) long vlong_min;
@property (nonatomic,assign) long long vlonglong_min;
@property (nonatomic,assign) unsigned char vunsignedchar_min;
@property (nonatomic,assign) unsigned int vunsignedint_min;
@property (nonatomic,assign) unsigned short vunsignedshort_min;
@property (nonatomic,assign) unsigned long vunsignedlong_min;
@property (nonatomic,assign) unsigned long long vunsignedlonglong_min;

@property (nonatomic,assign) double vdouble_max;
@property (nonatomic,assign) BOOL vbool_max;
@property (nonatomic,assign) char vchar_max;
@property (nonatomic,assign) int vint_max;
@property (nonatomic,assign) float vfloat_max;
@property (nonatomic,assign) short vshort_max;
@property (nonatomic,assign) long vlong_max;
@property (nonatomic,assign) long long vlonglong_max;
@property (nonatomic,assign) unsigned char vunsignedchar_max;
@property (nonatomic,assign) unsigned int vunsignedint_max;
@property (nonatomic,assign) unsigned short vunsignedshort_max;
@property (nonatomic,assign) unsigned long vunsignedlong_max;
@property (nonatomic,assign) unsigned long long vunsignedlonglong_max;

@property (nonatomic,assign) hoo vfoo;

// objective-c
@property (nonatomic,assign) NSInteger vnsinteger;
@property (nonatomic,assign) NSRange vrange;
@property (nonatomic,strong) NSString *vstring;
@property (nonatomic,strong) NSMutableString *vmutableString;
@property (nonatomic,strong) NSNumber *vnumber;
@property (nonatomic,strong) NSNull *vnull;
@property (nonatomic,strong) NSURL *vurl;
@property (nonatomic,strong) NSData *vdata;
@property (nonatomic,strong) UIColor *vcolor;
@property (nonatomic,strong) UIImage *vimage;
@property (nonatomic,strong) id vid;
@property (nonatomic,strong) BZOSIdenticalItemModel *vmodel;
@property (nonatomic,strong) NSValue *vvalue;

// objective-c core graphics
@property (nonatomic,assign) CGFloat vcgfloat;
@property (nonatomic,assign) CGRect vrect;
@property (nonatomic,assign) CGPoint vpoint;
@property (nonatomic,assign) CGSize vsize;
@property (nonatomic,assign) CGRect vnilrect;

// objective-c array,set,dictionary,orderedset
@property (nonatomic,strong) NSSet *vSet;
@property (nonatomic,strong) NSArray *vArray;
@property (nonatomic,strong) NSDictionary *vdictionary;
@property (nonatomic,strong) NSOrderedSet *vOrderedSet;
@property (nonatomic,strong) NSMutableSet *vmutableSet;
@property (nonatomic,strong) NSMutableArray *vmutableArray;
@property (nonatomic,strong) NSMutableDictionary *vmutabledictionary;
@property (nonatomic,strong) NSMutableOrderedSet *vmutableOrderedSet;

@end
