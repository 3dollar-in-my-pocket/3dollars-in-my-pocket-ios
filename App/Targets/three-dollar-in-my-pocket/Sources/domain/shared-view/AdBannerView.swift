import UIKit
import AppTrackingTransparency

import DesignSystem
import AppInterface
import Model

import GoogleMobileAds

class AdBannerView: UIView, AdBannerViewProtocol {
    private var admobView: GADBannerView?
    private let containerView = UIView()
    private let adType: AdType
    private var hasLoadedAd = false

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
        backgroundColor = Colors.gray10.color
        addSubview(containerView)
    }

    private func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func load(in rootViewController: UIViewController) {
        guard !hasLoadedAd else {
            print("⚠️ Ad already loaded for \(adType), skipping")
            return
        }

        hasLoadedAd = true

        // 먼저 프리로드된 배너를 확인
        if let preloadedBanner = AdBannerPreloadManager.shared.getPreloadedBanner(for: adType) {
            attachBanner(preloadedBanner, rootViewController: rootViewController)

            // 다음 사용을 위해 미리 새 배너를 프리로드
            AdBannerPreloadManager.shared.preloadBanner(for: adType, width: frame.width)
        } else {
            // 프리로드된 배너가 없으면 즉시 로드
            loadBannerImmediately(rootViewController: rootViewController)
        }
    }

    func preloadNextBanner() {
        AdBannerPreloadManager.shared.preloadBanner(for: adType, width: frame.width)
    }

    private func loadBannerImmediately(rootViewController: UIViewController) {
        let bannerView = GADBannerView()
        bannerView.adUnitID = Bundle.getAdmobId(adType: adType)
        bannerView.rootViewController = rootViewController
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(frame.width)
        bannerView.delegate = self

        attachBanner(bannerView, rootViewController: rootViewController)
        bannerView.load(GADRequest())

        print("🟡 Loading banner immediately for \(adType)")
    }

    private func attachBanner(_ bannerView: GADBannerView, rootViewController: UIViewController) {
        // 기존 배너 제거
        admobView?.removeFromSuperview()

        admobView = bannerView
        admobView?.rootViewController = rootViewController

        containerView.addSubview(bannerView)
        bannerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        hasLoadedAd = false
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
