import UIKit

class CategoryListTitleCell: BaseTableViewCell {
  
  static let registerId = "\(CategoryListTitleCell.self)"
  
  let categoryTitleLabel = UILabel().then {
    $0.font = UIFont(name: "AppleSDGothicNeoEB00", size: 24)
    $0.textColor = .black
    $0.text = "붕어빵 만나기 30초 전"
  }
  
  let nearOrderButton = UIButton().then {
    $0.setTitle("category_ordering_distance".localized, for: .normal)
    $0.setTitleColor(.black, for: .selected)
    $0.setTitleColor(UIColor.init(r: 189, g: 189, b: 189), for: .normal)
    $0.isSelected = true
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
  }
  
  let reviewOrderButton = UIButton().then {
    $0.setTitle("category_ordering_review".localized, for: .normal)
    $0.setTitleColor(.black, for: .selected)
    $0.setTitleColor(UIColor.init(r: 189, g: 189, b: 189), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
  }
  
  
  override func setup() {
    self.backgroundColor = .clear
    self.selectionStyle = .none
    self.contentView.isUserInteractionEnabled = false
    self.addSubViews(reviewOrderButton, nearOrderButton, categoryTitleLabel)
  }
  
  override func bindConstraints() {
    self.categoryTitleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalTo(self.reviewOrderButton.snp.left).offset(-19)
      make.top.equalToSuperview().offset(48)
      make.bottom.equalToSuperview().offset(-33)
    }
    
    self.reviewOrderButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalTo(self.categoryTitleLabel)
    }
    
    self.nearOrderButton.snp.makeConstraints { make in
      make.bottom.equalTo(self.reviewOrderButton)
      make.right.equalTo(self.reviewOrderButton.snp.left).offset(-16)
    }
  }

}
