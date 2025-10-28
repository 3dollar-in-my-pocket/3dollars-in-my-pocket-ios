import UIKit

public protocol AdBannerViewProtocol: AnyObject where Self: UIView {
    var isLoaded: Bool { get }
    func load(in rootViewController: UIViewController)
}
