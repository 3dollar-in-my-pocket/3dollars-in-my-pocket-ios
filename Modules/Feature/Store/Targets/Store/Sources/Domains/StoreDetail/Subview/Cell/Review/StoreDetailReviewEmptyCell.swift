import UIKit

import Common
import DesignSystem

final class StoreDetailReviewEmptyCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 78
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray10.color
        view.layer.cornerRadius = 6
        
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 2
        stackView.axis = .horizontal
        
        return stackView
    }()
    
    private let emptyImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Icons.empty02.image
        
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray50.color
        label.text = Strings.StoreDetail.Review.empty
        
        return label
    }()
    
    override func setup() {
        stackView.addArrangedSubview(emptyImage)
        stackView.addArrangedSubview(titleLabel)
        addSubViews([
            containerView,
            stackView
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview().priority(.high)
            $0.right.equalToSuperview()
            $0.height.equalTo(Layout.height)
            $0.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.center.equalTo(containerView)
        }
        
        emptyImage.snp.makeConstraints {
            $0.size.equalTo(48)
        }
    }
    
    func updateBackgroundColor(_ color: UIColor) {
        containerView.backgroundColor = color
    }
}
