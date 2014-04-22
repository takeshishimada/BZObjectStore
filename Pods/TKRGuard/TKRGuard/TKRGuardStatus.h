//
//  TKRGuardStatus.h
//
//  Created by ToKoRo on 2013-12-22.
//

typedef NS_ENUM(NSInteger, TKRGuardStatus) {
    TKRGuardStatusAny = -1,
    TKRGuardStatusSuccess = 1,
    TKRGuardStatusFailure = 10,
    TKRGuardStatusTimeouted = 100,

    TKRGuardStatusNil = 0 //< Your application must not use
};

typedef NS_ENUM(NSInteger, TKRGuardStatusOld) {
    kTKRGuardStatusAny = -1,
    kTKRGuardStatusSuccess = 1,
    kTKRGuardStatusFailure = 10,
    kTKRGuardStatusTimeouted = 100,
    kTKRGuardStatusNil = 0
};

