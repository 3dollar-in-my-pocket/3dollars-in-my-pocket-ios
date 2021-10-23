import UIKit

final class RatingView: BaseView {
  
  let star1 = UIButton().then {
    $0.setImage(R.image.ic_star_on(), for: .selected)
    $0.setImage(R.image.ic_star_off(), for: .normal)
    $0.isUserInteractionEnabled = false
  }
  
  let star2 = UIButton().then {
    $0.setImage(R.image.ic_star_on(), for: .selected)
    $0.setImage(R.image.ic_star_off(), for: .normal)
    $0.isUserInteractionEnabled = false
  }
  
  let star3 = UIButton().then {
    $0.setImage(R.image.ic_star_on(), for: .selected)
    $0.setImage(R.image.ic_star_off(), for: .normal)
    $0.isUserInteractionEnabled = false
  }
  
  let star4 = UIButton().then {
    $0.setImage(R.image.ic_star_on(), for: .selected)
    $0.setImage(R.image.ic_star_off(), for: .normal)
    $0.isUserInteractionEnabled = false
  }
  
  let star5 = UIButton().then {
    $0.setImage(R.image.ic_star_on(), for: .selected)
    $0.setImage(R.image.ic_star_off(), for: .normal)
    $0.isUserInteractionEnabled = false
  }
  
  let stackView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .leading
    $0.backgroundColor = .clear
  }
  
  override func setup() {
    self.backgroundColor = .clear
    self.stackView.addArrangedSubview(self.star1)
    self.stackView.addArrangedSubview(self.star2)
    self.stackView.addArrangedSubview(self.star3)
    self.stackView.addArrangedSubview(self.star4)
    self.stackView.addArrangedSubview(self.star5)
    self.addSubViews([
      self.stackView
    ])
  }
  
  override func bindConstraints() {
    self.star1.snp.makeConstraints { (make) in
      make.width.height.equalTo(18)
    }
    
    self.star2.snp.makeConstraints { (make) in
      make.width.height.equalTo(18)
    }
    
    self.star3.snp.makeConstraints { (make) in
      make.width.height.equalTo(18)
    }
    
    self.star4.snp.makeConstraints { (make) in
      make.width.height.equalTo(18)
    }
    self.star5.snp.makeConstraints { (make) in
      make.width.height.equalTo(18)
    }
    
    self.stackView.snp.makeConstraints { (make) in
      make.left.top.right.equalTo(self.stackView).priority(.high)
      make.height.equalTo(16)
    }
  }
  
  func bind(rating: Int) {
    for index in 0...stackView.arrangedSubviews.count - 1 {
      if let star = stackView.arrangedSubviews[index] as? UIButton {
        star.isSelected = index < rating
      }
    }
  }
}
