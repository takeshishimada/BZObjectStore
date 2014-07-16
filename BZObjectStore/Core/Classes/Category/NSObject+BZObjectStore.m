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

#import "NSObject+BZObjectStore.h"
#import <objc/runtime.h>
#import "BZObjectStoreRuntime.h"

@implementation NSObject (BZObjectStore)

-(NSNumber*)rowid {
    return objc_getAssociatedObject(self, @selector(setRowid:));
}

-(void)setRowid:(NSNumber *)rowid
{
    objc_setAssociatedObject(self, _cmd, rowid, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BZObjectStoreRuntime*)OSRuntime {
    return objc_getAssociatedObject(self, @selector(setOSRuntime:));
}

-(void)setOSRuntime:(BZObjectStoreRuntime *)runtime
{
    objc_setAssociatedObject(self, _cmd, runtime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)OSHashForSave
{
    NSNumber *number = [NSNumber numberWithUnsignedInteger:[self hash]];
    NSString *hash = [NSString stringWithFormat:@"%@",[number stringValue]];
    return hash;
}

- (NSString*)OSHashForFetch
{
    NSString *hash = [NSString stringWithFormat:@"%@-%@",NSStringFromClass([self class]),[self.rowid stringValue]];
    return hash;
}

- (BOOL)isEqualToOSObject:(NSObject*)object
{
    if (self == object) {
        return YES;
    } else if ([self class] == [object class]) {
        if (self.rowid && object.rowid) {
            if ([self.rowid isEqualToNumber:object.rowid]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
