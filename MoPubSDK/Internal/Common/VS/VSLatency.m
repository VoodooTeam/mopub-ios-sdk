//
//  VSLatency.m
//  MoPubSDK
//
//  Created by sarra_srairi on 03/05/2019.
//  Copyright © 2019 MoPub. All rights reserved.
//

#import "VSLatency.h"
#import "MPAdConfiguration.h"

#pragma mark - static values
#define vsplatform                      @"iOS"
#define vsversion                       @"3.5.0"
#define kLatency                        @"kLatencyVS"


@implementation VSLatency

- (instancetype)initWithLatency:(NSString *)latency
                    networkType:(NSString *)networkType
                         adunit:(NSString *)adunit
{
    self = [super init];
    if (self) {
        self.latencyMs = latency;
        self.networkType = networkType;
        self.adUnit = adunit;
    }
    return self;
}

+ (NSString *)vs_sourceID{
    return [[NSBundle mainBundle] bundleIdentifier];
}


+ (NSString *)vs_platform{
    return vsplatform;
}


+ (NSString *)vs_version{
    return vsversion;
}


+ (NSString *)vs_connectivity{
    
    NSURL *scriptUrl = [NSURL URLWithString:@"http://www.google.com/m"];
    NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
    if (data)
        // add rechability
        return  @"WIFI";
    else
        return  @"not rechable";
}

@end
