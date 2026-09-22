import UIKit

import Common

protocol DebugMenuItem {
    var title: String { get }
    func perform(from viewController: UIViewController)
}
