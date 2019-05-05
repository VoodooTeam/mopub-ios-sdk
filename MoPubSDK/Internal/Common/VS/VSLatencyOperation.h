//
//  VSLatencyOperation.h
//  MoPubSDK
//
//  Created by sarra_srairi on 03/05/2019.
//  Copyright © 2019 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSLatency.h"


NS_ASSUME_NONNULL_BEGIN

@interface VSLatencyOperation : NSObject

+ (void)sendLatency:(VSLatency *)vlatency;


@end

NS_ASSUME_NONNULL_END
