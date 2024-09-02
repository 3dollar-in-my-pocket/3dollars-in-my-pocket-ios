import UIKit

import Common
import DesignSystem
import Model
import AppInterface

final class CategoryBannerCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width - 48, height: 100)
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .leading
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        label.textAlignment = .left
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 12)
        label.numberOfLines = 0
        return label
    }()
    
    private let rightImageView = UIImageView()
    
    private let adBannerView = Environment.appModuleInterface.createAdBannerView(adType: .categoryFilter)
    
    override func setup() {
        setupUI()
    }
    
    private func setupUI() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        addSubViews([
            containerView,
            stackView,
            rightImageView,
            adBannerView
        ])
        
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
        
        adBannerView.snp.makeConstraints {
            $0.edges.equalTo(containerView)
        }
    }
    
    func bind(advertisement: AdvertisementResponse?, in rootViewController: UIViewController) {
        if let advertisement {
            titleLabel.text = advertisement.title?.content
            titleLabel.textColor = UIColor(hex: advertisement.title?.fontColor ?? "000000")
            titleLabel.setKern(kern: -0.4)
            descriptionLabel.text = advertisement.subTitle?.content
            descriptionLabel.textColor = UIColor(hex: advertisement.subTitle?.fontColor ?? "000000")
            descriptionLabel.setKern(kern: -0.2)
            rightImageView.setImage(urlString: advertisement.image?.url)
            containerView.backgroundColor = UIColor(hex: advertisement.background?.color ?? "FFFFFF")
            
            if let subTitle = advertisement.subTitle,
               subTitle.content.count < 21 {
                stackView.spacing = 0
            } else {
                stackView.spacing = 8
            }
            
            adBannerView.isHidden = true
        } else {
            adBannerView.load(in: rootViewController)
            adBannerView.isHidden = false
        }
    }
}
