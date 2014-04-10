//
//  BZUpdateExistsObjectWithNoRowIdModel.h
//  BZObjectStore
//
//  Created by SHIMADATAKESHI on 2014/04/11.
//  Copyright (c) 2014年 BONZOO INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BZObjectStoreModelInterface.h"

@interface BZUpdateExistsObjectWithNoRowIdModel : NSObject
@property (nonatomic,strong) NSString<OSIdenticalAttribute> *no1;
@property (nonatomic,strong) NSString<OSIdenticalAttribute> *no2;
@property (nonatomic,strong) NSString *name;
@end
