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

#import "MANote.h"
#import "MANotebook.h"
#import <NSObject+ActiveRecord.h>

@implementation MANote

- (instancetype)initWithNotebook:(MANotebook*)notebook
{
    if (self = [super init]) {
        self.objectId = nil;
        self.createdAt = [NSDate date];
        self.updatedAt = [NSDate date];
        self.updateSequence = 0;
        self.title = [NSString stringWithFormat:@"New note (%ld)",(long)notebook.notes.count + 1];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"md"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        self.contentAsMarkdown = [[NSString alloc] initWithData:data
                                         encoding:NSShiftJISStringEncoding];
        self.notebook = notebook;
        self.synchronized = NO;
    }
    return self;
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
