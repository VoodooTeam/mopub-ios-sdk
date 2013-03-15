#import "MPHTMLBannerAdapter.h"
#import "MPAdWebView.h"
#import "MPAdConfigurationFactory.h"
#import "MPAdWebViewAgent.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPHTMLBannerAdapterSpec)

describe(@"MPHTMLBannerAdapter", ^{
    __block MPHTMLBannerAdapter *adapter;
    __block id<CedarDouble, MPAdapterDelegate> delegate;
    __block MPAdWebViewAgent *bannerAgent;
    __block MPAdConfiguration *configuration;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPAdapterDelegate));
        configuration = [MPAdConfigurationFactory defaultBannerConfiguration];
    });

    subjectAction(^{
        adapter = [[[MPHTMLBannerAdapter alloc] initWithAdapterDelegate:delegate] autorelease];
        [adapter getAdWithConfiguration:configuration];
        bannerAgent = adapter.bannerAgent;
    });

    describe(@"setting up the bannerAgent", ^{
        __block NSObject *customMethodDelegatePlaceholder;
        beforeEach(^{
            customMethodDelegatePlaceholder = [[[NSObject alloc] init] autorelease];
            delegate stub_method(@selector(adViewDelegate)).and_return(customMethodDelegatePlaceholder);
        });

        it(@"should set up the bannerAgent and banner with the ad configuration", ^{
            bannerAgent.view.loadedHTMLString should equal(@"Publisher's Ad");
        });

        it(@"should set up the customMethodDelegate", ^{
            bannerAgent.customMethodDelegate should equal(customMethodDelegatePlaceholder);
        });
    });

    describe(@"rotating", ^{
        it(@"should tell the banner agent", ^{
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
            [adapter rotateToOrientation:UIInterfaceOrientationLandscapeLeft];
            NSString *JS = bannerAgent.view.executedJavaScripts[0];
            JS should contain(@"return -90");
        });
    });

    describe(@"MPAdWebViewAgentDelegate delegate", ^{
        context(@"when asked for a view controller from which to display modals", ^{
            it(@"should return its delegate's viewControllerForPresentingModalView", ^{
                UIViewController *controller = [[[UIViewController alloc] init] autorelease];
                delegate stub_method(@selector(viewControllerForPresentingModalView)).and_return(controller);
                [adapter viewControllerForPresentingModalView] should equal(controller);
            });
        });

        context(@"when told that the ad did finish loading", ^{
            it(@"should forward the ad to its delegate", ^{
                [adapter adDidFinishLoadingAd:nil];
                delegate should have_received(@selector(adapter:didFinishLoadingAd:shouldTrackImpression:)).with(adapter).and_with(bannerAgent.view).and_with(NO);
            });
        });

        context(@"when told that the ad failed to load", ^{
            it(@"should tell its delegate", ^{
                [adapter adDidFailToLoadAd:nil];
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(nil);
            });
        });

        context(@"when told that the adActionWillBegin", ^{
            it(@"should tell its delegate", ^{
                [adapter adActionWillBegin:nil];
                delegate should have_received(@selector(userActionWillBeginForAdapter:)).with(adapter);
            });
        });

        context(@"when told that the adActionDidFinish", ^{
            it(@"should tell its delegate", ^{
                [adapter adActionDidFinish:nil];
                delegate should have_received(@selector(userActionDidFinishForAdapter:)).with(adapter);
            });
        });

        context(@"when told that the adActionWillLeaveApplication", ^{
            it(@"should tell its delegate", ^{
                [adapter adActionWillLeaveApplication:nil];
                delegate should have_received(@selector(userWillLeaveApplicationFromAdapter:)).with(adapter);
            });
        });
    });

});

SPEC_END