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
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("🟢bannerViewDidReceiveAd")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("🟢didFailToReceiveAdWithError: \(error)")
    }
}
