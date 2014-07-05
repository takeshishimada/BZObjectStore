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

#import <Foundation/Foundation.h>

@protocol OSNotification
@end

@protocol OSCascadeNotification
@end

@protocol OSIgnoreSuperClass
@end

@protocol OSFullTextSearch3
@end

@protocol OSFullTextSearch4
@end

@protocol OSInsertPerformance
@end

@protocol OSUpdatePerformance
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

@class BZObjectStore;

@protocol OSModelInterface <NSObject>
@optional
+ (NSString*)OSTableName;
+ (NSString*)OSColumnName:(NSString*)attributeName;
- (void)OSModelDidLoad;
- (void)OSModelDidSave;
- (void)OSModelDidDelete;
+ (BOOL)attributeIsOSIdenticalAttribute:(NSString*)attributeName;
+ (BOOL)attributeIsOSIgnoreAttribute:(NSString*)attributeName;
+ (BOOL)attributeIsOSWeakReferenceAttribute:(NSString*)attributeName;
+ (BOOL)attributeIsOSFetchOnRefreshingAttribute:(NSString*)attributeName;
+ (BOOL)attributeIsOSNotUpdateIfValueIsNullAttribute:(NSString*)attributeName;
+ (BOOL)attributeIsOSSerializableAttribute:(NSString*)attributeName;
+ (BOOL)attributeIsOSOnceUpdateAttribute:(NSString*)attributeName;
@end

@interface NSObject (OSAttributeProtocol)
<OSCascadeNotification,OSNotification,OSIgnoreSuperClass,OSFullTextSearch3,OSFullTextSearch4,OSInsertPerformance,OSUpdatePerformance,OSIdenticalAttribute,OSIgnoreAttribute,OSWeakReferenceAttribute,OSFetchOnRefreshingAttribute,OSNotUpdateIfValueIsNullAttribute,OSSerializableAttribute,OSOnceUpdateAttribute
>
@end
@implementation NSString (OSAttributeProtocol)
@end
