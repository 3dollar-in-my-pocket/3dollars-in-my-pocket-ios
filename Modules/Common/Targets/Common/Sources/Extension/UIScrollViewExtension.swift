import UIKit

public extension UIScrollView {
    func scrollToTop(animated: Bool = true) {
        let targetContentOffset = CGPoint(
            x: -contentInset.left,
            y: -contentInset.top
        )
        setContentOffset(targetContentOffset, animated: animated)
    }
}
