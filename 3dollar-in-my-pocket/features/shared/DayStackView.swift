import UIKit

class DayStackView: UIStackView {
  
  let dayStackSize: DayStackViewSize
  let itemWidth: Int
  let fontSize: CGFloat
  
  let sundayButton = UIButton().then {
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_sunday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
  }
  
  let mondayButton = UIButton().then {
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_monday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
  }
  
  let tuesdayButton = UIButton().then {
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_tuesday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
  }
  
  let wednesday = UIButton().then {
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_wednesday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
  }
  
  let thursday = UIButton().then {
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_thursday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
  }
  
  let friday = UIButton().then {
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_friday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
  }
  
  let saturday = UIButton().then {
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_saturday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
  }
  
  init(dayStackSize: DayStackViewSize){
    self.dayStackSize = dayStackSize
    if dayStackSize == .normal {
      self.fontSize = 16
      self.itemWidth = 36
    } else {
      self.fontSize = 12
      self.itemWidth = 24
    }
    super.init(frame: .zero)
    setup()
    bindConstraints()
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
    
    self.sundayButton.layer.cornerRadius = CGFloat(self.itemWidth/2)
    self.mondayButton.layer.cornerRadius = CGFloat(self.itemWidth/2)
    self.tuesdayButton.layer.cornerRadius = CGFloat(self.itemWidth/2)
    self.wednesday.layer.cornerRadius = CGFloat(self.itemWidth/2)
    self.thursday.layer.cornerRadius = CGFloat(self.itemWidth/2)
    self.friday.layer.cornerRadius = CGFloat(self.itemWidth/2)
    self.saturday.layer.cornerRadius = CGFloat(self.itemWidth/2)
    
    self.sundayButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: self.fontSize)
    self.mondayButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: self.fontSize)
    self.tuesdayButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: self.fontSize)
    self.wednesday.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: self.fontSize)
    self.thursday.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: self.fontSize)
    self.friday.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: self.fontSize)
    self.saturday.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: self.fontSize)
  }
  
  private func bindConstraints() {
    self.sundayButton.snp.makeConstraints { make in
      make.width.height.equalTo(self.itemWidth)
    }
    
    self.mondayButton.snp.makeConstraints { make in
      make.width.height.equalTo(self.itemWidth)
    }
    
    self.tuesdayButton.snp.makeConstraints { make in
      make.width.height.equalTo(self.itemWidth)
    }
    
    self.wednesday.snp.makeConstraints { make in
      make.width.height.equalTo(self.itemWidth)
    }
    
    self.thursday.snp.makeConstraints { make in
      make.width.height.equalTo(self.itemWidth)
    }
    
    self.friday.snp.makeConstraints { make in
      make.width.height.equalTo(self.itemWidth)
    }
    
    self.saturday.snp.makeConstraints { make in
      make.width.height.equalTo(self.itemWidth)
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

enum DayStackViewSize {
  case small, normal
}
