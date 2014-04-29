//
// The MIT License (MIT)
//
// Copyright (c) 2014 BONZOO.LLC
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

#import "BZObjectStoreOnDisk.h"
#import "FMDatabase.h"

@implementation BZObjectStoreOnDisk
+ (instancetype)sharedInstance
{
    static id _sharedInstance;
    @synchronized(self) {
        if (!_sharedInstance) {
            NSError *error = nil;
            NSString *deletePath = [self databasePath:@"database.sqlite"];
            NSFileManager *manager = [NSFileManager defaultManager];
            if ([manager fileExistsAtPath:deletePath]) {
                [manager removeItemAtPath:deletePath error:&error];
                if (error) {
                    NSLog(@"%@",error);
                }
            }
            NSString *path = @"database.sqlite";
            _sharedInstance = [self openWithPath:path error:&error];
            NSAssert(error == nil,@"objectstore is nil");
        }
        return _sharedInstance;
    }
}

+ (NSString*)databasePath:(NSString*)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
    dir = [dir stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
    path = [dir stringByAppendingPathComponent:path];
    return path;
}

+ (NSString*)ignorePrefixName
{
    return @"BZ";
}

+ (NSString*)ignoreSuffixName
{
    return @"Model";
}

- (void)transactionDidBegin:(FMDatabase *)db
{
//    [db setTraceExecution:YES];
}

- (void)transactionDidEnd:(FMDatabase *)db
{
}

@end
