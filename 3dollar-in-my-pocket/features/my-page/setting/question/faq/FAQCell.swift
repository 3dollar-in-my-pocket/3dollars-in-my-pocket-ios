import UIKit

class FAQCell: BaseTableViewCell {
  
  static let registerId = "\(FAQCell.self)"
  
  let bgView = UIView().then {
    $0.backgroundColor = UIColor(r: 46, g: 46, b: 46)
    $0.layer.cornerRadius = 16
    $0.layer.masksToBounds = true
  }
  
  let qLabel = UILabel().then {
    $0.text = "Q."
    $0.font = UIFont(name: "SpoqaHanSans-Bold", size: 14)
    $0.textColor = UIColor(r: 243, g: 162, b: 169)
  }
  
  let questionLabel = UILabel().then {
    $0.font = UIFont(name: "SpoqaHanSans-Bold", size: 14)
    $0.textColor = UIColor(r: 243, g: 162, b: 169)
    $0.textAlignment = .left
    $0.numberOfLines = 0
  }
  
  let answerLabel = UILabel().then {
    $0.font = UIFont(name: "SpoqaHanSans-Regular", size: 14)
    $0.textColor = UIColor(r: 242, g: 242, b: 242)
    $0.textAlignment = .left
    $0.numberOfLines = 0
  }
  
  
  override func setup() {
    selectionStyle = .none
    backgroundColor = .clear
    addSubViews(bgView, qLabel, questionLabel, answerLabel)
  }
  
  override func bindConstraints() {
    self.bgView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24 * RatioUtils.widthRatio)
      make.right.equalToSuperview().offset(-24 * RatioUtils.widthRatio)
      make.top.equalToSuperview().offset(8)
      make.bottom.equalTo(self.answerLabel).offset(16)
      make.bottom.equalToSuperview().offset(-8)
    }
    
    self.qLabel.snp.makeConstraints { make in
      make.left.equalTo(self.bgView).offset(16)
      make.top.equalTo(self.questionLabel)
    }
    
    self.questionLabel.snp.makeConstraints { make in
      make.left.equalTo(self.bgView).offset(38)
      make.right.equalTo(self.bgView).offset(-18)
      make.top.equalTo(self.bgView).offset(16)
    }
    
    self.answerLabel.snp.makeConstraints { make in
      make.left.right.equalTo(self.questionLabel)
      make.top.equalTo(self.questionLabel.snp.bottom).offset(12)
    }
  }
  
  func bind(faq: FAQ) {
    self.questionLabel.text = faq.question
    self.answerLabel.text = faq.answer
  }
}
