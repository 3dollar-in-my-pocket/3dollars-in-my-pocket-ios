import UIKit

import AppInterface

final class MockAdBannerView: UIView, AdBannerViewProtocol {
    func load(in rootViewController: UIViewController) { }

    func preloadNextBanner() { }

    func prepareForReuse() { }
}
