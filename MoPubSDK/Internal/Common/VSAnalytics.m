//
//  VSAnalytics.m
//  MoPubSDK
//
//  Created by Mohamed taieb on 15/10/2018.
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "VSAnalytics.h"
#import "MPHTTPNetworkSession.h"
#import "MPLogging.h"

@implementation VSAnalytics {
}

NSString * const VS_Tracker_URL  = @"https://cnk1a3i0b3.execute-api.eu-west-2.amazonaws.com/dev";
const NSTimeInterval kVSTrackerTimeoutInterval = 10.0;
NSString *SESSION_ID = nil;
NSString *BUNDLE_ID = nil;
bool DISABLED = true;

+ (void) setLevel:(bool *) level {
    DISABLED = level;
}

+ (void) pixelRequest:(NSData *) request {
    if (DISABLED) {
        return;
    }
    
    if (SESSION_ID == nil) {
        SESSION_ID =  [[NSUUID UUID] UUIDString];
    }
    
    NSDictionary *dicRequest = [NSJSONSerialization JSONObjectWithData:request
                                                        options:kNilOptions error:nil];
    
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];

    BUNDLE_ID = dicRequest[@"bundle"] ? dicRequest[@"bundle"] : @"";
    
    NSDictionary *data= @{
                          @"meta": @{
                                  @"app_id": BUNDLE_ID,
                                  @"type": @"REQUEST",
                                  @"session_id": SESSION_ID,
                                  @"processingDate":  [date stringFromDate:[NSDate date]],
                                  },
                          @"event": dicRequest
                          };
    [self pixelProcess:data];
}

+ (void) pixelResponse:(NSData *) response {
    if (DISABLED) {
        return;
    }
        NSDictionary *dicResponse = [NSJSONSerialization JSONObjectWithData:response
                                                            options:kNilOptions error:nil];
        NSDateFormatter *date = [[NSDateFormatter alloc] init];
        [date setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
        NSDictionary *data= @{
                          @"meta": @{
                                  @"app_id": BUNDLE_ID,
                                  @"type": @"RESPONSE",
                                  @"session_id": SESSION_ID,
                                  @"processingDate": [date stringFromDate:[NSDate date]],
                                  },
                          @"event": dicResponse
                          };
    
        [self pixelProcess:data];
}

+ (void) pixelTracker:(NSString *) eventType
              impUrls:(NSArray<NSURL *> *) impUrls
             clickUrl:(NSURL *) clickUrl {
    if (DISABLED) {
        return;
    }
    
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSMutableArray *links = [[NSMutableArray alloc] init];
    
    if ([eventType isEqualToString:@"IMPRESSION"]) {
        for (int j = 0 ; j < [impUrls count]; j++) {
            [links addObject:[impUrls[j] absoluteString]];
        }
    } else {
        [links addObject:[clickUrl absoluteString]];
    }
    
    NSDictionary *data= @{
                          @"meta": @{
                                  @"app_id": BUNDLE_ID,
                                  @"type": eventType,
                                  @"session_id": SESSION_ID,
                                  @"processingDate": [date stringFromDate:[NSDate date]],
                                  },
                          @"event": @{
                                  @"url": links,
                                  }
                          };
    [self pixelProcess:data];
}

+ (void) pixelProcess:(NSDictionary *) data {
    NSError *error;
    NSDictionary *record = @{
                             @"DeliveryStreamName": @"vs-analytics-mopub",
                             @"Record": @{
                                     @"Data": [[NSJSONSerialization dataWithJSONObject:data
                                                                               options:NSJSONWritingPrettyPrinted
                                                                                 error:&error]
                                               base64EncodedStringWithOptions:0]
                                     }
                             };
    
    NSURL *url = [NSURL URLWithString:VS_Tracker_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kVSTrackerTimeoutInterval];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSData *recordData = [NSJSONSerialization dataWithJSONObject:record
                                    options:NSJSONWritingPrettyPrinted
                                                           error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)recordData.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:recordData];
    [MPHTTPNetworkSession startTaskWithHttpRequest:request responseHandler:^(NSData * _Nonnull data, NSHTTPURLResponse * _Nonnull response) {
        MPLogDebug(@"Successfully sent after load URL: %@", VS_Tracker_URL);
    } errorHandler:^(NSError * _Nonnull error) {
        MPLogDebug(@"Failed to send after load URL: %@", VS_Tracker_URL);
    }];
}
@end
