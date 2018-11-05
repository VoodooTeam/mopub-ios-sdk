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

NSString *BUNDLE_ID = nil;

+ (void) pixelRequest:(NSData *) request {
     NSDictionary *headers = [NSJSONSerialization JSONObjectWithData:request
                                                        options:kNilOptions error:nil];
    BUNDLE_ID = headers[@"bundle"];
}

+ (void) pixelResponse:(NSData *) response {
    NSArray *keys;
    NSString *RESPONSE_ID;
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:response
                                                            options:kNilOptions error:nil];
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"!*'(){};:@&=+$,/?%#[]"] invertedSet];;
    [date setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];

    NSLog(@"VidCoin Sniffer %@", [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);
 
    for (int i = 0; i < [jsonResponse[@"ad-responses"] count]; i++) {
        NSDictionary *adResponse = jsonResponse[@"ad-responses"][i][@"metadata"];
        keys = [adResponse allKeys];
        RESPONSE_ID = [[NSUUID UUID] UUIDString];
        
        for (int j = 0 ; j < [keys count]; j++) {
            NSString *key = keys[j];
            NSArray *ignoredHeaders = @[@"content-type", @"x-height", @"x-refreshtime", @"x-width", @"x-after-load-url",
                                        @"x-before-load-url",@"x-browser-agent", @"x-ad-timeout-ms", @"x-connection-hash",
                                        @"x-banner-impression-min-pixels", @"x-banner-impression-min-ms", @"x-orientation",
                                        @"x-tsa-request-body-time", @"x-xss-protection", @"strict-transport-security",
                                        @"content-length", @"content-encoding", @"date", @"server", @"x-nativeparams",
                                        @"x-connection-hash", @"content-security-policy", @"x-custom-event-class-data"];
            
            if (![ignoredHeaders containsObject: key]) {
                // Array of value
                if ([adResponse[key] isKindOfClass:[NSArray class]]) {
                    for (int k = 0 ; k < [adResponse[key] count]; k++) {
                        [self pixelProcess:[NSString stringWithFormat:[VD_Tracker_URL stringByAppendingString:@"/?event_name=response&data_source=%@&event_category=requestad&response_id=%@&bundle_id=%@&mopub_log_date=%@&%@=%@"],
                                            VD_DATA_SOURCE,
                                            RESPONSE_ID,
                                            BUNDLE_ID,
                                            [date stringFromDate:[NSDate date]],
                                            key,
                                            [adResponse[key][k] stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters]]];
                    }
                } else if ([adResponse[key] isKindOfClass:[NSString class]]) {
                    [self pixelProcess:[NSString stringWithFormat:[VD_Tracker_URL stringByAppendingString:@"/?event_name=response&data_source=%@&event_category=requestad&response_id=%@&bundle_id=%@&mopub_log_date=%@&%@=%@"],
                                        VD_DATA_SOURCE,
                                        RESPONSE_ID,
                                        BUNDLE_ID,
                                        [date stringFromDate:[NSDate date]],
                                        key,
                                        [adResponse[key] stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters]]];
                }
            }
        }
    }
}

+ (void) pixelTracker:(NSString *) eventType eventUrl:(NSArray<NSURL *> *) eventUrl {
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"!*'(){};:@&=+$,/?%#[]"] invertedSet];;
    [date setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];


    for (int j = 0 ; j < [eventUrl count]; j++) {
        [self pixelProcess:[NSString stringWithFormat:[VD_Tracker_URL stringByAppendingString:@"/?event_name=event&data_source=%@&event_category=requestad&bundle_id=%@&tracking=%@&&mopub_log_date=%@&tracker=%@"],
                            VD_DATA_SOURCE,
                            BUNDLE_ID,
                            eventType,
                            [date stringFromDate:[NSDate date]],
                            [[eventUrl[j] absoluteString] stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters]]];
    }
}

+ (void) pixelProcess:(NSString *) strURL {
    NSLog(@"VidCoin Sniffer str %@", strURL);
    
    NSURLRequest *trackingRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString: strURL]];
    [MPHTTPNetworkSession startTaskWithHttpRequest:trackingRequest];
}
@end
