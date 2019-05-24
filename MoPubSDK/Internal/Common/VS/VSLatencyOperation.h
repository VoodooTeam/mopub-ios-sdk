//
//  VSLatencyOperation.h
//  MoPubSDK
//
//  Created by sarra_srairi on 03/05/2019.
//  Copyright © 2019 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSLatency.h"

/**
 A representation of the API Endpoints
 */
typedef enum VSAPIEndPoint {
    VSAPIEndPointInt,
    VSAPIEndPointMetric,
    
} VSAPIEndPoint;


typedef enum VSEventType {
    VSAImpressionEvent,
    VSLatencyEvent,
} VSEventType;


@interface VSLatencyOperation : NSObject


/*  Sending latency informations to VS API
 *  VSLatency : object containing latency' information
 *  type : Latency / impression
 */
+ (void)senddata:(VSLatency *)vlatency
     customClass:(NSString *)className
     waterfallID:(NSString *)waterfallID
      adunitType:(VSUnitFormat)unitType
            type:(VSEventType)eventType;


/*  init latency
 *  Important if server side send NO : SHOULD stop sending logs to server side 
 */
+ (void)initLatencyConfig;

@end
