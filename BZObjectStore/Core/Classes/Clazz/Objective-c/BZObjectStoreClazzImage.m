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

#import "BZObjectStoreClazzImage.h"
#import <FMResultSet.h>
#import "BZObjectStoreConst.h"
#import "BZObjectStoreRuntimeProperty.h"

@implementation BZObjectStoreClazzImage

#if TARGET_OS_IPHONE

- (Class)superClazz
{
    return [UIImage class];
}
- (NSArray*)storeValuesWithValue:(UIImage*)value attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    if (value) {
        return @[[NSData dataWithData:UIImagePNGRepresentation(value)]];
    }
    return @[[NSNull null]];
}

- (id)valueWithResultSet:(FMResultSet*)resultSet attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    NSData *data = [resultSet dataForColumn:attribute.columnName];
    if (data) {
        return [[UIImage alloc] initWithData:data];
    }
    return nil;
}

#elif TARGET_OS_MAC && !TARGET_OS_IPHONE

- (Class)superClazz
{
    return [NSImage class];
}

- (NSArray*)storeValuesWithValue:(NSImage*)value attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    if (value) {
        return @[[NSData dataWithData:[self PNGDataWithImage:value]]];
    }
    return @[[NSNull null]];
}

- (id)valueWithResultSet:(FMResultSet*)resultSet attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    NSData *data = [resultSet dataForColumn:attribute.columnName];
    if (data) {
        return [[NSImage alloc] initWithData:data];
    }
    return nil;
}

- (NSData*)PNGDataWithImage:(NSImage *)image
{
    CGImageRef cgRef = [image CGImageForProposedRect:NULL
                                             context:nil
                                               hints:nil];
    NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
    [newRep setSize:[image size]];
    NSData *pngData = [newRep representationUsingType:NSPNGFileType properties:nil];
    return pngData;
}

#endif

- (BOOL)isSimpleValueClazz
{
    return YES;
}

- (NSString*)sqliteDataTypeName
{
    return SQLITE_DATA_TYPE_BLOB;
}

@end
