import UIKit

public extension UIStackView {
    func addArrangedSubview(_ view: UIView, previousSpace: CGFloat = 0) {
        if let lastView = arrangedSubviews.last {
            setCustomSpacing(previousSpace, after: lastView)
        }
        addArrangedSubview(view)
    }
}
