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
#import <UIKit/UIKit.h>

@implementation VSAnalytics {
}

static NSString *VS_Tracker_URL  = @"https://vs-analytics.voodoo-dev.io";
static NSString *VS_INIT_URL  = @"https://voodoosauce.voodoo-dev.io/init?bundle_id=%@";
static int VS_VERSION = 1;
static NSTimeInterval kVSTrackerTimeoutInterval = 10.0;
static NSString *SESSION_ID = nil;
static NSString *BUNDLE_ID = nil;
static NSString *FIREHOSE_CHANNEL = nil;
static NSString *LATENCY_VALUE = nil;
static NSString *CONNECTIVITY = @"NO";
static BOOL DISABLED = YES;

+ (void) initTracker  {
    if (SESSION_ID == nil) {
        SESSION_ID =  [[NSUUID UUID] UUIDString];
    }

    BUNDLE_ID = [[NSBundle mainBundle] bundleIdentifier];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:VS_INIT_URL, BUNDLE_ID]]];
    
    [MPHTTPNetworkSession startTaskWithHttpRequest:request responseHandler:^(NSData * data, NSHTTPURLResponse * response) {
        
        NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:kNilOptions error:nil];

        if (dicData[@"disabled"]) {
            
        }
        DISABLED = [dicData[@"disabled"] isEqualToString:@"yes"]
            || arc4random_uniform(10) % [dicData[@"devideBy"] longValue] != 0
            || VS_VERSION < (int) dicData[@"minVersion"];

        FIREHOSE_CHANNEL = dicData[@"firehoseChannel"];
    } errorHandler:^(NSError * error) {
        MPLogDebug(@"Failed to init vsanalytics");
        DISABLED = YES;
        
    }];
}

+ (void) pixelRequest:(NSData *) request {
    if (DISABLED) {
        return;
    }

    NSDictionary *dicRequest = [NSJSONSerialization JSONObjectWithData:request
                                                        options:kNilOptions error:nil];
    
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSDictionary *data= @{
                          @"meta": @{
                                  @"app_id": BUNDLE_ID,
                                  @"vs_version": [NSNumber numberWithInteger:VS_VERSION],
                                  @"type": @"REQUEST",
                                  @"session_id": SESSION_ID,
                                  @"processingDate":  [date stringFromDate:[NSDate date]]
                                  },
                          @"event": dicRequest
                          };
    [self pixelProcess:data];
}

+ (void) pixelResponse:(NSData *) response {
  
    NSDictionary *dicResponse;
    
//    if (DISABLED) {
//        return;
//    }
    if (response) {
       dicResponse = [NSJSONSerialization JSONObjectWithData:response
                                                                    options:kNilOptions error:nil];
    }

    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
   
   
    
    for (int i = 0; i < [dicResponse[@"ad-responses"] count]; i++) {
        NSDictionary *data= @{
                              @"meta": @{
                                      @"app_id": BUNDLE_ID,
                                      @"vs_version": [NSNumber numberWithInteger:VS_VERSION],
                                      @"type": @"RESPONSE",
                                      @"session_id": SESSION_ID,
                                      @"processingDate": [date stringFromDate:[NSDate date]],
                                      @"latency": LATENCY_VALUE ?:@"",
                                      @"connectivityStatus": CONNECTIVITY,
                                      },
                              @"event": dicResponse[@"ad-responses"][i]
                              };


    [self pixelProcess:data];
    }
}


+ (void) pixelLatency:(NSData *) response {
    
    NSDictionary *dicResponse;
    
    if (DISABLED) {
        return;
    }
    if (response) {
        dicResponse = [NSJSONSerialization JSONObjectWithData:response
                                                      options:kNilOptions error:nil];
    }
    
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    for (int i = 0; i < [dicResponse[@"ad-responses"] count]; i++) {
        NSDictionary *data= @{
                              @"meta": @{
                                      @"app_id": BUNDLE_ID,
                                      @"vs_version": [NSNumber numberWithInteger:VS_VERSION],
                                      @"type": @"RESPONSE",
                                      @"session_id": SESSION_ID,
                                      @"processingDate": [date stringFromDate:[NSDate date]],
                                      @"latency": LATENCY_VALUE ?:@"",
                                      @"connectivityStatus": CONNECTIVITY,
                                      },
                                @"event": dicResponse[@"ad-responses"][i]
                              };
        
        [self pixelProcess:data];
    }
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
                                  @"vs_version": [NSNumber numberWithInteger:VS_VERSION],
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


+ (void)startLatencyCalcul:(NSString *)adUnitID{
    
    [VSAnalytics connectivity];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:[NSDate date] forKey:adUnitID];
    [defaults setObject:adUnitID forKey:@"ADUnit_LATENCY"]; 
    [defaults synchronize];
}

+ (void)calculateLatencyFor:(NSString *)adUnitID
                       data:(NSData *)response
                      newAd:(NSString *)newUnit{
  
    if (adUnitID && [NSUserDefaults.standardUserDefaults objectForKey:adUnitID]){
        NSDate *start = [NSUserDefaults.standardUserDefaults objectForKey:adUnitID];
        
        [NSUserDefaults.standardUserDefaults removeObjectForKey:adUnitID];
        [NSUserDefaults.standardUserDefaults synchronize];
        
        NSTimeInterval lastTime = ([NSDate date].timeIntervalSince1970 - start.timeIntervalSince1970);
        CGFloat rounded_down = floorf(lastTime * 100) / 100;
        LATENCY_VALUE = [NSString stringWithFormat:@"%.02f s", rounded_down];
        
        NSLog(@"[SAUCE] latency for custom %@",adUnitID);
 
        [VSAnalytics pixelLatency:response];
    }
    [VSAnalytics startLatencyCalcul:newUnit];
}

+ (void)connectivity
{
    NSURL *scriptUrl = [NSURL URLWithString:@"http://www.google.com/m"];
    NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
    if (data)
        CONNECTIVITY = @"YES";
    else
        CONNECTIVITY = @"NO";
}

@end
