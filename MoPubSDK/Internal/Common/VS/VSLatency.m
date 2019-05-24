//
//  VSLatency.m
//  MoPubSDK
//
//  Created by sarra_srairi on 03/05/2019.
//  Copyright © 2019 MoPub. All rights reserved.
//

#import "VSLatency.h"
#import "MPAdConfiguration.h"
#import "MPConsentManager.h"
#import "MPIdentityProvider.h"
#import <AdSupport/ASIdentifierManager.h>
#import "MPReachabilityManager.h"

#pragma mark - static values
#define vsplatform                      @"ios"
#define vsversion                       @"3.5.0"
#define kLatency                        @"kLatencyVS"
#define kunitType                       @"VS_UNIT_TYPE"

@implementation VSLatency


- (instancetype)initWithLatency:(double)latency 
{
    self = [super init];
    if (self) {
        self.latencyMs = latency;
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


- (NSString *)vs_className:(NSString *)className{
    
    // Admob
    if (    [className isEqualToString:@"MPGoogleAdMobBannerCustomEvent"] ||
            [className isEqualToString:@"MPGoogleAdMobInterstitialCustomEvent"]  ||
            [className isEqualToString:@"MPGoogleAdMobRewardedVideoCustomEvent"]){
        return @"AdMob";
    }
    
    // AppLovin
    if (    [className isEqualToString:@"AppLovinBannerCustomEvent"] ||
            [className isEqualToString:@"AppLovinInterstitialCustomEvent"]  ||
            [className isEqualToString:@"AppLovinRewardedVideoCustomEvent"]){
        return @"AppLovin";
    }
    
    // IronSource
    if (    [className isEqualToString:@"IronSourceInterstitialCustomEvent"] ||
            [className isEqualToString:@"IronSourceRewardedVideoCustomEvent"]){
        return @"IronSource";
    }
    
    // Vungle
    if (    [className isEqualToString:@"VungleInterstitialCustomEvent"] ||
            [className isEqualToString:@"VungleRewardedVideoCustomEvent"]){
        return @"Vungle";
    }

    // Tapjoy
    if (    [className isEqualToString:@"TapjoyInterstitialCustomEvent"] ||
            [className isEqualToString:@"TapjoyInterstitialCustomEvent"]){
        return @"Tapjoy";
    }
    
    // UnityAds
    if (    [className isEqualToString:@"UnityAdsBannerCustomEvent"] ||
            [className isEqualToString:@"UnityAdsInterstitialCustomEvent"] ||
            [className isEqualToString:@"UnityAdsRewardedVideoCustomEvent"]){
        return @"UnityAds";
    }
    
    // VoodooAds
    if (    [className isEqualToString:@"VABannerCustomEvent"] ||
            [className isEqualToString:@"VAInterstitialCustomEvent"] ||
            [className isEqualToString:@"VARewardedCustomEvent"] ||
            [className isEqualToString:@"VidcoinInterstitialCustomEvent"] ||
            [className isEqualToString:@"VidcoinRewardedVideoCustomEvent"]
        ){
        return @"VoodooAds";
    }
    
    // Faceboook
    if (    [className isEqualToString:@"FacebookBannerCustomEvent"] ||
            [className isEqualToString:@"FacebookInterstitialCustomEvent"] ||
            [className isEqualToString:@"FacebookRewardedVideoCustomEvent"]
        ){
        return @"Faceboook";
        
    }
    
    // AdColony
    if (    [className isEqualToString:@"AdColonyInterstitialCustomEvent"] ||
            [className isEqualToString:@"AdColonyRewardedVideoCustomEvent"]
        ){
        return @"AdColony";
    }
    
    // AppOnboard
    if (    [className isEqualToString:@"AppOnboardInterstitialCustomEvent"] ||
            [className isEqualToString:@"AppOnboardRewardedVideoCustomEvent"]
        ){
        return @"AppOnboard";
    }
    
    // Mintegral
    if (    [className isEqualToString:@"MintegralInterstitialVideoCustomEvent"] ||
            [className isEqualToString:@"MobvistaRewardVideoCustomEvent"]
        ){
        return @"Mintegral";
    }
    
    // InMobi
    if (    [className isEqualToString:@"InMobiBannerCustomEvent"] ||
            [className isEqualToString:@"InMobiInterstitialCustomEvent"]||
            [className isEqualToString:@"InMobiRewardedCustomEvent"]
        ){
        return @"InMobi";
    }
    
    // ByteDance
    if (    [className isEqualToString:@"BUDMopub_BannerCustomEvent"] ||
            [className isEqualToString:@"BUDMopub_FullscreenVideoCustomEvent"]||
            [className isEqualToString:@"BUDMopub_RewardedVideoCustomEvent"]
        ){
        return @"ByteDance";
    }
    
    //Fyber
    if (    [className isEqualToString:@"InneractiveBannerCustomEvent"] ||
            [className isEqualToString:@"InneractiveInterstitialCustomEvent"]||
            [className isEqualToString:@"InneractiveRewardedVideoCustomEvent"]
        ){
        return @"Fyber";
    }
    
    //IQzone
    if (    [className isEqualToString:@"IMDBannerCustomEvent"] ||
            [className isEqualToString:@"IMDInterstitialCustomEvent"]||
            [className isEqualToString:@"IMDRewardedVideoCustomEvent"]
        ){
        return @"IQzone";
    }
    
    //MobFox
    if (    [className isEqualToString:@"MoPubAdapterMobFox"] ||
            [className isEqualToString:@"MoPubInterstitialAdapterMobFox"]
        ){
        return @"MobFox";
    }
    
    //Chartbooast
    if (    [className isEqualToString:@"ChartboostInterstitialCustomEvent"] ||
            [className isEqualToString:@"ChartboostRewardedVideoCustomEvent"]
        ){
        return @"Chartboost";
    }
    
    //Millennial
    if (    [className isEqualToString:@"MPMillennialBannerCustomEvent"] ||
            [className isEqualToString:@"MPMillennialInterstitialCustomEvent"]
        ){
        return @"Millennialmedia";
    }
    
    return className;
}


+ (NSString *)vs_connectivity{
    
//    NSURL *scriptUrl = [NSURL URLWithString:@"http://www.google.com/m"];
//    NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
//
//    if (data){
    // add rechability
        switch (MPReachabilityManager.sharedManager.currentStatus) {
            case 0:
                return @"UNKNOWN";
                break;
                
            case 2:
                return @"WIFI";
                break;
                
            case 4:
                return @"2G";
                break;
                
            case 5:
                return @"3G";
                break;
                
            case 6:
                return @"4G";
                break;
                
            default:
                return @"NOT_REACHABLE";
        }
    
}


#define kDefaultUUID @"00000000-0000-0000-0000-000000000000"
+ (NSString *)vs_userID{
    
    if (MPIdentityProvider.advertisingTrackingEnabled && [MPConsentManager sharedManager].canCollectPersonalInfo) {
        return  [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] ?: kDefaultUUID;
    }
    return kDefaultUUID;
}


+ (NSString *)formatUnitfromType:(VSUnitFormat)endpoint {
    switch (endpoint) {
            
        case VS_FS:
            return @"INTERSTITIAL";
            break;
            
        case VS_RV:
            return @"REWARDED_VIDEO";
            break;
            
        case VS_BANNER:
            return @"BANNER";
            break;
            
        case VS_NATIVE:
            return @"NATIVE";
            break;
    }
}

@end
