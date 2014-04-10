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

@protocol OSIgnoreSuperClass
@end

@protocol OSFullTextSearch
@end

@protocol OSTemporary
@end

@protocol OSIdenticalAttribute
@end

@protocol OSIgnoreAttribute
@end

@protocol OSWeakReferenceAttribute
@end

@protocol OSFetchOnRefreshingAttribute
@end

@protocol OSNotUpdateIfValueIsNullAttribute
@end

@protocol OSSerializableAttribute
@end

@protocol OSOnceUpdateAttribute
@end

@protocol OSModelInterface <NSObject>
@optional
+ (NSString*)OSTableName;
+ (NSString*)OSColumnName:(NSString*)attributeName;
+ (BOOL)attributeIsOSIdenticalAttribute:(NSString*)attributeName;
+ (BOOL)attributeIsOSIgnoreAttribute:(NSString*)attributeName;
+ (BOOL)attributeIsOSWeakReferenceAttribute:(NSString*)attributeName;
+ (BOOL)attributeIsOSFetchOnRefreshingAttribute:(NSString*)attributeName;
+ (BOOL)attributeIsOSNotUpdateIfValueIsNullAttribute:(NSString*)attributeName;
+ (BOOL)attributeIsOSSerializableAttribute:(NSString*)attributeName;
+ (BOOL)attributeIsOSOnceUpdateAttribute:(NSString*)attributeName;
- (void)OSModelDidLoad;
- (void)OSModelDidSave;
- (void)OSModelDidRemove;
@end

@interface NSObject (OSAttributeProtocol)
<OSIdenticalAttribute,OSIgnoreAttribute,OSSerializableAttribute,OSWeakReferenceAttribute,OSFetchOnRefreshingAttribute,OSNotUpdateIfValueIsNullAttribute,OSOnceUpdateAttribute>
@end
@implementation NSString (OSAttributeProtocol)
@end
