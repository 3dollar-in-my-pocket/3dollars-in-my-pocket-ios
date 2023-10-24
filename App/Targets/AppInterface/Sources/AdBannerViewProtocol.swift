import UIKit

public protocol AdBannerViewProtocol: AnyObject where Self: UIView {
    func load(in rootViewController: UIViewController)
}
