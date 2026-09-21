import UIKit

import netfox

struct NetfoxDebugMenuItem: DebugMenuItem {
    let title = "Netfox (네트워크 로그)"

    func perform(from viewController: UIViewController) {
        NFX.sharedInstance().show()
    }
}
