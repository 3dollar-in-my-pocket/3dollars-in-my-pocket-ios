import UIKit
import AppTrackingTransparency

import DesignSystem
import AppInterface
import Model

import GoogleMobileAds

class AdBannerView: UIView, AdBannerViewProtocol {
    let admobView = BannerView()
    
    private let adType: AdType
    
    var isLoaded: Bool = false
    
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
        guard isLoaded.isNot else { return }
        admobView.rootViewController = rootViewController
        admobView.adSize = currentOrientationAnchoredAdaptiveBanner(width: frame.width)
        admobView.delegate = self
        admobView.load(Request())
    }
}

extension AdBannerView: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        isLoaded = true
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        isLoaded = false
    }
}
