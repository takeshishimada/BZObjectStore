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

#import "BZObjectStoreOnDisk.h"

@implementation BZObjectStoreOnDisk
+ (instancetype)sharedInstance
{
    static id _sharedInstance;
    @synchronized(self) {
        if (!_sharedInstance) {
            NSString *path = [self path];
            NSError *error = nil;
            [self deleteFile:path error:&error];
            NSAssert(error == nil,@"cannot delete file");
            _sharedInstance = [BZObjectStore openWithPath:path error:&error];
            NSAssert(error == nil,@"objectstore is nil");
            NSLog(@"%@",path);
        }
        return _sharedInstance;
    }
}

+ (NSString *)path {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
    dir = [dir stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
    dir = [dir stringByAppendingPathComponent:@"Databases"];
    NSString *path = [dir stringByAppendingPathComponent:@"database.sqlite"];
    return path;
}

+ (void)deleteFile:(NSString*)path error:(NSError**)error
{
    if (!path) {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:error];
    }
    BOOL isdir = YES;
    NSString *dir = [path stringByDeletingLastPathComponent];
    if (![fileManager fileExistsAtPath:dir isDirectory:&isdir]) {
        [fileManager createDirectoryAtPath:dir
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:NULL];    }
    
}

@end
