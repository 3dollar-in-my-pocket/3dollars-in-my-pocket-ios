import UIKit

class RadioButton: UIButton {
  
  let radioImage = UIImageView().then {
    $0.image = UIImage(named: "ic_radio_off")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.bindConstraint()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    
  }
  
  private func bindConstraint() {
    
  }
}
