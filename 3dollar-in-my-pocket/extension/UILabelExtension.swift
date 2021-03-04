import UIKit

extension UILabel {
  
  func setKern(kern: Float) {
    guard let text = self.text else { return }
    let attributedString = NSMutableAttributedString(string: text)
    
    attributedString.addAttribute(.kern, value: kern, range: .init(location: 0, length: text.count))
    
    self.attributedText = attributedString
  }
}
