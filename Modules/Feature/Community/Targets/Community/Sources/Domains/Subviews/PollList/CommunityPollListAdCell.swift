import UIKit

import Common
import DesignSystem
import Model

/// 커뮤니티탭 카드 광고
final class CommunityPollListAdCell: BaseCollectionViewCell {

    private let containerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.backgroundColor = Colors.systemWhite.color
    }
    
    private let imageView = UIImageView().then {
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 20)
        $0.textColor = Colors.gray90.color
        $0.textAlignment = .center
    }
    
    private let contentLabel = UILabel().then {
        $0.font = Fonts.regular.font(size: 14)
        $0.textColor = Colors.gray50.color
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private let moreButton = UIButton().then {
        $0.setTitle("자세히 보기", for: .normal)
        $0.titleLabel?.font = Fonts.medium .font(size: 12)
        $0.imageEdgeInsets.left = 2
        $0.semanticContentAttribute = .forceRightToLeft
        $0.contentEdgeInsets = .init(top: 16, left: 12, bottom: 16, right: 12)
        $0.setTitleColor(Colors.gray50.color, for: .normal)
        $0.setImage(Icons.arrowRight.image
            .resizeImage(scaledTo: 16)
            .withTintColor(Colors.gray50.color), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    private let adButton = UIButton().then {
        $0.setTitle("광고", for: .normal)
        $0.titleLabel?.font = Fonts.medium.font(size: 10)
        $0.backgroundColor = Colors.gray10.color
        $0.layer.cornerRadius = 9
        $0.setTitleColor(Colors.gray50.color, for: .normal)
        $0.isUserInteractionEnabled = false
    }

    private var viewModel: CommunityPollListAdCellViewModel?

    override func setup() {
        super.setup()
        
        contentView.addSubview(containerView)
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
    }

    func bind(viewModel: CommunityPollListAdCellViewModel) {
        self.viewModel = viewModel
        
        let advertisement = viewModel.output.item
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
                .paragraphStyle: style,
            ]
        )
        attributedText = attributedString
    }
}
