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

#import "BZObjectStoreClazzPFUser.h"
#import <FMDB/FMResultSet.h>
#import "BZObjectStoreConst.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreModelInterface.h"
#import <Parse/Parse.h>
#import "BZRuntime.h"

@interface BZObjectStoreClazzPFUserRequiredAttributesModel : NSObject
@property (nonatomic, strong) NSString<OSModelInterface> *objectId;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *sessionToken;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) PFACL<OSSerializableAttribute> *ACL;
@end
@implementation BZObjectStoreClazzPFUserRequiredAttributesModel
@end

@implementation BZObjectStoreClazzPFUser

- (NSEnumerator*)objectEnumeratorWithObject:(NSArray*)object
{
    NSArray *array = @[object];
    return [array objectEnumerator];
}
- (NSArray*)keysWithObject:(id)object
{
    return nil;
}

- (id)objectWithClazz:(Class)clazz
{
    return [PFUser user];
}

- (Class)superClazz
{
    return [PFUser class];
}
- (NSString*)attributeType
{
    return NSStringFromClass([self superClazz]);
}
- (BOOL)isObjectClazz
{
    return YES;
}
- (BOOL)isRelationshipClazz
{
    return YES;
}
- (BOOL)isSubClazz:(Class)clazz
{
    NSString *parseClassName = NSStringFromClass([PFUser class]);
    while (true) {
        NSString *className = NSStringFromClass(clazz);
        if ([parseClassName isEqualToString:className]) {
            return YES;
        }
        clazz = [clazz superclass];
        if (!clazz) {
            break;
        }
    }
    return NO;
}

- (NSArray*)requiredPropertyList
{
    BZRuntime *runtime = [BZRuntime runtimeWithClass:[BZObjectStoreClazzPFUserRequiredAttributesModel class]];
    return runtime.propertyList;
}

- (NSArray*)storeValuesWithValue:(NSObject*)value attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    if (value) {
        return @[[NSNumber numberWithUnsignedInteger:1]];
    }
    return @[[NSNumber numberWithUnsignedInteger:0]];
}

- (NSString*)sqliteDataTypeName
{
    return SQLITE_DATA_TYPE_INTEGER;
}

@end
