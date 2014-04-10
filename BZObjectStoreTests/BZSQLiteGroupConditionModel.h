//
//  BZGroupModel.h
//  BZObjectStore
//
//  Created by SHIMADATAKESHI on 2014/04/09.
//  Copyright (c) 2014年 BONZOO INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BZObjectStoreModelInterface.h"

@interface BZSQLiteGroupConditionModel : NSObject
- (instancetype)initWithNo:(NSString*)no name:(NSString*)name price:(NSInteger)price;
@property (nonatomic,strong) NSString<OSIdenticalAttribute> *no;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) NSInteger price;
@end
