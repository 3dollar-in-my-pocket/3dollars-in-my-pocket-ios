import UIKit

final class AdBannerHeaderView: UICollectionReusableView {
    static let registerID = "\(AdBannerHeaderView.self)"
    static let size = CGSize(
        width: UIScreen.main.bounds.width - 48,
        height: 100
    )
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 12
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textAlignment = .left
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.numberOfLines = 0
    }
    
    private let rightImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        self.bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(advertisement: Popup) {
        self.titleLabel.text = advertisement.title
        self.titleLabel.textColor = .init(hex: advertisement.fontColor)
        self.titleLabel.setKern(kern: -0.4)
        self.descriptionLabel.text = advertisement.subTitle
        self.descriptionLabel.textColor = .init(hex: advertisement.fontColor)
        self.descriptionLabel.setKern(kern: -0.2)
        self.rightImageView.setImage(urlString: advertisement.imageUrl)
        self.containerView.backgroundColor = .init(hex: advertisement.bgColor)
    }
    
    private func setup() {
        self.addSubViews([
            self.containerView,
            self.titleLabel,
            self.descriptionLabel,
            self.rightImageView
        ])
    }
    
    private func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(84)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.top.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.rightImageView.snp.left)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel)
            make.right.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(4)
        }
        
        self.rightImageView.snp.makeConstraints { make in
            make.top.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.width.height.equalTo(84)
        }
    }
}
