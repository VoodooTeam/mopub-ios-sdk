//
//  VidCoinSniffer.m
//  MoPubSDK
//
//  Created by Mohamed taieb on 15/10/2018.
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "VidCoinSniff.h"
#import "MPHTTPNetworkSession.h"

@implementation VidCoinSniff {
}

#ifdef DEBUG
static const NSString *VD_Tracker_URL  = @"https://trackers.val-dev.io";
#else
static const NSString *VD_Tracker_URL  = @"https://trackers.voodoo-analytics.io";
#endif

static const NSString *VD_DATA_SOURCE = @"cc8e3892-ce30-11e8-a8d5-f2801f1b9fd1";
static NSString *REQUEST_ID;

// event_name=params&data_source=cc8e3892-ce30-11e8-a8d5-f2801f1b9fd1&event_category=requestad
// dn gdpr_applies uuid bundle requestid current_consent_status av & nv
+ (void) pixelRequest:(NSData *) request {
    NSDictionary *headers = [NSJSONSerialization JSONObjectWithData:request
                                                        options:kNilOptions error:nil];
    
    if (headers[@"request_id"]) {
        REQUEST_ID = headers[@"request_id"];
    } else {
        REQUEST_ID = [[NSUUID UUID] UUIDString];
    }
    
    [self pixelProcess:[NSString stringWithFormat:[VD_Tracker_URL stringByAppendingString:@"/?event_name=params&data_source=%@&event_category=requestad&request_id=%@&dn=%@&gdpr_applies=%@&bundle=%@&current_consent_status=%@&av=%@&nv=%@"],
                        VD_DATA_SOURCE, REQUEST_ID,
                        headers[@"dn"],
                        headers[@"gdpr_applies"],
                        headers[@"bundle"],
                        headers[@"current_consent_status"],
                        headers[@"av"],
                        headers[@"nv"]
            ]];
}

+ (void) pixelResponse:(NSData *) response {
    
    NSArray *keys;
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:response
                                                            options:kNilOptions error:nil];
    
    for (int i = 0; i < [jsonResponse[@"ad-responses"] count]; i++) {
        NSDictionary *adResponse = jsonResponse[@"ad-responses"][i][@"metadata"];
        keys = [adResponse allKeys];

        for (int j = 0 ; j < [keys count]; j++) {
            NSString *key = keys[j];
            NSArray *ignoredHeaders = @[@"content-type", @"x-height", @"x-refreshtime", @"x-width", @"x-after-load-url",
                                        @"x-before-load-url",@"x-browser-agent", @"x-ad-timeout-ms", @"x-response-time",
                                        @"x-banner-impression-min-pixels", @"x-banner-impression-min-ms", @"x-orientation",
                                        @"x-connection-hash", @"x-tsa-request-body-time", @"x-xss-protection",
                                        @"x-failurl", @"content-length", @"content-encoding", @"date", @"server",
                                        @"strict-transport-security", @"x-connection-hash", @"content-security-policy",
                                        @"x-nativeparams", @"x-custom-event-class-data"];
            
            if (![ignoredHeaders containsObject: key]) {
                NSString *formattedData;
                
                // Array of value
                if ([adResponse[key] isKindOfClass:[NSArray class]]) {
                    for (int k = 0 ; k < [adResponse[key] count]; k++) {
                        formattedData = adResponse[key][k];
                    }
                // key string value
                } else {
                    formattedData = adResponse[key];
                }
                
                // Add Date
                [self pixelProcess:[NSString stringWithFormat:[VD_Tracker_URL stringByAppendingString:@"/?event_name=response&data_source=%@&event_category=requestad&request_id=%@&%@=%@"],
                                    VD_DATA_SOURCE,
                                    REQUEST_ID,
                                    key,
                                    formattedData]];
            }
        }
    }
}

+ (void) pixelTracker:(NSString *) eventType {
    [self pixelProcess:[NSString stringWithFormat:[VD_Tracker_URL stringByAppendingString:@"/?event_name=event&data_source=%@&event_category=requestad&request_id=%@&tracking=%@"],
                        VD_DATA_SOURCE,
                        REQUEST_ID,
                        eventType]];
}

+ (void) pixelProcess:(NSString *) strURL {
    NSURLRequest *trackingRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString: strURL]];
    [MPHTTPNetworkSession startTaskWithHttpRequest:trackingRequest];
}
@end

