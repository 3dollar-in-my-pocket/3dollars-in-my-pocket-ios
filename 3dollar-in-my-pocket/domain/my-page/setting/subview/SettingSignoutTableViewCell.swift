import UIKit

import Base

final class SettingSignoutTableViewCell: BaseTableViewCell {
    static let registerId = "\(SettingSignoutTableViewCell.self)"
    
    private let warningImage = UIImageView().then {
        $0.image = R.image.ic_warning_white()
    }
    
    private let withdrawalLabel = UILabel().then {
        $0.text = R.string.localization.setting_withdrawal()
        $0.font = .medium(size: 14)
        $0.textColor = UIColor(r: 153, g: 153, b: 153)
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.addSubViews([
            self.warningImage,
            self.withdrawalLabel
        ])
    }
    
    override func bindConstraints() {
        self.warningImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.height.equalTo(16)
        }
        
        self.withdrawalLabel.snp.makeConstraints { make in
            make.left.equalTo(self.warningImage.snp.right).offset(8)
            make.centerY.equalTo(self.warningImage)
        }
    }
}
