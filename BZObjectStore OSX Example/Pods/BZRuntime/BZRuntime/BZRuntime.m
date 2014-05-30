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

#import "BZRuntime.h"
#import <objc/runtime.h>

@implementation BZRuntime

+(BZRuntime*)runtimeWithClass:(Class)clazz
{
    return [self runtimeWithClass:clazz superClazz:[NSObject class] enumratePropertyOfSuperClass:NO];
}

+(BZRuntime*)runtimeSuperClassWithClass:(Class)clazz
{
    return [self runtimeWithClass:clazz superClazz:[NSObject class] enumratePropertyOfSuperClass:YES];
}

+(BZRuntime*)runtimeWithClass:(Class)clazz superClazz:(Class)superClazz
{
    return [self runtimeWithClass:clazz superClazz:superClazz enumratePropertyOfSuperClass:NO];
}

+(BZRuntime*)runtimeSuperClassWithClass:(Class)clazz superClazz:(Class)superClazz
{
    return [self runtimeWithClass:clazz superClazz:superClazz enumratePropertyOfSuperClass:YES];
}

+(BZRuntime*)runtimeWithClass:(Class)clazz superClazz:(Class)superClazz enumratePropertyOfSuperClass:(BOOL)enumratePropertyOfSuperClass
{
    return [[BZRuntime alloc]initWithClass:clazz superClazz:superClazz enumratePropertyOfSuperClass:enumratePropertyOfSuperClass];
}

- (id)initWithClass:(Class)clazz superClazz:(Class)superClazz enumratePropertyOfSuperClass:(BOOL)enumratePropertyOfSuperClass
{
    if ( self = [super init]) {
        _clazz = clazz;
        _propertyList = [self propertyListWithClass:clazz propertyList:nil superClazz:superClazz enumratePropertyOfSuperClass:enumratePropertyOfSuperClass];
    }
    return self;
}


- (NSArray*)propertyListWithClass:(Class)clazz propertyList:(NSMutableArray*)propertyList superClazz:(Class)superClazz enumratePropertyOfSuperClass:(BOOL)enumratePropertyOfSuperClass
{
    if (!clazz) {
        return [NSArray arrayWithArray:propertyList];
    }
    NSString *clazzName = NSStringFromClass(clazz);
    NSString *superClazzName = NSStringFromClass(superClazz);
    if ([clazzName isEqualToString:superClazzName]) {
        return [NSArray arrayWithArray:propertyList];
    }
    
    NSMutableArray *list = [NSMutableArray array];
    NSString *className = NSStringFromClass(clazz);
    id class = objc_getClass([className UTF8String]);
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        NSString *attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        BZRuntimeProperty *runtimeProperty = [[BZRuntimeProperty alloc]initWithName:[name copy] attributes:[attributes copy]];
        [list addObject:runtimeProperty];
    }
    free(properties);
    if (list.count > 0) {
        if (!propertyList) {
            propertyList = [NSMutableArray array];
        }
        [propertyList addObjectsFromArray:list];
    }
    if (enumratePropertyOfSuperClass) {
        clazz = [clazz superclass];
        return [self propertyListWithClass:clazz propertyList:propertyList superClazz:superClazz enumratePropertyOfSuperClass:enumratePropertyOfSuperClass];
    } else {
        return [NSArray arrayWithArray:propertyList];
    }
}



@end
