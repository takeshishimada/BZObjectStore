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

#import "MANoteViewController.h"
#import "MANoteEditViewController.h"
#import "MANote.h"
#import "MANotebook.h"
#import <GHMarkdownParser.h>
#import <BZObjectStoreNotificationCenter.h>
#import <BZObjectStoreNotificationObserver.h>

@interface MANoteViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) BZObjectStoreNotificationObserver *observer;
@end

@implementation MANoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Delete"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(deleteNote:)];
    
    deleteButton.enabled = NO;
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editNote:)];
    editButton.enabled = NO;

    self.navigationItem.rightBarButtonItems = @[editButton,deleteButton];

    [self show];
}

- (void)show
{
    if (self.note) {
        
        self.observer = [BZObjectStoreNotificationCenter observerForObject:self.note target:self completionBlock:^(MANoteViewController *weakSelf, MANote *note) {
            
            if (note) {
                // saved
                weakSelf.title = note.title;
                for (UIBarButtonItem *item in weakSelf.navigationItem.rightBarButtonItems) {
                    item.enabled = YES;
                }
                
                GHMarkdownParser *parser = [[GHMarkdownParser alloc] init];
                parser.options = kGHMarkdownAutoLink;
                parser.githubFlavored = YES;
                NSString *html = [parser HTMLStringFromMarkdownString:note.contentAsMarkdown];
                
                weakSelf.webView.scalesPageToFit = YES;
                [weakSelf.webView loadData:[html dataUsingEncoding:NSUTF8StringEncoding] MIMEType:@"text/html"textEncodingName:@"utf-8"baseURL:nil];
                
            } else {
                // removed
                weakSelf.title = @"note";
                for (UIBarButtonItem *item in weakSelf.navigationItem.rightBarButtonItems) {
                    item.enabled = NO;
                }
                [weakSelf.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }

            }

        } immediately:YES];
        
        
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

#pragma mark segue

- (void)editNote:(id)sender
{
    if (self.note) {
        [self performSegueWithIdentifier:NSStringFromClass([MANoteEditViewController class]) sender:self];
    }
}

- (void)deleteNote:(id)sender
{
    [self.notebook removeNote:self.note];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:NSStringFromClass([MANoteEditViewController class])]) {
        UINavigationController *nv = [segue destinationViewController];
        MANoteEditViewController *vc = (MANoteEditViewController*)nv.topViewController;
        vc.note = self.note;
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"Notebooks";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
