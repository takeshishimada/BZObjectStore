//
//  TKRGuard.h
//
//  Created by ToKoRo on 2013-12-13.
//

#import "TKRGuardStatus.h"

#define TKRGUARD_KEY ([TKRGuard adjustedKey:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]])
#define TKRGUARD_TIMEOUT XCTFail(@"TKRGuard timeouted")
#define TKRAssertEqualStatus(v, e) TKRGuardStatus e_ ## __LINE__ = (e); \
                                   TKRGuardStatus v_ ## __LINE__ = (v); \
                                   e_ ## __LINE__ == v_ ## __LINE__ ? \
                                   (void)nil : \
                                   XCTFail(@"%@", [TKRGuard guideMessageWithExpected:e_ ## __LINE__  \
                                                                                 got:v_ ## __LINE__])

#if !defined(UNUSE_TKRGUARD_SHORTHAND)

#define WAIT TKRGuardStatusTimeouted != [TKRGuard waitForKey:TKRGUARD_KEY] ? \
                        (void)nil : TKRGUARD_TIMEOUT
#define WAIT_MAX(t) TKRGuardStatusTimeouted != [TKRGuard waitWithTimeout:(t) forKey:TKRGUARD_KEY] ? \
                        (void)nil : TKRGUARD_TIMEOUT
#define WAIT_TIMES(t) TKRGuardStatusTimeouted != [TKRGuard waitForKey:TKRGUARD_KEY times:(t)] ? \
                        (void)nil : TKRGUARD_TIMEOUT
#define WAIT_FOR(s) TKRAssertEqualStatus([TKRGuard waitForKey:TKRGUARD_KEY], (s))

#define RESUME [TKRGuard resumeForKey:TKRGUARD_KEY]
#define RESUME_WITH(s) [TKRGuard resumeWithStatus:(s) forKey:TKRGUARD_KEY]

#endif

#if !defined(NOTALLOW_TKRGUARD_DELAYWAIT)
#define ALLOW_TKRGUARD_DELAYWAIT
#endif

@interface TKRGuard : NSObject

+ (TKRGuardStatus)waitForKey:(id)key;
+ (TKRGuardStatus)waitForKey:(id)key times:(NSUInteger)times;
+ (TKRGuardStatus)waitWithTimeout:(NSTimeInterval)timeout forKey:(id)key;
+ (TKRGuardStatus)waitWithTimeout:(NSTimeInterval)timeout forKey:(id)key times:(NSUInteger)times;

+ (void)resumeForKey:(id)key;
+ (void)resumeWithStatus:(TKRGuardStatus)status forKey:(id)key;

+ (void)setDefaultTimeoutInterval:(NSTimeInterval)timeoutInterval;
+ (void)resetDefaultTimeoutInterval;

+ (id)adjustedKey:(id)key;

+ (NSString *)guideMessageWithExpected:(TKRGuardStatus)expected got:(TKRGuardStatus)got;

@end
