import UIKit

import Common
import DesignSystem
import Model

final class HomeCardAdvertisementCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width - 81, height: 152)
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = DesignSystemAsset.Colors.gray100.color
        view.clipsToBounds = true
        
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private let tagLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 2, bottomInset: 2, leftInset: 2, rightInset: 2)
        label.textColor = Colors.mainPink.color
        label.font = Fonts.medium.font(size: 10)
        label.text = "광고"
        label.backgroundColor = Colors.systemBlack.color
        
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.systemWhite.color
        label.numberOfLines = 1
        label.textAlignment = .left
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray50.color
        label.font = Fonts.medium.font(size: 12)
        label.numberOfLines = 0
        
        return label
    }()
    
    private let adBannerView = Environment.appModuleInterface.createAdBannerView(adType: .homeCard)
    
    override func setup() {
        adBannerView.layer.cornerRadius = 20
        adBannerView.layer.masksToBounds = true
        containerView.addSubViews([
            imageView,
            tagLabel,
            titleLabel,
            descriptionLabel
        ])
        
        contentView.addSubViews([
            containerView,
            adBannerView
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.leading.equalTo(contentView)
            $0.top.equalTo(containerView)
            $0.bottom.equalTo(containerView)
            $0.width.equalTo(Layout.size.width * 0.29).priority(.high)
        }
        
        tagLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalTo(imageView.snp.trailing).offset(10)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(10)
            $0.top.equalTo(tagLabel.snp.bottom).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        adBannerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(advertisement: AdvertisementResponse?, in rootViewController: UIViewController) {
        if let advertisement {
            titleLabel.text = advertisement.title?.content
            if let titleColor = advertisement.title?.fontColor {
                titleLabel.textColor = UIColor(hex: titleColor)
            }
            
            descriptionLabel.text = advertisement.subTitle?.content
            if let descriptionColor = advertisement.subTitle?.fontColor {
                descriptionLabel.textColor = UIColor(hex: descriptionColor)
            }
            descriptionLabel.setLineHeight(lineHeight: 18)
            
            imageView.setImage(urlString: advertisement.image?.url)
            adBannerView.isHidden = true
        } else {
            adBannerView.load(in: rootViewController)
            adBannerView.isHidden = false
        }
    }
}
