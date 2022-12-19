import UIKit

final class MedalCollectionCell: BaseCollectionViewCell {
    static let registerId = "\(MedalCollectionCell.self)"
    
    static let size = CGSize(
        width: (UIScreen.main.bounds.width - 48 - 24) / 2,
        height: 161
    )
    
    private let containerView = UIView().then {
        $0.backgroundColor = Color.gray95
        $0.layer.cornerRadius = 8
    }
    
    private let medalImage = UIImageView()
    
    private let nameContainerView = UIView().then {
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor(r: 255, g: 161, b: 170).cgColor
        $0.layer.borderWidth = 1
        $0.backgroundColor = .clear
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = Color.pink
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.containerView.layer.borderWidth = 1
                self.containerView.layer.borderColor = UIColor(r: 255, g: 161, b: 170).cgColor
                self.nameContainerView.layer.borderWidth = 0
                self.nameContainerView.backgroundColor = .white
            } else {
                self.containerView.layer.borderWidth = 0
                self.nameContainerView.layer.borderWidth = 1
                self.nameContainerView.backgroundColor = .clear
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.nameContainerView.layer.borderWidth = 0
        self.containerView.layer.borderWidth = 0
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.containerView,
            self.medalImage,
            self.nameContainerView,
            self.nameLabel
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(self.medalImage).offset(15)
        }
        
        self.medalImage.snp.makeConstraints { make in
            make.centerX.equalTo(self.containerView)
            make.top.equalTo(self.containerView).offset(15)
            make.width.height.equalTo(90)
        }
        
        self.nameContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.containerView.snp.bottom).offset(9)
            make.bottom.equalToSuperview()
        }
        
        self.nameLabel.snp.makeConstraints { make in
            make.center.equalTo(self.nameContainerView)
        }
    }
    
    func bind(medal: Medal) {
        if medal.isOwned {
            self.medalImage.setImage(urlString: medal.iconUrl)
            self.containerView.layer.borderWidth = 0
            self.nameContainerView.layer.borderWidth = 1
            self.nameContainerView.layer.borderColor = UIColor(r: 255, g: 161, b: 170).cgColor
            self.nameContainerView.backgroundColor = .clear
            self.nameLabel.textColor = Color.pink
        } else {
            self.medalImage.setImage(urlString: medal.disableUrl)
            self.nameLabel.textColor = Color.gray60
            self.nameContainerView.layer.borderColor = UIColor(r: 90, g: 90, b: 90).cgColor
            self.nameContainerView.layer.borderWidth = 1
        }
        self.nameLabel.text = medal.name
    }
}
