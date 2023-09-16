import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailRatingCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 76
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.pink100.color
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.StoreDetail.Rating.title
        label.textColor = Colors.gray50.color
        label.font = Fonts.medium.font(size: 10)
        
        return label
    }()
    
    private let starStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        
        
        return stackView
    }()
    
    private let ratingValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray80.color
        label.font = Fonts.semiBold.font(size: 20)
        
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        starStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    override func setup() {
        contentView.addSubViews([
            containerView,
            ratingLabel,
            starStackView
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(Layout.height)
        }
        
        ratingLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(containerView).offset(16)
        }
        
        starStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(28)
            $0.top.equalTo(ratingLabel.snp.bottom).offset(2)
        }
    }
    
    func bind(_ rating: Double) {
        for index in 0..<5 {
            if index < Int(rating) {
                let starImageView = UIImageView(image: Icons.starSolid.image.withTintColor(Colors.mainPink.color))
                
                starStackView.addArrangedSubview(starImageView)
            } else {
                let starImageView = UIImageView(image: Icons.starSolid.image.withTintColor(Colors.pink200.color))
                
                starStackView.addArrangedSubview(starImageView)
            }
        }
        
        if let lastView = starStackView.arrangedSubviews.last {
            starStackView.setCustomSpacing(10, after: lastView)
        }
        
        ratingValueLabel.text = "\(rating)점"
        starStackView.addArrangedSubview(ratingValueLabel)
    }
}
