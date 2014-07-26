//
// The MIT License (MIT)
//
// Copyright (c) 2014 MarkdownAnywhere
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

#import "MAJSONModel.h"
#import <BZObjectStoreModelInterface.h>

@class MAShelfModel;
@class MANotebook;
@class MANote;

@protocol MANote
@end

@interface MANote : MAJSONModel<OSIgnoreSuperClass,OSNotification,OSUpdatePerformance>
- (instancetype)initWithNotebook:(MANotebook*)notebook;
- (instancetype)initWithNotebook:(MANotebook*)notebook dictionary:(NSDictionary*)dictionary error:(NSError**)error;
+ (NSMutableArray*)arrayOfDictionariesFromModels:(NSArray*)array notebook:(MANotebook*)notebook error:(NSError**)error;
@property (nonatomic,strong) NSNumber<OSIdenticalAttribute> *objectId;
@property (nonatomic,strong) NSDate<OSOnceUpdateAttribute> *createdAt;
@property (nonatomic,strong) NSDate *updatedAt;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *contentAsMarkdown;
@property (nonatomic,assign) BOOL synchronized;
@property (nonatomic,weak) MANotebook<Ignore> *notebook;
- (BOOL)save;
- (BOOL)save:(BOOL)synchronized;
@end

