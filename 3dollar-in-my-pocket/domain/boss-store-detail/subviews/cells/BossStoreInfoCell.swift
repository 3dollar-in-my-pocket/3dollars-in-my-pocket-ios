import UIKit

import Base

final class BossStoreInfoCell: BaseCollectionViewCell {
    static let registerId = "\(BossStoreInfoCell.self)"
    static let estimatedHeight: CGFloat = 210
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let contactTitleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = R.color.black()
        $0.text = R.string.localization.boss_store_contact()
    }
    
    private let contactValueLabel = UILabel().then {
        $0.font = .regular(size: 14)
        $0.textColor = R.color.gray50()
    }
    
    private let snsTitleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = R.color.black()
        $0.text = R.string.localization.boss_store_sns()
    }
    
    private let snsButton = UIButton().then {
        $0.setTitle(R.string.localization.boss_store_sns_shortcut(), for: .normal)
        $0.titleLabel?.font = .regular(size: 14)
        $0.setTitleColor(R.color.green(), for: .normal)
    }
    
    private let introductionTitleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = R.color.black()
        $0.text = R.string.localization.boss_store_introduction()
    }
    
    private let introductionValueLabel = UILabel().then {
        $0.font = .regular(size: 14)
        $0.textColor = R.color.gray50()
        $0.numberOfLines = 0
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.containerView,
            self.contactTitleLabel,
            self.contactValueLabel,
            self.snsTitleLabel,
            self.snsButton,
            self.introductionTitleLabel,
            self.introductionValueLabel
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalTo(self.introductionValueLabel).offset(16)
        }
        
        self.contactTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.top.equalTo(self.containerView).offset(16)
        }
        
        self.contactValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.contactTitleLabel)
            make.right.equalTo(self.containerView).offset(-16)
        }
        
        self.snsTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.contactTitleLabel)
            make.top.equalTo(self.contactTitleLabel.snp.bottom).offset(18)
        }
        
        self.snsButton.snp.makeConstraints { make in
            make.right.equalTo(self.contactValueLabel)
            make.centerY.equalTo(self.snsTitleLabel)
        }
        
        self.introductionTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.contactTitleLabel)
            make.top.equalTo(self.snsTitleLabel.snp.bottom).offset(16)
        }
        
        self.introductionValueLabel.snp.makeConstraints { make in
            make.top.equalTo(self.introductionTitleLabel.snp.bottom).offset(8)
        }
    }
    
    func bind(contacts: String?, snsUrl: String?, introduction: String?) {
        self.contactValueLabel.text = contacts
        self.snsButton.isHidden = snsUrl == nil
        self.introductionValueLabel.text = introduction
    }
}
