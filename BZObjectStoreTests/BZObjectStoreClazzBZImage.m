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

#import "BZObjectStoreClazzBZImage.h"
#import <FMResultSet.h>
#import "BZObjectStoreConst.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreSQLiteColumnModel.h"
#import "BZImage.h"

@implementation BZObjectStoreClazzBZImage


- (Class)superClazz
{
    return [BZImage class];
}
- (NSString*)attributeType
{
    return NSStringFromClass([self superClazz]);
}
- (BOOL)isSimpleValueClazz
{
    return YES;
}

- (NSArray*)sqliteColumnsWithAttribute:(BZObjectStoreRuntimeProperty *)attribute
{
    BZObjectStoreSQLiteColumnModel *url = [[BZObjectStoreSQLiteColumnModel alloc]init];
    url.columnName = [NSString stringWithFormat:@"%@_url",attribute.columnName];
    url.dataTypeName = SQLITE_DATA_TYPE_TEXT;
    
    BZObjectStoreSQLiteColumnModel *gif = [[BZObjectStoreSQLiteColumnModel alloc]init];
    gif.columnName = [NSString stringWithFormat:@"%@_gif",attribute.columnName];
    gif.dataTypeName = SQLITE_DATA_TYPE_BLOB;
    
    return @[url,gif];
}

- (NSArray*)storeValuesWithValue:(BZImage*)value attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    if ([[value class] isSubclassOfClass:[BZImage class]]) {
        NSObject *url = value.url;
        NSObject *gif = value.gif;
        if (!url) {
            url = [NSNull null];
        }
        if (!gif) {
            gif = [NSNull null];
        }
        return @[url,gif];
    }
    return @[[NSNull null],[NSNull null]];
}

- (id)valueWithResultSet:(FMResultSet*)resultSet attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *urlColumnName = [NSString stringWithFormat:@"%@_url",attribute.columnName];
    NSString *gifColumnName = [NSString stringWithFormat:@"%@_gif",attribute.columnName];
    BZImage *image = [[BZImage alloc]init];
    image.url = [resultSet stringForColumn:urlColumnName];
    image.gif = [resultSet dataForColumn:gifColumnName];
    return image;
}


@end
