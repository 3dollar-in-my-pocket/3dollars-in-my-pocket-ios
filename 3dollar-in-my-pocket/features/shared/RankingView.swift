import UIKit

class RankingView: BaseView {
  
  let star1 = UIButton().then {
    $0.setImage(UIImage(named: "ic_star_on"), for: .selected)
    $0.setImage(UIImage(named: "ic_star_off"), for: .normal)
    $0.isUserInteractionEnabled = false
  }
  
  let star2 = UIButton().then {
    $0.setImage(UIImage(named: "ic_star_on"), for: .selected)
    $0.setImage(UIImage(named: "ic_star_off"), for: .normal)
    $0.isUserInteractionEnabled = false
  }
  
  let star3 = UIButton().then {
    $0.setImage(UIImage(named: "ic_star_on"), for: .selected)
    $0.setImage(UIImage(named: "ic_star_off"), for: .normal)
    $0.isUserInteractionEnabled = false
  }
  
  let star4 = UIButton().then {
    $0.setImage(UIImage(named: "ic_star_on"), for: .selected)
    $0.setImage(UIImage(named: "ic_star_off"), for: .normal)
    $0.isUserInteractionEnabled = false
  }
  
  let star5 = UIButton().then {
    $0.setImage(UIImage(named: "ic_star_on"), for: .selected)
    $0.setImage(UIImage(named: "ic_star_off"), for: .normal)
    $0.isUserInteractionEnabled = false
  }
  
  let stackView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .leading
    $0.backgroundColor = .clear
    $0.spacing = 2
  }
  
  let rankingLabel = UILabel().then {
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
    $0.textColor = .white
  }
  
  override func setup() {
    self.backgroundColor = .clear
    self.stackView.addArrangedSubview(star1)
    self.stackView.addArrangedSubview(star2)
    self.stackView.addArrangedSubview(star3)
    self.stackView.addArrangedSubview(star4)
    self.stackView.addArrangedSubview(star5)
    self.addSubViews(stackView, rankingLabel)
  }
  
  override func bindConstraints() {
    self.star1.snp.makeConstraints { make in
      make.width.height.equalTo(14)
    }
    
    self.star2.snp.makeConstraints { make in
      make.width.height.equalTo(14)
    }
    
    self.star3.snp.makeConstraints { make in
      make.width.height.equalTo(14)
    }
    
    self.star4.snp.makeConstraints { make in
      make.width.height.equalTo(14)
    }
    
    self.star5.snp.makeConstraints { make in
      make.width.height.equalTo(14)
    }
    
    self.stackView.snp.makeConstraints { make in
      make.left.centerY.equalToSuperview()
    }
    
    self.rankingLabel.snp.makeConstraints { make in
      make.left.equalTo(self.stackView.snp.right).offset(9)
      make.centerY.equalTo(self.stackView).offset(2)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.stackView.sizeToFit()
  }
  
  func setRank(rank: Float) {
    let roundedRank = Int(rank.rounded())
    
    for index in 0...stackView.arrangedSubviews.count - 1 {
      if let star = stackView.arrangedSubviews[index] as? UIButton {
        star.isSelected = index < roundedRank
      }
    }
    self.rankingLabel.text = "\(rank)점"
  }
}
