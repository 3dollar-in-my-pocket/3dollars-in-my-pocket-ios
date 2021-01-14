import UIKit

class DayStackView: UIStackView {
  
  let sundayButton = UIButton().then {
    $0.layer.cornerRadius = 18
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_sunday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
  }
  
  let mondayButton = UIButton().then {
    $0.layer.cornerRadius = 18
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_monday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
  }
  
  let tuesdayButton = UIButton().then {
    $0.layer.cornerRadius = 18
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_tuesday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
  }
  
  let wednesday = UIButton().then {
    $0.layer.cornerRadius = 18
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_wednesday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
  }
  
  let thursday = UIButton().then {
    $0.layer.cornerRadius = 18
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_thursday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
  }
  
  let friday = UIButton().then {
    $0.layer.cornerRadius = 18
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_friday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
  }
  
  let saturday = UIButton().then {
    $0.layer.cornerRadius = 18
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.setTitle("write_store_saturday".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    bindConstraints()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.alignment = .leading
    self.axis = .horizontal
    self.backgroundColor = .clear
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
}
