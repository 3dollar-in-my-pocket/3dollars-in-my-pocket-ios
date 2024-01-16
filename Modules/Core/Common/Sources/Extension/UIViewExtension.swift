import UIKit

public extension UIView {
    func addSubViews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
    
    func gesture(_ type: UIGestureRecognizer.GestureType) -> UIGestureRecognizer.GesturePublisher {
        return .init(view: self, gestureType: type)
    }
}
