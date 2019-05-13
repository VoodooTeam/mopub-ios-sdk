//
//  VSLatencyOperation.h
//  MoPubSDK
//
//  Created by sarra_srairi on 03/05/2019.
//  Copyright © 2019 MoPub. All rights reserved.
//

#import "NSObject+VSLoader.h"
#import "VSLatencyOperation.h"


@implementation NSObject (VSLoader)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        [center addObserver:self
                   selector:@selector(voodooSauce_appDidBecomeActive)
                       name:UIApplicationDidBecomeActiveNotification
                     object:nil];
    });
}


#pragma mark - Application Lifecycle
static dispatch_once_t once;
- (void)voodooSauce_appDidBecomeActive {
    dispatch_once(&once, ^{
      [VSLatencyOperation initLatencyConfig];
    });
}
@end

