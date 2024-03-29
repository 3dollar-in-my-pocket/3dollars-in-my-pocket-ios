import UIKit
import AppTrackingTransparency

import DesignSystem
import AppInterface
import Model

import GoogleMobileAds

class AdBannerView: UIView, AdBannerViewProtocol {
    let admobView: GADBannerView = {
        let view = GADBannerView()
        
        return view
    }()
    
    private let adType: AdType
    
    required init(adType: AdType) {
        self.adType = adType
        super.init(frame: .zero)
        
        setup()
        bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        admobView.adUnitID = Bundle.getAdmobId(adType: adType)
        backgroundColor = Colors.gray10.color
        addSubview(admobView)
    }
    
    private func bindConstraints() {
        admobView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func load(in rootViewController: UIViewController) {
        admobView.rootViewController = rootViewController
        admobView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(frame.width)
        admobView.delegate = self
        admobView.load(GADRequest())
    }
}

extension AdBannerView: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("💚adViewDidReceiveAd")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("💚adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("💚adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("💚adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("💚adViewWillLeaveApplication")
    }
}
