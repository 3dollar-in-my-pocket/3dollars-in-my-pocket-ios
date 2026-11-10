import UIKit
import AppTrackingTransparency

import DesignSystem
import AppInterface
import Model

import GoogleMobileAds

class AdBannerView: UIView, AdBannerViewProtocol {
    let admobView = BannerView()
    
    private let adType: AdType
    private let defaultAdUnitId: String
    
    var isLoaded: Bool = false
    var onClick: (() -> Void)?
    var onLoadFailed: (() -> Void)?
    
    required init(adType: AdType) {
        self.adType = adType
        self.defaultAdUnitId = Bundle.getAdmobId(adType: adType)
        super.init(frame: .zero)
        
        setup()
        bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        admobView.adUnitID = defaultAdUnitId
        backgroundColor = Colors.gray10.color
        addSubview(admobView)
    }
    
    func setServerAdUnitId(_ adUnitId: String?) {
        let resolvedAdUnitId = AdUnitIdResolver.resolve(
            serverAdUnitId: adUnitId,
            fallback: defaultAdUnitId,
            usesServerAdUnitId: Self.usesServerAdUnitId
        )
        guard admobView.adUnitID != resolvedAdUnitId else { return }
        admobView.adUnitID = resolvedAdUnitId
        isLoaded = false
    }

    private static var usesServerAdUnitId: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
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
        retryWithDefaultAdUnitIfNeeded(bannerView)
    }

    private func retryWithDefaultAdUnitIfNeeded(_ bannerView: BannerView) {
        guard let retryAdUnitId = AdUnitIdResolver.retryAdUnitId(
            afterFailureOf: bannerView.adUnitID,
            fallback: defaultAdUnitId
        ) else {
            onLoadFailed?()
            return
        }

        bannerView.adUnitID = retryAdUnitId
        bannerView.load(Request())
    }

    func bannerViewDidRecordClick(_ bannerView: BannerView) {
        onClick?()
    }
}
