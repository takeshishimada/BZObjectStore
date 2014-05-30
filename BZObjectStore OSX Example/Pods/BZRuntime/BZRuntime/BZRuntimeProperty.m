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

#import "BZRuntimeProperty.h"

@implementation BZRuntimeProperty

- (id)initWithName:(NSString*)name attributes:(NSString*)attributes
{
    if (self = [super init]) {
        _name = name;
        _attributes = attributes;
        _propertyType = [[BZRuntimePropertyType alloc]initWithAttributes:attributes];
        _propertyEncoding = [[BZRuntimePropertyEncoding alloc]initWithAttributes:attributes];
        _clazz = [self classWithAttributes:attributes];
        _structureName = [self structureNameWithAttributes:attributes];
    }
    return self;
}

- (NSString*)structureNameWithAttributes:(NSString*)attributes
{
    NSString *structureName = nil;
    if (_propertyEncoding.isStructure) {
        NSArray *attributeList = [attributes componentsSeparatedByString:@","];
        NSString *firstAttribute = [attributeList firstObject];
        if (firstAttribute.length > 3) {
            NSString *name = [firstAttribute substringWithRange:NSMakeRange(2, firstAttribute.length - 3)];
            NSArray *names = [name componentsSeparatedByString:@"="];
            structureName = names.firstObject;
        }
    }
    return structureName;
}

- (Class)classWithAttributes:(NSString*)attributes
{
    Class clazz = Nil;
    if (_propertyEncoding.isObject) {
        NSArray *attributeList = [attributes componentsSeparatedByString:@","];
        NSString *firstAttribute = [attributeList firstObject];
        if (firstAttribute.length > 3) {
            NSString *className = [firstAttribute substringWithRange:NSMakeRange(3, firstAttribute.length - 4)];
            NSArray *names = [className componentsSeparatedByString:@"<"];
            clazz = NSClassFromString(names.firstObject);
        }
    }
    return clazz;
}

@end
