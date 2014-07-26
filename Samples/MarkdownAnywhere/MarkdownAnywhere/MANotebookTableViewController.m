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

#import "MANotebookTableViewController.h"
#import "MANoteTableViewController.h"
#import "MANotebookTableViewCell.h"

@interface MANotebookTableViewController()
@property (nonatomic,assign) BOOL stopObserving;
@end

@implementation MANotebookTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerNib:[MANotebookTableViewCell nib] forCellReuseIdentifier:NSStringFromClass([MANotebookTableViewCell class])];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    self.navigationItem.rightBarButtonItems = @[addButton];
    
    [self.bookshelf addOSObserver:self selector:@selector(savedBookshelf:latest:) notificationType:BZObjectStoreNotificationTypeSaved];
    
}

- (void)savedBookshelf:(MABookshelf*)current latest:(MABookshelf*)latest
{
    if (self.stopObserving) {
        return;
    }
    [self.tableView reloadData];
}

- (void)add:(id)sender
{
    self.stopObserving = YES;
    [self.bookshelf addNotebook];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.stopObserving = NO;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bookshelf.notebooks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MANotebookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MANotebookTableViewCell class]) forIndexPath:indexPath];

    MANotebook *notebook = self.bookshelf.notebooks[indexPath.row];
    [cell showNotebook:notebook];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.stopObserving = YES;
        MANotebook *notebook = self.bookshelf.notebooks[indexPath.row];
        [self.bookshelf removeNotebook:notebook];
        [self.garbageBox addNotebook:notebook];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        self.stopObserving = NO;
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:NSStringFromClass([MANoteTableViewController class]) sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:NSStringFromClass([MANoteTableViewController class])]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MANotebook *notebook = self.bookshelf.notebooks[indexPath.row];
        MANoteTableViewController *vc = [segue destinationViewController];
        vc.notebook = notebook;
    }
}

@end
