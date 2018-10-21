//
//  VidCoinSniff.h
//  MoPubSDK
//
//  Created by Mohamed taieb on 15/10/2018.
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VidCoinSniff : NSObject

+ (void) pixelRequest:(NSData *) request;
+ (void) pixelResponse:(NSData *) response;
+ (void) pixelTracker:(NSString *) eventType;
+ (void) pixelProcess:(NSString *) strURL;

@end
