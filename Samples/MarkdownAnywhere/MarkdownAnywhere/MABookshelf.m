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

#import "MABookshelf.h"
#import "MAGarbageBox.h"
#import "MABookshelf.h"
#import "MANotebook.h"
#import "MANote.h"
#import <NSObject+ActiveRecord.h>

@implementation MABookshelf

+ (instancetype)bookshelf
{
    static id _bookshelf = nil;
    if (!_bookshelf) {
        NSArray *bookshelfs = [self fetch:nil];
        if (bookshelfs.firstObject) {
            _bookshelf = bookshelfs.firstObject;
        } else {
            _bookshelf = [[self alloc]init];
        }
    }
    return _bookshelf;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.notebooks = [NSMutableArray array];
    }
    return self;
}

- (MANotebook*)addNotebook
{
    MANotebook *notebook = [[MANotebook alloc]initWithBookshelf:self];
    [self.notebooks insertObject:notebook atIndex:0];
    [self save];
    return notebook;
}

- (void)removeNotebook:(MANotebook*)notebook
{
    [self.notebooks removeObject:notebook];
    [self save];
}

@end
