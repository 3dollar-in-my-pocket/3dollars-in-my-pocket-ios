import UIKit

import Model

public protocol AdBannerViewProtocol: AnyObject where Self: UIView {
    func load(_ advertisement: Model.Advertisement?, in rootViewController: UIViewController)
}
