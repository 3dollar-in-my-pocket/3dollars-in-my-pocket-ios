import UIKit

import Model

import GoogleMobileAds

final class AdBannerPreloadManager {
    static let shared = AdBannerPreloadManager()

    private var preloadedBanners: [AdType: GADBannerView] = [:]
    private let queue = DispatchQueue(label: "com.threedollars.adBannerPreload", qos: .userInitiated)
    private var isPreloadingInProgress: Set<AdType> = []

    private init() {}

    /// 특정 AdType의 배너 광고를 미리 로드합니다
    func preloadBanner(for adType: AdType, width: CGFloat) {
        queue.async { [weak self] in
            guard let self = self else { return }

            // 이미 프리로딩 중이거나 프리로드된 배너가 있으면 스킵
            if self.isPreloadingInProgress.contains(adType) || self.preloadedBanners[adType] != nil {
                return
            }

            self.isPreloadingInProgress.insert(adType)

            DispatchQueue.main.async {
                let bannerView = GADBannerView()
                bannerView.adUnitID = Bundle.getAdmobId(adType: adType)
                bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
                bannerView.delegate = self
                bannerView.load(GADRequest())

                print("🟡 Preloading banner for \(adType)")
            }
        }
    }

    /// 프리로드된 배너를 가져옵니다. 없으면 nil 반환
    func getPreloadedBanner(for adType: AdType) -> GADBannerView? {
        var banner: GADBannerView?
        queue.sync {
            banner = preloadedBanners[adType]
            preloadedBanners[adType] = nil
        }

        if banner != nil {
            print("🟢 Using preloaded banner for \(adType)")
        }

        return banner
    }

    /// 특정 AdType의 프리로드된 배너를 제거합니다
    func clearPreloadedBanner(for adType: AdType) {
        queue.async { [weak self] in
            self?.preloadedBanners[adType] = nil
            print("🔴 Cleared preloaded banner for \(adType)")
        }
    }

    /// 모든 프리로드된 배너를 제거합니다
    func clearAllPreloadedBanners() {
        queue.async { [weak self] in
            self?.preloadedBanners.removeAll()
            print("🔴 Cleared all preloaded banners")
        }
    }
}

extension AdBannerPreloadManager: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        queue.async { [weak self] in
            guard let self = self,
                  let adUnitID = bannerView.adUnitID,
                  let adType = self.getAdType(from: adUnitID) else {
                return
            }

            self.preloadedBanners[adType] = bannerView
            self.isPreloadingInProgress.remove(adType)

            DispatchQueue.main.async {
                print("🟢 Preloaded banner ready for \(adType)")
            }
        }
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        queue.async { [weak self] in
            guard let self = self,
                  let adUnitID = bannerView.adUnitID,
                  let adType = self.getAdType(from: adUnitID) else {
                return
            }

            self.isPreloadingInProgress.remove(adType)

            DispatchQueue.main.async {
                print("🔴 Failed to preload banner for \(adType): \(error.localizedDescription)")
            }
        }
    }

    private func getAdType(from adUnitID: String) -> AdType? {
        return AdType.allCases.first { Bundle.getAdmobId(adType: $0) == adUnitID }
    }
}
