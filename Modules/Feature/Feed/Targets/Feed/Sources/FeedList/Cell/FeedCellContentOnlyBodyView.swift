import UIKit

import Common
import DesignSystem
import Model

final class FeedCellContentOnlyBodyView: BaseView {
    enum Layout {
        static let height: CGFloat = 36
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView
    }()
    
    private let contentLeadingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray80.color
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    override func setup() {
        layer.cornerRadius = 12
        layer.masksToBounds = true
        addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
    }
    
    func bind(body: ContentOnlyFeedBodyResponse) {
        if let contentLeadingImage = body.contentLeadingImage {
            contentLeadingImageView.setImage(urlString: contentLeadingImage.imageUrl)
            stackView.addArrangedSubview(contentLeadingImageView)
            contentLeadingImageView.snp.makeConstraints {
                $0.size.equalTo(16)
            }
        }
        
        contentLabel.setUiText(body.content)
        stackView.addArrangedSubview(contentLabel)
        backgroundColor = UIColor(hex: body.style.backgroundColor)
    }
}
