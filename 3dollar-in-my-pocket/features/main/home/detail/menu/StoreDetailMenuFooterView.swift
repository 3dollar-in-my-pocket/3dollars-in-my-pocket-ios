import UIKit

class StoreDetailMenuFooterView: BaseView {
  
  let footerView = UIView()
  
  override func setup() {
    backgroundColor = .clear
    addSubViews(footerView)
  }
  
  override func bindConstraints() {
    self.footerView.snp.makeConstraints { make in
      make.left.right.top.bottom.equalToSuperview()
      make.height.equalTo(19)
    }
  }
}
