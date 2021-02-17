import UIKit

class MenuFooterView: BaseView {
  
  let whiteBackground = UIView().then {
    $0.backgroundColor = .white
  }
  
  let grayBackground = UIView().then {
    $0.backgroundColor = UIColor(r: 250, g: 250, b: 250)
  }
  
  override func setup() {
    backgroundColor = .clear
    addSubViews(whiteBackground, grayBackground)
  }
  
  override func bindConstraints() {
    self.whiteBackground.snp.makeConstraints { make in
      make.left.right.top.equalToSuperview()
      make.height.equalTo(10)
    }
    
    self.grayBackground.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.top.equalTo(self.whiteBackground.snp.bottom)
      make.height.equalTo(10)
    }
  }
}
