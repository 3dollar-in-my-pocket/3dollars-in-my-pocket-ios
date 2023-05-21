import UIKit

final class BossStoreInfoCell: BaseCollectionViewCell {
    static let registerId = "\(BossStoreInfoCell.self)"
    static let estimatedHeight: CGFloat = 436
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let snsTitleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = Color.black
        $0.text = "boss_store_sns".localized
    }
    
    let snsButton = UIButton().then {
        $0.setTitle("boss_store_sns_shortcut".localized, for: .normal)
        $0.titleLabel?.font = .regular(size: 14)
        $0.setTitleColor(Color.green, for: .normal)
    }
    
    private let introductionTitleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = Color.black
        $0.text = "boss_store_introduction".localized
    }
    
    private let introductionValueLabel = UILabel().then {
        $0.font = .regular(size: 14)
        $0.textColor = Color.gray50
        $0.numberOfLines = 0
        $0.textAlignment = .left
    }
    
    private let photoView = UIImageView().then {
        $0.layer.cornerRadius = 12
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.containerView,
            self.snsTitleLabel,
            self.snsButton,
            self.introductionTitleLabel,
            self.introductionValueLabel,
            self.photoView
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalTo(self.introductionValueLabel).offset(16)
        }
        
        self.snsTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.top.equalTo(self.containerView).offset(16)
        }
        
        self.snsButton.snp.makeConstraints { make in
            make.right.equalTo(self.containerView).offset(-16)
            make.centerY.equalTo(self.snsTitleLabel)
        }
        
        self.introductionTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.snsTitleLabel)
            make.top.equalTo(self.snsTitleLabel.snp.bottom).offset(16)
        }
        
        self.introductionValueLabel.snp.makeConstraints { make in
            make.top.equalTo(self.introductionTitleLabel.snp.bottom).offset(8)
            make.left.equalTo(self.introductionTitleLabel)
            make.right.equalTo(self.containerView).offset(-16)
        }
        
        self.photoView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.containerView.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
            make.height.equalTo(210)
        }
    }
    
    func bind(snsUrl: String?, introduction: String?, imageUrl: String?) {
        if let snsUrl = snsUrl {
            self.snsButton.isHidden = snsUrl.isEmpty
        } else {
            self.snsButton.isHidden = true
        }
        self.introductionValueLabel.text = introduction
        if let imageUrl = imageUrl {
            self.photoView.setImage(urlString: imageUrl)
        }
    }
}
