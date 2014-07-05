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

#import "FMDatabase+indexInfo.h"

@implementation FMDatabase (indexInfo)

- (BOOL)indexExists:(NSString*)indexName {
    
    indexName = [indexName lowercaseString];
    
    FMResultSet *rs = [self executeQuery:@"select [sql] from sqlite_master where [type] = 'index' and lower(name) = ?", indexName];
    
    //if at least one next exists, table exists
    BOOL returnBool = [rs next];
    
    //close and free object
    [rs close];
    
    return returnBool;
}

- (NSArray*)columnNamesWithIndexName:(NSString*)indexName
{
    NSMutableArray *columnNames = [NSMutableArray array];
    FMResultSet *rs = [self executeQuery:[NSString stringWithFormat:@"PRAGMA index_info(%@)", indexName]];
    while (rs.next) {
        [columnNames addObject:[rs stringForColumn:@"name"]];
    }
    [rs close];
    return [NSArray arrayWithArray:columnNames];
}

@end
