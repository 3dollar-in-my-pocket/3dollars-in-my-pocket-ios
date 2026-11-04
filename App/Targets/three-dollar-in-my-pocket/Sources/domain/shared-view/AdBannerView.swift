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
    var onClick: (() -> Void)?
    
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
            $0.top.bottom.centerX.equalToSuperview()
            $0.width.equalToSuperview().priority(.high)
            $0.width.lessThanOrEqualTo(Self.maxBannerWidth)
        }
    }
    
    func load(in rootViewController: UIViewController) {
        load(in: rootViewController, adSize: currentOrientationAnchoredAdaptiveBanner(width: min(frame.width, Self.maxBannerWidth)))
    }

    func load(in rootViewController: UIViewController, size: CGSize) {
        load(in: rootViewController, adSize: inlineAdaptiveBanner(width: min(size.width, Self.maxBannerWidth), maxHeight: size.height))
    }

    private static var maxBannerWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    private func load(in rootViewController: UIViewController, adSize: AdSize) {
        guard isLoaded.isNot else { return }
        admobView.rootViewController = rootViewController
        admobView.adSize = adSize
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
        AdMobErrorReporter.report(
            adType: adType,
            unitId: bannerView.adUnitID ?? "",
            from: bannerView.rootViewController,
            error: error
        )
    }

    func bannerViewDidRecordClick(_ bannerView: BannerView) {
        onClick?()
    }
}
