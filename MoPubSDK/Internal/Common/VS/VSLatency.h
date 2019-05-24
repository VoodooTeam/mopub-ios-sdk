//
//  VSLatency.h
//  MoPubSDK
//
//  Created by sarra_srairi on 03/05/2019.
//  Copyright © 2019 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 A representation of the API Endpoints
 */
typedef enum VSUnitFormat {
    VS_FS,
    VS_RV,
    VS_BANNER,
    VS_NATIVE
    
} VSUnitFormat;

@interface VSLatency : NSObject


/**
 The network Latency in ms Integer 
 */
@property (nonatomic) double latencyMs;



/* source id : app's bundle id */
+ (NSString *_Nonnull)vs_sourceID;


/* vs_platform : platform type / android/ iOS */
+ (NSString *_Nonnull)vs_platform;


/* vs_version : voodoo_sauce version */
+ (NSString *_Nonnull)vs_version;


/* vs_version : voodoo_sauce version */
+ (NSString *_Nonnull)vs_connectivity;
 
/* userID :idfa */
+ (NSString *_Nonnull)vs_userID;


/* init method with latency */
- (instancetype _Nullable )initWithLatency:(double)latency;


+ (NSString *_Nonnull)formatUnitfromType:(VSUnitFormat)endpoint;
@end


