//
//  BZGroupModel.m
//  BZObjectStore
//
//  Created by SHIMADATAKESHI on 2014/04/09.
//  Copyright (c) 2014年 BONZOO INC. All rights reserved.
//

#import "BZSQLiteGroupConditionModel.h"

@implementation BZSQLiteGroupConditionModel
- (instancetype)initWithNo:(NSString*)no name:(NSString*)name price:(NSInteger)price
{
    if ( self = [super init]) {
        self.no = no;
        self.name = name;
        self.price = price;
    }
    return self;
}
@end
