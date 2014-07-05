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

#import "MANotebook.h"
#import "MANote.h"
#import "MAGarbageBox.h"
#import "MABookshelf.h"

@implementation MANotebook

- (instancetype)initWithBookshelf:(MABookshelf*)bookshelf
{
    if (self = [super init]) {
        self.objectId = nil;
        self.createdAt = [NSDate date];
        self.updatedAt = [NSDate date];
        self.updateSequence = 0;
        self.title = [NSString stringWithFormat:@"New notebook (%ld)",(long)bookshelf.notebooks.count + 1];
        self.notes = [NSMutableArray array];
        self.synchronized = NO;
        self.bookshelf = bookshelf;
    }
    return self;
}

- (MANote*)addNote
{
    MANote *note = [[MANote alloc]initWithNotebook:self];
    [self.notes insertObject:note atIndex:0];
    [self save];
    return note;
}

- (void)removeNote:(MANote*)note
{
    [self.notes removeObject:note];
    [self save];
}

- (BOOL)save
{
    self.updatedAt = [NSDate date];
    if (self.synchronized) {
        self.updateSequence = self.updateSequence + 1;
        self.synchronized = NO;
    }
    return [super save];
}

@end
