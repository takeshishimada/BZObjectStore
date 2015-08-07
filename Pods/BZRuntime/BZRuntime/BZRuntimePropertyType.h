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

// https://developer.apple.com/library/ios/documentation/cocoa/conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW5

@interface BZRuntimePropertyType : NSObject

//
- (id)initWithAttributes:(NSString*)attributes;
// Declared property type encodings
@property (nonatomic,assign,readonly) BOOL isReadonly;
@property (nonatomic,assign,readonly) BOOL isCopy;
@property (nonatomic,assign,readonly) BOOL isRetain;
@property (nonatomic,assign,readonly) BOOL isNonatomic;
@property (nonatomic,assign,readonly) BOOL isCustomSetter;
@property (nonatomic,assign,readonly) BOOL isCustomGetter;
@property (nonatomic,assign,readonly) BOOL isDynamic;
@property (nonatomic,assign,readonly) BOOL isWeakReference;
@property (nonatomic,assign,readonly) BOOL isEligibleForGC;
@property (nonatomic,assign,readonly) BOOL isOldStyleSpecifiesType;
@property (nonatomic,strong,readonly) NSString *custumSetterName;
@property (nonatomic,strong,readonly) NSString *custumGetterName;
@end
