import UIKit

public protocol AdBannerViewProtocol: AnyObject where Self: UIView {
    var isLoaded: Bool { get set }
    func load(in rootViewController: UIViewController)
}
