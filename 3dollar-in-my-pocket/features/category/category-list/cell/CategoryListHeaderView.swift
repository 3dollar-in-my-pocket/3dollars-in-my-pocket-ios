import UIKit

class CategoryListHeaderView: BaseView {
  
  let headerImage = UIImageView().then {
    $0.image = UIImage(named: "ic_near_filled")
  }
  
  let headerLabel = UILabel().then {
    $0.text = "Header"
    $0.font = UIFont(name: "AppleSDGothicNeoEB00", size: 14)
    $0.textColor = UIColor(r: 255, g: 161, b: 170)
  }
  
  
  override func setup() {
    self.backgroundColor = .clear
    self.addSubViews(headerImage, headerLabel)
  }
  
  override func bindConstraints() {
    self.headerImage.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(7)
      make.bottom.equalToSuperview().offset(-7)
      make.width.height.equalTo(16)
    }
    
    self.headerLabel.snp.makeConstraints { make in
      make.left.equalTo(self.headerImage.snp.right).offset(8)
      make.right.equalToSuperview().offset(-24)
      make.centerY.equalTo(self.headerImage)
    }
  }
  
  func bind(type: CategoryHeaderType?) {
    if let type = type {
      switch type {
      case .distance50, .distance100, .distance500, .distance1000, .distanceOver1000:
        self.headerImage.image = UIImage(named: "ic_near_filled")
        self.headerLabel.text = "category_list_header_\(type.rawValue)".localized
      case .review0, .review1, .review2, .review3, .review4:
        self.headerImage.image = UIImage(named: "ic_star")
        self.headerLabel.text = "category_list_header_\(type.rawValue)".localized
      default:
        break
      }
    }
  }
}
