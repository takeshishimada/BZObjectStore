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

#import "BZObjectStoreClazzNSValue.h"
#import <FMResultSet.h>
#import "BZObjectStoreConst.h"
#import "BZObjectStoreRuntimeProperty.h"

@interface NSValueConverter : NSObject <NSCoding>
+ (NSData*)convertedDataWithValue:(NSValue*)value;
+ (NSValue*)valueWithConvertedData:(NSData*)convertedData;
@end

@interface NSValueConverter ()
@property (nonatomic,strong) NSString *objCType;
@property (nonatomic,strong) NSData *data;
@end

@implementation NSValueConverter
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _objCType = [aDecoder decodeObjectForKey:@"objCType"];
        _data = [aDecoder decodeObjectForKey:@"data"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_objCType forKey:@"objCType"];
    [aCoder encodeObject:_data forKey:@"data"];
}

+ (NSData*)convertedDataWithValue:(NSValue*)value
{
    NSValueConverter *holder = [[self alloc]initWithValue:value];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:holder];
    return data;
}
+ (NSValue*)valueWithConvertedData:(NSData*)convertedData
{
    NSValueConverter *holder = [NSKeyedUnarchiver unarchiveObjectWithData:convertedData];
    const char *objCType = [holder.objCType cStringUsingEncoding:NSUTF8StringEncoding];
    return [NSValue valueWithBytes:[holder.data bytes] objCType:objCType];
}

- (instancetype)initWithValue:(NSValue*)value
{
    if (self = [super init]) {
        _objCType = [self _objCTypeWithValue:value];
        _data = [self _dataWithValue:value];
    }
    return self;
}
- (NSData*)_dataWithValue:(NSValue*)value
{
    NSUInteger size;
    const char* encoding = [value objCType];
    NSGetSizeAndAlignment(encoding, &size, NULL);
    void* ptr = malloc(size);
    [value getValue:ptr];
    NSData* data = [NSData dataWithBytes:ptr length:size];
    free(ptr);
    return data;
}
- (NSString*)_objCTypeWithValue:(NSValue*)value
{
    const char *objCType = [value objCType];
    return [NSString stringWithCString:objCType encoding:NSUTF8StringEncoding];
}
@end

@implementation BZObjectStoreClazzNSValue

- (Class)superClazz
{
    return [NSValue class];
}
- (NSString*)attributeType
{
    return NSStringFromClass([self superClazz]);
}
- (BOOL)isSimpleValueClazz
{
    return YES;
}

- (NSArray*)storeValuesWithValue:(NSValue*)value attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    if (value) {
        return @[[NSValueConverter convertedDataWithValue:value]];
    }
    return @[[NSNull null]];
}

- (id)valueWithResultSet:(FMResultSet*)resultSet attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    NSData *value = [resultSet objectForColumnName:attribute.columnName];
    if (value && [[value class] isSubclassOfClass:[NSData class]]) {
        return [NSValueConverter valueWithConvertedData:value];
    }
    return nil;
}

- (NSString*)sqliteDataTypeName
{
    return SQLITE_DATA_TYPE_BLOB;
}

@end
