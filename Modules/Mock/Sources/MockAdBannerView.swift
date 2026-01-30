import UIKit

import AppInterface

final class MockAdBannerView: UIView, AdBannerViewProtocol {
    var isLoaded = true
    func load(in rootViewController: UIViewController) { }
}
