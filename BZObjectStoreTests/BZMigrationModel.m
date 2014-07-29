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

#import "BZMigrationModel.h"

@implementation BZMigrationModel

static BOOL ignoreDetails1;
static BOOL ignoreWillRemovedObjectId2;
static BOOL ignoreWillAddedObjectId3;
static BOOL tableNameChange;
static BOOL columnNameChange;

+ (void)setIgnoreDetails1:(BOOL)value
{
    ignoreDetails1 = value;
}

+ (void)setIgnoreWillRemovedObjectId2:(BOOL)value
{
    ignoreWillRemovedObjectId2 = value;
}

+ (void)setWillAddedObjectId3:(BOOL)value
{
    ignoreWillAddedObjectId3 = value;
}

+ (void)setTableNameChange:(BOOL)value
{
    tableNameChange = value;
}

+ (void)setColumnNameChange:(BOOL)value
{
    columnNameChange = value;
}

+ (BOOL)attributeIsOSIgnoreAttribute:(NSString *)attributeName
{
    if ([attributeName isEqualToString:@"willRemovedObjectId2"] && ignoreWillRemovedObjectId2) {
        return YES;
    } else if ([attributeName isEqualToString:@"willAddedObjectId3"] && ignoreWillAddedObjectId3) {
        return YES;
    } else if ([attributeName isEqualToString:@"details1"] && ignoreDetails1) {
        return YES;
    }
    return NO;
}

+ (NSString*)OSTableName
{
    if (!tableNameChange) {
        return @"Migration";
    } else {
        return @"Migration2";
    }
}

+ (NSString*)OSColumnName:(NSString *)attributeName
{
    if (columnNameChange) {
        if ([attributeName isEqualToString:@"objectId1"]) {
            return @"objectIdChangedName";
        }
    }
    return attributeName;
}


@end
