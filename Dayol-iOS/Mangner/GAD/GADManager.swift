//
//  GADBanner.swift
//  Dayol-iOS
//
//  Created by Seonho Ban on 2021/07/17.
//

import GoogleMobileAds

protocol GADBannerPresentable {
    var adBannerView: UIView { get }
}

final class GADManager: NSObject {
    enum Design {
        static let adBannerHeight: CGFloat = 50
    }

    static func mobileAdsStart(completionHandler: GADInitializationCompletionHandler? = nil) {
        GADMobileAds.sharedInstance().start(completionHandler: completionHandler)
    }

    private var gadBannerUnitID: String {
        // sample ID -> ca-app-pub-3940256099942544/2934735716
        if Config.shared.isProd {
            return "ca-app-pub-5111273163239664/5890972696"
        } else {
            return "ca-app-pub-5111273163239664/5635628307"
        }
    }

    private(set) lazy var gadBannerView: GADBannerView = GADBannerView(adSize: kGADAdSizeBanner)

    func configureBanner(targetViewController: DYViewController, targetView: GADBannerPresentable) {
        gadBannerView.translatesAutoresizingMaskIntoConstraints = false
        gadBannerView.adUnitID = gadBannerUnitID
        gadBannerView.rootViewController = targetViewController
        gadBannerView.delegate = self

        targetView.adBannerView.addSubview(gadBannerView)
        NSLayoutConstraint.activate([
            gadBannerView.topAnchor.constraint(equalTo: targetView.adBannerView.topAnchor),
            gadBannerView.bottomAnchor.constraint(equalTo: targetView.adBannerView.bottomAnchor),
            gadBannerView.centerXAnchor.constraint(equalTo: targetView.adBannerView.centerXAnchor)
        ])

        gadBannerView.load(GADRequest())
    }

    func closeBanner() {
        if let containerView = gadBannerView.superview, !containerView.isHidden {
            UIView.animate(withDuration: 0.5) {
                self.gadBannerView.alpha = 0
            } completion: { _ in
                containerView.isHidden = true
            }
        }
    }
}

// MARK: - BannerView Delegate

extension GADManager: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        DYLog.d(.ad, in: Self.self, value: #function)
        if let containerView = bannerView.superview, containerView.isHidden {
            UIView.animate(withDuration: 1) {
                bannerView.alpha = 1
                containerView.isHidden = false
            }
        } else {
            bannerView.alpha = 0
            UIView.animate(withDuration: 0.5) {
                bannerView.alpha = 1
            }
        }
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        DYLog.d(.ad, in: Self.self, value: "\(#function) | \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        DYLog.d(.ad, in: Self.self, value: #function)
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        DYLog.d(.ad, in: Self.self, value: #function)
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        DYLog.d(.ad, in: Self.self, value: #function)
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        DYLog.d(.ad, in: Self.self, value: #function)
    }
}
