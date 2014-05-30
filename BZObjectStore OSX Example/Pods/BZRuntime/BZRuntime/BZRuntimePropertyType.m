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

#import "BZRuntimePropertyType.h"

@interface BZRuntimePropertyType () {
    NSString *_attributes;
}
@end

@implementation BZRuntimePropertyType

- (id)initWithAttributes:(NSString*)attributes
{
    if (self = [super init]) {
        _attributes = attributes;
        _isReadonly = NO;
        _isCopy = NO;
        _isRetain = NO;
        _isNonatomic = NO;
        _isDynamic = NO;
        _isWeakReference = NO;
        _isEligibleForGC = NO;
        _isCustomGetter = NO;
        _isCustomSetter = NO;
        _custumGetterName = @"";
        _custumSetterName = @"";
        NSArray *attributeList = [attributes componentsSeparatedByString:@","];
        for ( NSString *attribute in attributeList ) {
            if (attribute == [attributeList firstObject]) {
            } else if (attribute == [attributeList lastObject]) {
            } else {
                NSString *code = [attribute substringToIndex:1];
                if ( [@"R" isEqualToString:code] ) {
                    _isReadonly = YES;
                } else if ( [@"C" isEqualToString:code] ) {
                    _isCopy = YES;
                } else if ( [@"&" isEqualToString:code] ) {
                    _isRetain = YES;
                } else if ( [@"N" isEqualToString:code] ) {
                    _isNonatomic = YES;
                } else if ( [@"D" isEqualToString:code] ) {
                    _isDynamic = YES;
                } else if ( [@"W" isEqualToString:code] ) {
                    _isWeakReference = YES;
                } else if ( [@"P" isEqualToString:code] ) {
                    _isEligibleForGC = YES;
                } else if ( [@"G" isEqualToString:code] ) {
                    _isCustomGetter = YES;
                    _custumGetterName = [attribute substringFromIndex:1];
                } else if ( [@"S" isEqualToString:code] ) {
                    _isCustomSetter = YES;
                    _custumSetterName = [attribute substringFromIndex:1];
                }
            }
        }
    }
    return self;
}


@end
