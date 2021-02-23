import UIKit

class StoreDetailMenuEmptyView: BaseView {
  
  let emptyImage = UIImageView().then {
    $0.image = UIImage(named: "img_empty")
  }
  
  
  override func setup() {
    self.backgroundColor = .clear
    self.addSubViews(emptyImage)
  }
  
  override func bindConstraints() {
    self.emptyImage.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.bottom.equalToSuperview().offset(-13)
      make.centerX.equalToSuperview()
    }
  }
}
