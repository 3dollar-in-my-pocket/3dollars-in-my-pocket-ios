import UIKit

final class DayStackView: UIStackView {
    private let sundayButton = UIButton().then {
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.setTitle(R.string.localization.write_store_sunday(), for: .normal)
        $0.titleLabel?.font = .regular(size: 12)
        $0.layer.cornerRadius = CGFloat(12)
    }
  
    private let mondayButton = UIButton().then {
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.setTitle(R.string.localization.write_store_monday(), for: .normal)
        $0.titleLabel?.font = .regular(size: 12)
        $0.layer.cornerRadius = CGFloat(12)
    }
  
    private let tuesdayButton = UIButton().then {
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.setTitle(R.string.localization.write_store_tuesday(), for: .normal)
        $0.titleLabel?.font = .regular(size: 12)
        $0.layer.cornerRadius = CGFloat(12)
    }
  
    private let wednesday = UIButton().then {
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.setTitle(R.string.localization.write_store_wednesday(), for: .normal)
        $0.titleLabel?.font = .regular(size: 12)
        $0.layer.cornerRadius = CGFloat(12)
    }
  
    private let thursday = UIButton().then {
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.setTitle(R.string.localization.write_store_thursday(), for: .normal)
        $0.titleLabel?.font = .regular(size: 12)
        $0.layer.cornerRadius = CGFloat(12)
    }
    
    private let friday = UIButton().then {
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.setTitle(R.string.localization.write_store_friday(), for: .normal)
        $0.titleLabel?.font = .regular(size: 12)
        $0.layer.cornerRadius = CGFloat(12)
    }
    
    private let saturday = UIButton().then {
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.setTitle(R.string.localization.write_store_saturday(), for: .normal)
        $0.titleLabel?.font = .regular(size: 12)
        $0.layer.cornerRadius = CGFloat(12)
    }
  
  
    override init(frame: CGRect) {
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
        
        self.addArrangedSubview(self.sundayButton)
        self.addArrangedSubview(self.mondayButton)
        self.addArrangedSubview(self.tuesdayButton)
        self.addArrangedSubview(self.wednesday)
        self.addArrangedSubview(self.thursday)
        self.addArrangedSubview(self.friday)
        self.addArrangedSubview(self.saturday)
    }
  
    private func bindConstraints() {
        self.sundayButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        self.mondayButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        self.tuesdayButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        self.wednesday.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        self.thursday.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        self.friday.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        self.saturday.snp.makeConstraints { make in
            make.width.height.equalTo(24)
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
            button.layer.borderColor = UIColor(r: 255, g: 161, b: 170).cgColor
            button.setTitleColor(UIColor(r: 255, g: 161, b: 170), for: .normal)
        } else {
            button.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
            button.setTitleColor(UIColor(r: 161, g: 161, b: 161), for: .normal)
        }
    }
}
