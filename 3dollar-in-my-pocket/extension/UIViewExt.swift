import UIKit

extension UIView {
  
  func addSubViews(_ views: UIView...) {
    for view in views {
      self.addSubview(view)
    }
  }
  
  func addSubViews(_ views: [UIView]) {
    for view in views {
      self.addSubview(view)
    }
  }
}
