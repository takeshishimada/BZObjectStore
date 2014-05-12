//
//  BZActiveRecordModel.h
//  BZObjectStore
//
//  Created by SHIMADATAKESHI on 2014/05/12.
//  Copyright (c) 2014年 BONZOO INC. All rights reserved.
//

#import "BZActiveRecord.h"

@interface BZActiveRecordModel : BZActiveRecord
@property (nonatomic,strong) NSString *code;
@property (nonatomic,assign) CGFloat price;
@end
