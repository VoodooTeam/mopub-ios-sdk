//
//  VSLatency.h
//  MoPubSDK
//
//  Created by sarra_srairi on 03/05/2019.
//  Copyright © 2019 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface VSLatency : NSObject


/**
 The network Latency
 */
@property (nonatomic, strong, nonnull) NSString *latencyMs;


/**
 The network name
 */
@property (nonatomic, strong, nonnull) NSString *networkType;


/**
 The adUnit value
 */
@property (nonatomic, strong, nonnull) NSString *adUnit;



/* source id : app's bundle id */
+ (NSString *_Nonnull)vs_sourceID;


/* vs_platform : platform type / android/ iOS */
+ (NSString *_Nonnull)vs_platform;


/* vs_version : voodoo_sauce version */
+ (NSString *_Nonnull)vs_version;


/* vs_version : voodoo_sauce version */
+ (NSString *_Nonnull)vs_connectivity;


- (instancetype _Nullable )initWithLatency:(NSString *_Nonnull)latency
                               networkType:(NSString *_Nonnull)networkType
                                    adunit:(NSString *_Nonnull)adunit;
@end


