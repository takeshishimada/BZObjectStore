//
//  TKRGuardToken.h
//
//  Created by ToKoRo on 2013-12-13.
//

#import "TKRGuardStatus.h"

@interface TKRGuardToken : NSObject

@property (assign) NSUInteger waitCount;
@property (assign) TKRGuardStatus resultStatus;
@property (assign, getter=isPreceding) BOOL preceding;

- (TKRGuardStatus)waitWithTimeout:(NSTimeInterval)timeout;
- (void)resumeWithStatus:(TKRGuardStatus)status;
- (BOOL)isWaiting;

@end
