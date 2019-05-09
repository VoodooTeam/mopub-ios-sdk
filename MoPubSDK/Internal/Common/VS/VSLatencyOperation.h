//
//  VSLatencyOperation.h
//  MoPubSDK
//
//  Created by sarra_srairi on 03/05/2019.
//  Copyright © 2019 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSLatency.h"



@interface VSLatencyOperation : NSObject


/*  Sending latency informations to VS API
 *  VSLatency : object containing latency' information
 */
+ (void)sendLatency:(VSLatency *)vlatency;

+ (void)initLatencyConfig;

@end
