// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import GoogleMobileAds

class GoogleAdService: NSObject, AdService {

    /// Ad struct
    struct AdInfo {
        /// The ad loader. You must keep a strong reference to the GADAdLoader
        /// during the ad loading process.
        var adLoader:     GADAdLoader

        /// The native ad view that is being presented.
        var nativeAdView: GADNativeAdView
    }

    /// All add infos for all native ad views
    private var adInfos:        [AdInfo?] = [nil, nil, nil]

    /// Injections
    private let viewController: UIViewController
    private let sensitives:     GoogleAdSensitives

    /// Construction with dependencies
    init(with mainViewController: MainViewController,
         googleAdSensitives: GoogleAdSensitives) {
        viewController = mainViewController.viewController
        sensitives = googleAdSensitives
        GADMobileAds.sharedInstance().start(completionHandler: { status in
            Log.i("Google ads initialized: \(status.adapterStatusesByClassName)")
        })
    }

    /// Show full screen google add
    func showFullscreenAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: sensitives.AdUnitIdFullscreen,
                               request: request,
                               completionHandler: { [weak self] ad, error in
                                   guard let self = self else { return }
                                   if let error = error {
                                       Log.e("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                       return
                                   }
                                   ad?.present(fromRootViewController: self.viewController)
                               })
    }

    /// Create new ad info
    private func createNewAdInfo(for parentView: UIView) -> AdInfo {
        let newInfo = AdInfo(adLoader: GADAdLoader(adUnitID: sensitives.AdUnitIdNative,
                                                   rootViewController: viewController,
                                                   adTypes: [.native],
                                                   options: nil),
                             nativeAdView: Bundle.main.loadNibNamed("GoogleAdNativeAdView", owner: nil)?.first as! GADNativeAdView)
        newInfo.adLoader.delegate = self
        parentView.addSubview(newInfo.nativeAdView)
        newInfo.nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        newInfo.nativeAdView.fillParent()
        newInfo.nativeAdView.alpha = 0
        return newInfo
    }

    /// Remove existing ad at index
    private func removeAdAt(index: Int, completion: @escaping () -> Void) {
        guard let adInfo = adInfos[safe: index],
              let info = adInfo else {
            completion()
            return
        }
        info.nativeAdView.fadeOut { [weak self] in
            guard let self = self else { return }
            info.nativeAdView.removeFromSuperview()
            self.adInfos[index] = nil
            completion()
        }
    }

    /// Show google ad inside a give view
    func showAd(in parentView: UIView, at index: Int) {
        // 1. Remove existing ad
        removeAdAt(index: index) { [weak self] in
            guard let self = self else { return }
            // 2. Create new ad
            let newAd = self.createNewAdInfo(for: parentView)
            assert(self.adInfos[index] == nil)
            self.adInfos[index] = newAd
            // 3. trigger loading
            newAd.adLoader.load(GADRequest())

        }
    }
}

extension GoogleAdService: GADNativeAdLoaderDelegate {

    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        Log.e("Error loading ad: \(error.localizedDescription)")
    }


    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        guard let adInfo = adInfos.first(where: { savedInfo in adLoader == savedInfo?.adLoader }),
              let info = adInfo else {
            Log.e("Could not find the right info: \(adInfos) for \(adLoader)")
            return
        }
        // Set ourselves as the native ad delegate to be notified of native ad events.
        nativeAd.delegate = self

        // Populate the native ad view with the native ad assets.
        // The headline and mediaContent are guaranteed to be present in every native ad.
        (info.nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        info.nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent

        // These assets are not guaranteed to be present. Check that they are before
        // showing or hiding them.
        (info.nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        info.nativeAdView.bodyView?.isHidden = nativeAd.body == nil

        (info.nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        info.nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil

        (info.nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        info.nativeAdView.iconView?.isHidden = nativeAd.icon == nil

        (info.nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
        info.nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil

        (info.nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        info.nativeAdView.storeView?.isHidden = nativeAd.store == nil

        (info.nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        info.nativeAdView.priceView?.isHidden = nativeAd.price == nil

        (info.nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        info.nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil

        // In order for the SDK to process touch events properly, user interaction should be disabled.
        info.nativeAdView.callToActionView?.isUserInteractionEnabled = false

        // Associate the native ad view with the native ad object. This is
        // required to make the ad clickable.
        // Note: this should always be done after populating the ad views.
        info.nativeAdView.nativeAd = nativeAd

        info.nativeAdView.fadeIn()
    }

    /// Returns a `UIImage` representing the number of stars from the given star rating; returns `nil`
    /// if the star rating is less than 3.5 stars.
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }
        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        } else {
            return nil
        }
    }
}

// MARK: - GADUnifiedNativeAdDelegate implementation
extension GoogleAdService: GADNativeAdDelegate {

    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        Log.i("\(#function) called")
    }

    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        Log.i("\(#function) called")
    }

    func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
        Log.i("\(#function) called")
    }

    func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
        Log.i("\(#function) called")
    }

    func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        Log.i("\(#function) called")
    }

    func nativeAdWillLeaveApplication(_ nativeAd: GADNativeAd) {
        Log.i("\(#function) called")
    }
}
