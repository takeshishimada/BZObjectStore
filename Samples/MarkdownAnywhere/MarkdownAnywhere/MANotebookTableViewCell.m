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

#import "MANotebookTableViewCell.h"
#import "MANotebook.h"

@interface MANotebookTableViewCell ()
@property (nonatomic,strong) BZObjectStoreNotificationObserver *observer;
@end

@implementation MANotebookTableViewCell

+ (UINib*)nib
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    return nib;
}

- (void)showNotebook:(MANotebook*)notebook
{
    self.observer = [notebook observerWithTarget:self completionBlock:^(MANotebookTableViewCell *weakSelf,MANotebook  *notebook) {
        if (notebook) {
            weakSelf.titleLabel.text = notebook.title;
            weakSelf.lastUpdatedTimeLabel.text = [notebook.updatedAt description];
//        } else {
//            weakSelf.titleLabel.text = @"";
//            weakSelf.lastUpdatedTimeLabel.text = @"";
        }
    } immediately:YES];
}

@end

