import UIKit

import RxSwift
import RxCocoa

final class AdBannerHeaderView: UICollectionReusableView {
    let disposeBag = DisposeBag()
    static let registerID = "\(AdBannerHeaderView.self)"
    static let size = CGSize(
        width: UIScreen.main.bounds.width - 48,
        height: 100
    )
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 12
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.alignment = .leading
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
    
    fileprivate let button = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        self.bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(advertisement: Advertisement) {
        self.titleLabel.text = advertisement.title
        self.titleLabel.textColor = .init(hex: advertisement.fontColor)
        self.titleLabel.setKern(kern: -0.4)
        self.descriptionLabel.text = advertisement.subTitle
        self.descriptionLabel.textColor = .init(hex: advertisement.fontColor)
        self.descriptionLabel.setKern(kern: -0.2)
        self.rightImageView.setImage(urlString: advertisement.imageUrl)
        self.containerView.backgroundColor = .init(hex: advertisement.bgColor)
        if advertisement.subTitle.count < 21 {
            self.stackView.spacing = 0
        } else {
            self.stackView.spacing = 8
        }
    }
    
    private func setup() {
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.descriptionLabel)
        self.addSubViews([
            self.containerView,
            self.stackView,
            self.rightImageView,
            self.button
        ])
    }
    
    private func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(84)
        }
        
        self.stackView.snp.makeConstraints { make in
            make.centerY.equalTo(self.containerView)
            make.left.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.rightImageView.snp.left)
        }
        
        self.rightImageView.snp.makeConstraints { make in
            make.top.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.width.height.equalTo(84)
        }
        
        self.button.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }
    }
}

extension Reactive where Base: AdBannerHeaderView {
    var tap: ControlEvent<Void> {
        return base.button.rx.tap
    }
}
