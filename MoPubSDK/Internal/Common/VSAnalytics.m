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

static NSString *VS_Tracker_URL  = @"https://vs-analytics.voodoo-dev.io";
static NSString *VS_INIT_URL  = @"https://voodoosauce.voodoo-dev.io/init?bundle_id=%@";

static NSTimeInterval kVSTrackerTimeoutInterval = 10.0;
static NSString *SESSION_ID = nil;
static NSString *BUNDLE_ID = nil;
static NSString *FIREHOSE_CHANNEL = nil;
static BOOL DISABLED = YES;

+ (void) initTracker  {
    BUNDLE_ID = [[NSBundle mainBundle] bundleIdentifier];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:VS_INIT_URL, BUNDLE_ID]]];
    
    [MPHTTPNetworkSession startTaskWithHttpRequest:request responseHandler:^(NSData * data, NSHTTPURLResponse * response) {
        
        NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:kNilOptions error:nil];
        DISABLED = [dicData[@"disabled"] isEqualToString:@"yes"];
        FIREHOSE_CHANNEL = dicData[@"firehoseChannel"];
    } errorHandler:^(NSError * error) {
        MPLogDebug(@"Failed to init vsanalytics");
    }];
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
                             @"DeliveryStreamName": FIREHOSE_CHANNEL,
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
    [MPHTTPNetworkSession startTaskWithHttpRequest:request];
}
@end
