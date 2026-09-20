import UIKit

import Common
import DesignSystem
import Model

/// 커뮤니티탭 카드 광고
final class CommunityPollListAdCell: BaseCollectionViewCell {

    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true
        containerView.backgroundColor = Colors.systemWhite.color
        return containerView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.semiBold.font(size: 20)
        titleLabel.textColor = Colors.gray90.color
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    private let contentLabel: UILabel = {
        let contentLabel = UILabel()
        contentLabel.font = Fonts.regular.font(size: 14)
        contentLabel.textColor = Colors.gray50.color
        contentLabel.numberOfLines = 0
        contentLabel.textAlignment = .center
        return contentLabel
    }()
    
    private let moreButton: UIButton = {
        let moreButton = UIButton()
        moreButton.setTitle("자세히 보기", for: .normal)
        moreButton.titleLabel?.font = Fonts.medium .font(size: 12)
        moreButton.imageEdgeInsets.left = 2
        moreButton.semanticContentAttribute = .forceRightToLeft
        moreButton.contentEdgeInsets = .init(top: 16, left: 12, bottom: 16, right: 12)
        moreButton.setTitleColor(Colors.gray50.color, for: .normal)
        moreButton.setImage(Icons.arrowRight.image
            .resizeImage(scaledTo: 16)
            .withTintColor(Colors.gray50.color), for: .normal)
        moreButton.isUserInteractionEnabled = false
        return moreButton
    }()
    
    private let adButton: UIButton = {
        let adButton = UIButton()
        adButton.setTitle("광고", for: .normal)
        adButton.titleLabel?.font = Fonts.medium.font(size: 10)
        adButton.backgroundColor = Colors.gray10.color
        adButton.layer.cornerRadius = 9
        adButton.setTitleColor(Colors.gray50.color, for: .normal)
        adButton.isUserInteractionEnabled = false
        return adButton
    }()
    
    private let adBanner = Environment.appModuleInterface.createAdBannerView(adType: .pollListItem)

    private var viewModel: CommunityPollListAdCellViewModel?

    override func setup() {
        super.setup()
        
        contentView.addSubview(containerView)
        contentView.addSubview(adBanner)
        containerView.addSubViews([
            imageView,
            titleLabel,
            contentLabel,
            adButton,
            moreButton
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(94)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        adButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(16)
            $0.size.equalTo(CGSize(width: 32, height: 18))
        }
        
        moreButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        adBanner.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func bind(viewModel: CommunityPollListAdCellViewModel, rootViewController: UIViewController?) {
        self.viewModel = viewModel
        
        if let advertisement = viewModel.output.item {
            
            imageView.setImage(urlString: advertisement.image?.url)
            
            titleLabel.setText(advertisement.title?.content, lineHeight: 28)
            if let titleColor = advertisement.title?.fontColor {
                titleLabel.textColor = UIColor(hex: titleColor)
            }
            
            contentLabel.setText(advertisement.subTitle?.content, lineHeight: 20)
            if let contentColor = advertisement.subTitle?.fontColor {
                contentLabel.textColor = UIColor(hex: contentColor)
            }
            
            if let backgroundColor = advertisement.background?.color {
                containerView.backgroundColor = UIColor(hex: backgroundColor)
            }
            
            adBanner.isHidden = true
        } else {
            if let rootViewController {
                adBanner.load(in: rootViewController)
                adBanner.isHidden = false
            }
        }
    }
}

private extension UILabel {
    func setText(_ text: String?, lineHeight: CGFloat) {
        guard let text = text else { return }
        let style = NSMutableParagraphStyle()
        
        style.maximumLineHeight = lineHeight
        style.minimumLineHeight = lineHeight
        style.alignment = .center
        
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [
                .paragraphStyle: style
            ]
        )
        attributedText = attributedString
    }
}
