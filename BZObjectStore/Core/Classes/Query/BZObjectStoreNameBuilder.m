//
// The MIT License (MIT)
//
// Copyright (c) 2014 BZObjectStore
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

#import "BZObjectStoreNameBuilder.h"

@implementation BZObjectStoreNameBuilder

- (NSString*)tableName:(Class)clazz
{
    NSString *tableName = nil;
    if ([clazz conformsToProtocol:@protocol(OSModelInterface)]) {
        if ([clazz respondsToSelector:@selector(OSTableName)]) {
            tableName = (NSString*)[clazz performSelector:@selector(OSTableName) withObject:nil];
        }
    }
    if (!tableName || [tableName isEqualToString:@""]) {
        tableName = NSStringFromClass(clazz);
        NSString *ignorePrefixName = self.ignorePrefixName;
        if (ignorePrefixName) {
            if ([tableName hasPrefix:ignorePrefixName]) {
                tableName = [tableName substringFromIndex:ignorePrefixName.length];
            }
        }
        NSString *ignoreSuffixName = self.ignoreSuffixName;
        if (ignoreSuffixName) {
            if ([tableName hasSuffix:ignoreSuffixName]) {
                tableName = [tableName substringToIndex:tableName.length - ignoreSuffixName.length];
            }
        }
    }
    return tableName;
}

- (NSString*)columnName:(NSString*)name clazz:(Class)clazz
{
    NSString *columnName = name;
    if ([clazz conformsToProtocol:@protocol(OSModelInterface)]) {
        if ([clazz respondsToSelector:@selector(OSColumnName:)]) {
            columnName = (NSString*)[clazz performSelector:@selector(OSColumnName:) withObject:name];
        }
    }
    return columnName;
}

@end
