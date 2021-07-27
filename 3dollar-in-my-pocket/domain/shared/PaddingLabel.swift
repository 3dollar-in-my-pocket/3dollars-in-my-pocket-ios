import UIKit

class PaddingLabel: UILabel {
  
  let topInset: CGFloat
  let bottomInset: CGFloat
  let leftInset: CGFloat
  let rightInset: CGFloat
  
  
  init(topInset: CGFloat, bottomInset: CGFloat, leftInset: CGFloat, rightInset: CGFloat) {
    self.topInset = topInset
    self.bottomInset = bottomInset
    self.leftInset = leftInset
    self.rightInset = rightInset
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets(
      top: topInset,
      left: leftInset,
      bottom: bottomInset,
      right: rightInset
    )
    super.drawText(in: rect.inset(by: insets))
  }
  
  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(width: size.width + leftInset + rightInset,
                  height: size.height + topInset + bottomInset)
  }
  
  override var bounds: CGRect {
    didSet {
      // ensures this works within stack views if multi-line
      preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
    }
  }
}
