import UIKit

import AppInterface

final class MockAdBannerView: UIView, AdBannerViewProtocol {
    var isLoaded = true
    var onClick: (() -> Void)?
    func load(in rootViewController: UIViewController) { }
    func load(in rootViewController: UIViewController, size: CGSize) { }
}
