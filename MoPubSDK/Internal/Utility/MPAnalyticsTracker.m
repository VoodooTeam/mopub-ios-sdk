//
//  MPAnalyticsTracker.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAnalyticsTracker.h"
#import "MPAdConfiguration.h"
#import "MPCoreInstanceProvider.h"
#import "MPHTTPNetworkSession.h"
#import "MPLogging.h"
#import "MPURLRequest.h"
#import "VidCoinSniff.h"

@implementation MPAnalyticsTracker

+ (MPAnalyticsTracker *)sharedTracker
{
    static MPAnalyticsTracker * sharedTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTracker = [[self alloc] init];
    });
    return sharedTracker;
}

- (void)trackImpressionForConfiguration:(MPAdConfiguration *)configuration
{
    // Take the @c impressionTrackingURLs array from @c configuration and use the @c sendTrackingRequestForURLs method
    // to actually send the requests.
    MPLogDebug(@"Tracking impression: %@", configuration.impressionTrackingURLs.firstObject);
    [self sendTrackingRequestForURLs:configuration.impressionTrackingURLs];
    [VidCoinSniff pixelTracker:@"impression" eventUrl:configuration.impressionTrackingURLs];
}

- (void)trackClickForConfiguration:(MPAdConfiguration *)configuration
{
    MPLogDebug(@"Tracking click: %@", configuration.clickTrackingURL);
    MPURLRequest * request = [[MPURLRequest alloc] initWithURL:configuration.clickTrackingURL];
    [MPHTTPNetworkSession startTaskWithHttpRequest:request];
    [VidCoinSniff pixelTracker:@"click" eventUrl:@[configuration.clickTrackingURL]];
}

- (void)sendTrackingRequestForURLs:(NSArray *)URLs
{
    for (NSURL *URL in URLs) {
        MPURLRequest * trackingRequest = [[MPURLRequest alloc] initWithURL:URL];
        [MPHTTPNetworkSession startTaskWithHttpRequest:trackingRequest];
    }
}

@end
