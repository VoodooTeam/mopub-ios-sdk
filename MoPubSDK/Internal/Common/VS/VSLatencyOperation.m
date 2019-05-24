//
//  VSLatencyOperation.m
//  MoPubSDK
//
//  Created by sarra_srairi on 03/05/2019.
//  Copyright © 2019 MoPub. All rights reserved.
//
#import "VSLatencyOperation.h"
#import "VSOperation.h"


@implementation VSLatencyOperation

static NSString *WATERFALL_ID = nil;


// disable ads format
static BOOL INTERTITIAL_ACTIVATED = false;
static BOOL REWARDED_ACTIVATED = false;
static BOOL BANNER_ACTIVATED = false;

#pragma mark - static values

// *** INIT KEYS ***
#define vsSourceIdKey                           @"source_id"
#define vsPlatformKey                           @"platform"
#define vsVersionKey                            @"vs_version"

// *** IMPRESSION KEYS ***
#define vsConnectivity                          @"connectivity"
#define vsUserId                                @"user_id"
#define kLatency                                @"latency"
#define kNetwork                                @"network"
// **** VALUE FS/RV/BANNER ***
#define kAdunit                                 @"ad_unit"
#define kIsActiveKey                            @"activate"
#define ktype                                   @"name"
#define kwaterfallId                            @"waterfall_id"

// Type values
#define Klatencytype                            @"latency"
#define Kimpressiontype                         @"impression"


//trackers 
#define kHostProduction @"https://vs-api.voodoo-tech.io"
#define kHostStaging @"https://vs-api.voodoo-staging.io"
#define kHostDev @"https://vs-api.voodoo-dev.io"

/*
 * init Config / enable _ disable analytics
 */
+ (void)initLatencyConfig {
    
  
    NSDictionary *params = @{
                             vsSourceIdKey   :[VSLatency vs_sourceID],
                             vsPlatformKey   :[VSLatency vs_platform],
                             vsVersionKey    :[VSLatency vs_version],
                             };
    
    // @todo : add end point init
    [VSOperation request:[NSURL URLWithString:[self hostName:VSAPIEndPointInt]]
              httpMethod:VSHTTPMethodPost
              parameters:params
                 headers:nil
                 success:^(id  _Nullable responseObject) {
                     
                     if ([responseObject isEqual:[NSNull null]] ||
                         ![responseObject isKindOfClass:NSDictionary.class]) {
                         return;
                     }
                     
                     NSDictionary *data = (NSDictionary *)responseObject[@"data"];
                     if ([data isEqual:[NSNull null]] ||
                         ![data isKindOfClass:NSDictionary.class]) {
                         return;
                     }
                     
                     INTERTITIAL_ACTIVATED =  [self isformatActivated:data forFormat:VS_FS];
                     REWARDED_ACTIVATED =     [self isformatActivated:data forFormat:VS_RV];
                     BANNER_ACTIVATED =       [self isformatActivated:data forFormat:VS_BANNER];
                     
                 } failure:^(NSError *error) {
                     NSLog(@"[SAUCE] Failed to int data config");
                     INTERTITIAL_ACTIVATED = false;
                     REWARDED_ACTIVATED = false;
                     BANNER_ACTIVATED = false;
                 }];
}


/*
 *  sending metrics
 */
+ (void)senddata:(VSLatency *)vlatency
     customClass:(NSString *)className
     waterfallID:(NSString *)waterfallID
      adunitType:(VSUnitFormat)unitType
            type:(VSEventType)eventType{
    
    switch (unitType) {
        case VS_RV:
            if (!REWARDED_ACTIVATED){
                return;
            }
            break;
            
        case VS_FS:
            if (!INTERTITIAL_ACTIVATED){
                return;
            }
            break;
            
        case VS_BANNER:
            if (!BANNER_ACTIVATED){
                return;
            }
            break;
        default:
            break;
    }
    
    NSMutableDictionary *params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [VSLatency vs_sourceID],                                      vsSourceIdKey,
                                     [VSLatency vs_platform],                                      vsPlatformKey,
                                     [VSLatency vs_version],                                       vsVersionKey,
                                     [VSLatency vs_connectivity],                                  vsConnectivity,
                                     [VSLatency vs_userID],                                        vsUserId,
                                     
                                     waterfallID  ?: @"unknown",                                   kwaterfallId,
                                     [self typeEventName:eventType] ?: @"unknown",                 ktype,
          
                                     [VSLatency formatUnitfromType:unitType] ?: @"unknown",        kAdunit,
                                     className ?: @"unknown",                                      kNetwork,
                                     
                                     nil];
  
        
        if (eventType == VSLatencyEvent && vlatency && vlatency.latencyMs){
            int result = (int)roundf(vlatency.latencyMs * 1000);
            [params setObject: [NSString stringWithFormat:@"@%d", result] forKey:kLatency];
        }
        
        NSDictionary *dictionary = [[NSDictionary alloc] init];
        dictionary = [params mutableCopy];
        
        [VSOperation request:[NSURL URLWithString:[self hostName:VSAPIEndPointMetric]]
                  httpMethod:VSHTTPMethodPost
                  parameters:dictionary
                     headers:nil
                     success:^(id  _Nullable responseObject) {
                         NSLog(@"[SAUCE] success to send data");
                     }
                     failure:^(NSError *error) {
                         NSLog(@"[SAUCE] Failed to send data");
                     }];
}


+(NSString *)typeEventName:(VSEventType)endpoint {
    switch (endpoint) {
            
        case VSAImpressionEvent:
            return @"impression";
            break;
            
        case VSLatencyEvent:
            return @"latency";
            break;
    }
}


+(nonnull NSString *)hostName:(VSAPIEndPoint)endpoint {
    
    switch (endpoint) {
            
        case VSAPIEndPointInt:
            return  [NSString stringWithFormat:@"%@/%@", kHostProduction, @"init"];
            break;
        case VSAPIEndPointMetric:
            return  [NSString stringWithFormat:@"%@/%@", kHostProduction, @"sendMetrics"];
            break;
    }
}

+(BOOL)isformatActivated:(NSDictionary *)dic
               forFormat:(VSUnitFormat)format{
    
    if ([dic isEqual:[NSNull null]] ||
        ![dic isKindOfClass:NSDictionary.class]) {
        return false;
    }
    
    NSDictionary *result = [dic objectForKey:[VSLatency formatUnitfromType:format]];
    if ([result isEqual:[NSNull null]] ||
        ![result isKindOfClass:NSDictionary.class]) {
        return false;
    }
    
    if ([[result objectForKey:kIsActiveKey] isEqual:[NSNull null]]){
        return false;
    }
    return [[result objectForKey:kIsActiveKey] boolValue];
}

@end
