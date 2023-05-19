import UIKit

final class HomeEmptyStoreCell: BaseCollectionViewCell {
    static let registerId = "\(HomeEmptyStoreCell.self)"
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 4, height: 4)
        $0.layer.shadowOpacity = 0.08
    }
  
    private let emptyImage = UIImageView().then {
        $0.image = UIImage(named: "img_empty_home")
    }
  
    private let emptyTitleLabel = UILabel().then {
        $0.text = "home_empty_title".localized
        $0.font = .bold(size: 14)
        $0.textColor = Color.black
        $0.setKern(kern: -0.5)
    }
  
    private let emptyDescriptionLabel = UILabel().then {
        $0.text = "home_empty_description".localized
        $0.textColor = Color.gray40
        $0.font = .regular(size: 12)
        $0.numberOfLines = 0
        $0.setKern(kern: -0.2)
    }
  
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.containerView,
            self.emptyImage,
            self.emptyTitleLabel,
            self.emptyDescriptionLabel
        ])
    }
  
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.emptyImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(64)
        }
        
        self.emptyTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.emptyImage.snp.right).offset(16)
            make.top.equalTo(self.containerView).offset(33)
        }
        
        self.emptyDescriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(self.emptyTitleLabel)
            make.top.equalTo(self.emptyTitleLabel.snp.bottom).offset(8)
        }
    }
    
    func bind(storeType: StoreType) {
        if storeType == .streetFood {
            self.emptyTitleLabel.text = "home_empty_title".localized
            self.emptyDescriptionLabel.text = "home_empty_description".localized
        } else {
            self.emptyTitleLabel.text = "home_empty_boss_title".localized
            self.emptyDescriptionLabel.text = "home_empty_boss_description".localized
        }
    }
}
