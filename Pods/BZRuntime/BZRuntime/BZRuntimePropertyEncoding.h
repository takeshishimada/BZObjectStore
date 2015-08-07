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

// https://developer.apple.com/library/ios/documentation/cocoa/conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1

@interface BZRuntimePropertyEncoding : NSObject
- (id)initWithAttributes:(NSString*)attributes;
@property (nonatomic,strong,readonly) NSString *code;
// Objective-C type encodings
@property (nonatomic,assign,readonly) BOOL isChar;
@property (nonatomic,assign,readonly) BOOL isInt;
@property (nonatomic,assign,readonly) BOOL isShort;
@property (nonatomic,assign,readonly) BOOL isLong;
@property (nonatomic,assign,readonly) BOOL isLongLong;
@property (nonatomic,assign,readonly) BOOL isUnsignedChar;
@property (nonatomic,assign,readonly) BOOL isUnsignedInt;
@property (nonatomic,assign,readonly) BOOL isUnsignedShort;
@property (nonatomic,assign,readonly) BOOL isUnsignedLong;
@property (nonatomic,assign,readonly) BOOL isUnsignedLongLong;
@property (nonatomic,assign,readonly) BOOL isFloat;
@property (nonatomic,assign,readonly) BOOL isDouble;
@property (nonatomic,assign,readonly) BOOL isBool;
@property (nonatomic,assign,readonly) BOOL isVoid;
@property (nonatomic,assign,readonly) BOOL isCharString;
@property (nonatomic,assign,readonly) BOOL isObject;
@property (nonatomic,assign,readonly) BOOL isClass;
@property (nonatomic,assign,readonly) BOOL isMethodSelector;
@property (nonatomic,assign,readonly) BOOL isArray;
@property (nonatomic,assign,readonly) BOOL isStructure;
@property (nonatomic,assign,readonly) BOOL isUnion;
@property (nonatomic,assign,readonly) BOOL isBit;
@property (nonatomic,assign,readonly) BOOL isPointer;
@property (nonatomic,assign,readonly) BOOL isUnknown;
// Objective-C method encodings
@property (nonatomic,assign,readonly) BOOL isConst;
@property (nonatomic,assign,readonly) BOOL isIn;
@property (nonatomic,assign,readonly) BOOL isInOut;
@property (nonatomic,assign,readonly) BOOL isOut;
@property (nonatomic,assign,readonly) BOOL isByCopy;
@property (nonatomic,assign,readonly) BOOL isByRef;
@property (nonatomic,assign,readonly) BOOL isOneway;

@end
