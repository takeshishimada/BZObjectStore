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

#import "MANoteTableViewCell.h"
#import "MANote.h"

@implementation MANoteTableViewCell

+ (UINib*)nib
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    return nib;
}

- (void)showNote:(MANote*)note
{
    [note addOSObserver:self selector:@selector(savedNote:latest:) notificationType:BZObjectStoreNotificationTypeSaved];
    [note addOSObserver:self selector:@selector(deletedNote:) notificationType:BZObjectStoreNotificationTypeDeleted];
    
    [self savedNote:nil latest:note];
}

- (void)savedNote:(MANote*)current latest:(MANote*)latest
{
    self.titleLabel.text = latest.title;
    self.lastUpdatedTimeLabel.text = [self ISO8601FormatString:latest.updatedAt];
}

- (void)deletedNote:(MANote*)current
{
    self.titleLabel.text = @"";
    self.lastUpdatedTimeLabel.text = @"";
}

- (NSString*)ISO8601FormatString:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSZZZ"];
    NSString *string = [formatter stringFromDate:date];
    return string;
}

@end
