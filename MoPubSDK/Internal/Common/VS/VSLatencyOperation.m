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


static BOOL DISABLED = YES;
#pragma mark - static values
#define vsSourceIdKey                           @"source_id"
#define vsPlatformKey                           @"platform"
#define vsVersionKey                            @"vs_version"
#define vsConnectivity                          @"connectivity"

#define kLatency                                @"latency"
#define kNetwork                                @"network"
#define kAdunit                                 @"ad_unit"
#define kIsActiveKey                            @"activate"



/*
 * init Config / enable _ disable analytics
 */
+ (void)initLatencyConfig {
    
    
    NSDictionary *params = @{
                             vsSourceIdKey   :[VSLatency vs_sourceID],
                             vsPlatformKey   :[VSLatency vs_platform],
                             vsVersionKey    :[VSLatency vs_version],
                             };
    
    [VSOperation request:[NSURL URLWithString:@"https://private-48bbe3-vadataapi.apiary-mock.com/?init"]
              httpMethod:VSHTTPMethodPost
              parameters:nil
                 headers:nil
                 success:^(id  _Nullable responseObject) {
                     
                     if ([responseObject isEqual:[NSNull null]] ||
                         ![responseObject isKindOfClass:NSDictionary.class]) {
                         DISABLED = YES;
                         return;
                     }
                     
                     NSDictionary *data = (NSDictionary *)responseObject[@"data"];
                     if ([data isEqual:[NSNull null]] ||
                         ![data isKindOfClass:NSDictionary.class]) {
                         DISABLED = YES;
                         return;
                     }
                     
                     if ([[data objectForKey:kIsActiveKey] isEqual:[NSNull null]] || ![data objectForKey:kIsActiveKey] ){
                         DISABLED = YES;
                     } else {
                         DISABLED = [[data objectForKey:kIsActiveKey] boolValue];
                     }
                     
                 } failure:^(NSError *error) {
                     NSLog(@"[SAUCE] Failed to int data config");
                     DISABLED = YES;
                 }];
}


/*
 *
 */
+ (void)sendLatency:(VSLatency *)vlatency{
    
    if (!DISABLED){
        // parse data
        NSDictionary *params = @{
                                 vsSourceIdKey       :[VSLatency vs_sourceID],
                                 vsPlatformKey       :[VSLatency vs_platform],
                                 vsVersionKey        :[VSLatency vs_version],
                                 vsConnectivity      :[VSLatency vs_connectivity],
                                 
                                 kNetwork            :vlatency.networkType,
                                 kAdunit             :vlatency.adUnit,
                                 kLatency            :vlatency.latencyMs,
                                 };
        
        [VSOperation request:[NSURL URLWithString:@"https://private-48bbe3-vadataapi.apiary-mock.com/?sendMetrics"]
                  httpMethod:VSHTTPMethodPost
                  parameters:params
                     headers:nil
                     success:^(id  _Nullable responseObject) {
                         NSLog(@"[SAUCE] success to send data");
                     }
                     failure:^(NSError *error) {
                         NSLog(@"[SAUCE] Failed to send data");
                     }];
    }
}

@end
