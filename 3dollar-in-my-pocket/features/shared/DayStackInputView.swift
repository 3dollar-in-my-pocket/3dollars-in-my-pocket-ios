import UIKit

class DayStackInputView: UIStackView {
  
  let sundayButton = UIButton().then {
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_sunday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
    $0.layer.cornerRadius = CGFloat(18)
  }
  
  let mondayButton = UIButton().then {
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_monday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
    $0.layer.cornerRadius = CGFloat(18)
  }
  
  let tuesdayButton = UIButton().then {
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_tuesday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
    $0.layer.cornerRadius = CGFloat(18)
  }
  
  let wednesday = UIButton().then {
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_wednesday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
    $0.layer.cornerRadius = CGFloat(18)
  }
  
  let thursday = UIButton().then {
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_thursday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
    $0.layer.cornerRadius = CGFloat(18)
  }
  
  let friday = UIButton().then {
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_friday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
    $0.layer.cornerRadius = CGFloat(18)
  }
  
  let saturday = UIButton().then {
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_saturday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
    $0.layer.cornerRadius = CGFloat(18)
  }
  
  override init(frame: CGRect){
    super.init(frame: frame)
    
    self.setup()
    self.bindConstraints()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func selectDays(weekDays: [WeekDay]) {
    self.clearSelected()
    for weekDay in weekDays {
      let index = weekDay.getIntValue()
      if let button = self.arrangedSubviews[index] as? UIButton {
        self.selectButton(button: button, isSelected: true)
      }
    }
  }
  
  private func setup() {
    self.alignment = .leading
    self.axis = .horizontal
    self.backgroundColor = .clear
    self.spacing = 4
    self.distribution = .equalSpacing
    
    self.addArrangedSubview(sundayButton)
    self.addArrangedSubview(mondayButton)
    self.addArrangedSubview(tuesdayButton)
    self.addArrangedSubview(wednesday)
    self.addArrangedSubview(thursday)
    self.addArrangedSubview(friday)
    self.addArrangedSubview(saturday)
  }
  
  private func bindConstraints() {
    self.sundayButton.snp.makeConstraints { make in
      make.width.height.equalTo(36)
    }
    
    self.mondayButton.snp.makeConstraints { make in
      make.width.height.equalTo(36)
    }
    
    self.tuesdayButton.snp.makeConstraints { make in
      make.width.height.equalTo(36)
    }
    
    self.wednesday.snp.makeConstraints { make in
      make.width.height.equalTo(36)
    }
    
    self.thursday.snp.makeConstraints { make in
      make.width.height.equalTo(36)
    }
    
    self.friday.snp.makeConstraints { make in
      make.width.height.equalTo(36)
    }
    
    self.saturday.snp.makeConstraints { make in
      make.width.height.equalTo(36)
    }
  }
  
  private func clearSelected() {
    for subView in self.arrangedSubviews {
      if let button = subView as? UIButton {
        self.selectButton(button: button, isSelected: false)
      }
    }
  }
  
  private func selectButton(button: UIButton, isSelected: Bool) {
    if isSelected {
      button.backgroundColor = .black
      button.layer.borderWidth = 0
    } else {
      button.backgroundColor = .clear
      button.layer.borderWidth = 1
    }
  }
}
