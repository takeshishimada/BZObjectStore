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

#import "BZRuntimePropertyEncoding.h"

@interface BZRuntimePropertyEncoding () {
    NSString *_attributes;
}
@end

@implementation BZRuntimePropertyEncoding

- (id)initWithAttributes:(NSString*)attributes {
    if ( self = [super init]) {
        NSArray *attributeList = [attributes componentsSeparatedByString:@","];
        NSString *firstAttribute = [attributeList firstObject];
        _code = [firstAttribute substringWithRange:NSMakeRange(1, 1)];
        _attributes = attributes;
        _isChar = NO;
        _isInt = NO;
        _isShort = NO;
        _isLong = NO;
        _isLongLong = NO;
        _isUnsignedChar = NO;
        _isUnsignedInt = NO;
        _isUnsignedShort = NO;
        _isUnsignedLong = NO;
        _isUnsignedLongLong = NO;
        _isFloat = NO;
        _isDouble = NO;
        _isBool = NO;
        _isVoid = NO;
        _isCharString = NO;
        _isObject = NO;
        _isClass = NO;
        _isMethodSelector = NO;
        _isArray = NO;
        _isStructure = NO;
        _isUnion = NO;
        _isBit = NO;
        _isPointer = NO;
        _isUnknown = NO;
        _isConst = NO;
        _isIn = NO;
        _isInOut = NO;
        _isOut = NO;
        _isByCopy = NO;
        _isByRef = NO;
        _isOneway = NO;
        
        // data type
        if ([_code isEqualToString:@"c"]) _isChar = YES;
        else if ([_code isEqualToString:@"i"]) _isInt = YES;
        else if ([_code isEqualToString:@"s"]) _isShort = YES;
        else if ([_code isEqualToString:@"l"]) _isLong = YES;
        else if ([_code isEqualToString:@"q"]) _isLongLong = YES;
        else if ([_code isEqualToString:@"C"]) _isUnsignedChar = YES;
        else if ([_code isEqualToString:@"I"]) _isUnsignedInt = YES;
        else if ([_code isEqualToString:@"S"]) _isUnsignedShort = YES;
        else if ([_code isEqualToString:@"L"]) _isUnsignedLong = YES;
        else if ([_code isEqualToString:@"Q"]) _isUnsignedLongLong = YES;
        else if ([_code isEqualToString:@"f"]) _isFloat = YES;
        else if ([_code isEqualToString:@"d"]) _isDouble = YES;
        else if ([_code isEqualToString:@"B"]) _isBool = YES;
        else if ([_code isEqualToString:@"v"]) _isVoid = YES;
        else if ([_code isEqualToString:@"*"]) _isCharString = YES;
        else if ([_code isEqualToString:@"@"]) _isObject = YES;
        else if ([_code isEqualToString:@"#"]) _isClass = YES;
        else if ([_code isEqualToString:@":"]) _isMethodSelector = YES;
        else if ([_code isEqualToString:@"["]) _isArray = YES;
        else if ([_code isEqualToString:@"{"]) _isStructure = YES;
        else if ([_code isEqualToString:@"("]) _isUnion = YES;
        else if ([_code isEqualToString:@"b"]) _isBit = YES;
        else if ([_code isEqualToString:@"^"]) _isPointer = YES;
        else if ([_code isEqualToString:@"?"]) _isUnknown = YES;
        else if ([_code isEqualToString:@"r"]) _isConst = YES;
        else if ([_code isEqualToString:@"n"]) _isIn = YES;
        else if ([_code isEqualToString:@"N"]) _isInOut = YES;
        else if ([_code isEqualToString:@"o"]) _isOut = YES;
        else if ([_code isEqualToString:@"O"]) _isByCopy = YES;
        else if ([_code isEqualToString:@"R"]) _isByRef = YES;
        else if ([_code isEqualToString:@"V"]) _isOneway = YES;

    }
    return self;
}

@end
