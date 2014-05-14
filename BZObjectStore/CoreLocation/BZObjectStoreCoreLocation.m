//
//  BZObjectStoreCoreLocation.m
//  BZObjectStore
//
//  Created by SHIMADATAKESHI on 2014/05/14.
//  Copyright (c) 2014年 BONZOO INC. All rights reserved.
//

#import "BZObjectStoreCoreLocation.h"
#import "BZObjectStoreClazz.h"
#import "BZObjectStoreClazzCLLocation.h"
#import "BZObjectStoreClazzCLLocationCoordinate2D.h"

@implementation BZObjectStoreCoreLocation

+ (void)load
{
    [self registerClass];
}
+ (void)registerClass
{
    [BZObjectStoreClazz addClazz:[BZObjectStoreClazzCLLocation class]];
    [BZObjectStoreClazz addClazz:[BZObjectStoreClazzCLLocationCoordinate2D class]];
}

@end
