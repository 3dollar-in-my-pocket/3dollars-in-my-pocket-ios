import UIKit

final class SettingMenuTableViewCell: BaseTableViewCell {
    static let registerId = "\(SettingMenuTableViewCell.self)"
    
    private let iconImageView = UIImageView()
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .regular(size: 16)
    }
    
    private let rightArrow = UIImageView().then {
        $0.image = R.image.ic_right_arrow()
    }
    
    let switchButton = UISwitch().then {
        $0.onTintColor = R.color.pink()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.rightArrow.isHidden = true
        self.switchButton.isHidden = true
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.contentView.isUserInteractionEnabled = false
        self.addSubViews([
            self.iconImageView,
            self.titleLabel,
            self.rightArrow,
            self.switchButton
        ])
    }
    
    override func bindConstraints() {
        self.iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(12.5)
            make.bottom.equalToSuperview().offset(-12.5)
            make.width.height.equalTo(16)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.iconImageView)
            make.left.equalTo(self.iconImageView.snp.right).offset(8)
        }
        
        self.rightArrow.snp.makeConstraints { make in
            make.centerY.equalTo(self.iconImageView.snp.centerY)
            make.right.equalToSuperview().offset(-24)
        }
        
        self.switchButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.iconImageView.snp.centerY)
            make.right.equalToSuperview().offset(-24)
        }
    }
    
    func bind(cellType: SettingTableViewCellType) {
        self.iconImageView.image = cellType.icon
        self.titleLabel.text = cellType.title
        
        if case .push(let isOn) = cellType {
            self.switchButton.isHidden = false
            self.switchButton.isOn = isOn
        } else {
            self.rightArrow.isHidden = false
        }
    }
}
