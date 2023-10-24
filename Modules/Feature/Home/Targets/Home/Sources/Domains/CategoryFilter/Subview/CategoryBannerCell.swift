import UIKit

import Common
import DesignSystem
import Model

final class CategoryBannerCell: BaseCollectionViewCell {
    static let size = CGSize(width: UIScreen.main.bounds.width - 48, height: 100)
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 12
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.alignment = .leading
    }
    
    private let titleLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        $0.textAlignment = .left
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.regular.font(size: 12)
        $0.numberOfLines = 0
    }
    
    private let rightImageView = UIImageView()
    
    override func setup() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        addSubViews([
            containerView,
            stackView,
            rightImageView
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(84)
        }
        
        stackView.snp.makeConstraints {
            $0.centerY.equalTo(containerView)
            $0.left.equalTo(containerView).offset(16)
            $0.right.equalTo(rightImageView.snp.left)
        }
        
        rightImageView.snp.makeConstraints {
            $0.top.equalTo(containerView)
            $0.right.equalTo(containerView)
            $0.width.height.equalTo(84)
        }
    }
    
    func bind(advertisement: Advertisement?) {
        guard let advertisement = advertisement else { return }

        titleLabel.text = advertisement.title
        titleLabel.textColor = UIColor(hex: advertisement.fontColor ?? "000000")
        titleLabel.setKern(kern: -0.4)
        descriptionLabel.text = advertisement.subTitle
        descriptionLabel.textColor = UIColor(hex: advertisement.fontColor ?? "000000")
        descriptionLabel.setKern(kern: -0.2)
        rightImageView.setImage(urlString: advertisement.imageUrl)
        containerView.backgroundColor = UIColor(hex: advertisement.bgColor ?? "FFFFFF")
        
        if let subTitle = advertisement.subTitle,
           subTitle.count < 21 {
            stackView.spacing = 0
        } else {
            stackView.spacing = 8
        }
    }
}
