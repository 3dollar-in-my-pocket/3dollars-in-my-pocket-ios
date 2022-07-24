import UIKit

import Base

class FAQTagCell: BaseCollectionViewCell {
  
  static let registerId = "\(FAQTagCell.self)"
  
  let bgView = UIView().then {
    $0.backgroundColor = .clear
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 130, g: 130, b: 130).cgColor
    $0.layer.cornerRadius = 16
    $0.layer.masksToBounds = true
  }
  
  let tagLabel = UILabel().then {
    $0.textColor = UIColor(r: 130, g: 130, b: 130)
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14 * RatioUtils.widthRatio)
  }
  
  override func setup() {
    backgroundColor = .clear
    addSubViews(bgView, tagLabel)
  }
  
  override func bindConstraints() {
    self.tagLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(12 * RatioUtils.widthRatio)
      make.right.equalToSuperview().offset(-12 * RatioUtils.widthRatio)
      make.height.equalTo(30 * RatioUtils.widthRatio)
      make.top.bottom.equalToSuperview()
    }
    
    self.bgView.snp.makeConstraints { make in
      make.edges.equalTo(0)
    }
  }
  
  func bind(name: String) {
    self.tagLabel.text = name
  }
  
  func setSelect(isSelected: Bool) {
    if isSelected {
      self.bgView.backgroundColor = UIColor(r: 238, g: 98, b: 76)
      self.bgView.layer.borderWidth = 0
      self.tagLabel.textColor = .white
    } else {
      self.bgView.backgroundColor = .clear
      self.bgView.layer.borderColor = UIColor(r: 130, g: 130, b: 130).cgColor
      self.bgView.layer.borderWidth = 1
      self.tagLabel.textColor = UIColor(r: 130, g: 130, b: 130)
    }
  }
}
