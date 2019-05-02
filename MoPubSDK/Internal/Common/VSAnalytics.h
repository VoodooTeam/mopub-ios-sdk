//
//  VSAnalytics.h
//  MoPubSDK
//
//  Created by Mohamed taieb on 15/10/2018.
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSAnalytics : NSObject
+ (void) initTracker;
+ (void) pixelRequest:(NSData *) request;
+ (void) pixelResponse:(NSData *) response;
+ (void) pixelTracker:(NSString *) eventType
              impUrls:(NSArray<NSURL *> *) impUrls
             clickUrl:(NSURL *) clickUrl;
+ (void) pixelProcess:(NSDictionary *) data;

+ (void)startLatencyCalcul:(NSString *)adUnitID;
+ (void)calculateLatencyFor:(NSString *)adUnitID
                  adNetwork:(NSString *)adNetwork;
@end
