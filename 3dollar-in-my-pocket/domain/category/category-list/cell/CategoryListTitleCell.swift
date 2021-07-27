import UIKit

class CategoryListTitleCell: BaseTableViewCell {
  
  static let registerId = "\(CategoryListTitleCell.self)"
  
  let categoryTitleLabel = UILabel().then {
    $0.font = UIFont(name: "AppleSDGothicNeo-Light", size: 24)
    $0.textColor = .black
    $0.numberOfLines = 0
  }
  
  let distanceOrderButton = UIButton().then {
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
    self.addSubViews(reviewOrderButton, distanceOrderButton, categoryTitleLabel)
  }
  
  override func bindConstraints() {
    self.categoryTitleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-129)
      make.top.equalToSuperview().offset(48)
      make.bottom.equalToSuperview().offset(-33)
    }
    
    self.reviewOrderButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalTo(self.categoryTitleLabel)
    }
    
    self.distanceOrderButton.snp.makeConstraints { make in
      make.bottom.equalTo(self.reviewOrderButton)
      make.right.equalToSuperview().offset(-75)
    }
  }
  
  func bind(category: StoreCategory) {
    let text = "category_list_\(category.lowcase)".localized
    let attributedString = NSMutableAttributedString(string: text)
    let boldTextRange = (text as NSString).range(of: "shared_category_\(category.lowcase)".localized)
    
    attributedString.addAttribute(
      .font,
      value: UIFont(name: "AppleSDGothicNeoEB00", size: 24)!,
      range: boldTextRange
    )
    self.categoryTitleLabel.attributedText = attributedString
  }
  
  func onTapOrderButton(order: CategoryOrder) {
    self.distanceOrderButton.isSelected = order == .distance
    self.reviewOrderButton.isSelected = order == .review
  }
}
