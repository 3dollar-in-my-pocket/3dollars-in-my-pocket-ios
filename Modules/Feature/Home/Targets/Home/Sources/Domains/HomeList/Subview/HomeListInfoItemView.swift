import UIKit

import Common
import DesignSystem

final class HomeListInfoItemView: BaseView {
    enum InfoType {
        case review(Int)
        case rate(Double)
        case distance(Int)
        
        var image: UIImage {
            switch self {
            case .review:
                return DesignSystemAsset.Icons.review.image.withTintColor(DesignSystemAsset.Colors.gray40.color)
                
            case .rate:
                return DesignSystemAsset.Icons.starSolid.image.withTintColor(DesignSystemAsset.Colors.gray40.color)
                
            case .distance:
                return DesignSystemAsset.Icons.locationSolid.image.withTintColor(DesignSystemAsset.Colors.gray40.color)
            }
        }
        
        var text: String {
            switch self {
            case .review(let count):
                return "\(count)개"
                
            case .rate(let rate):
                return "\(rate)"
                
            case .distance(let distance):
                return distance.distanceString
            }
        }
    }
    
    init(type: InfoType) {
        super.init(frame: .zero)
        
        imageView.image = type.image
        titleLabel.text = type.text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView = UIImageView()
    
    private let titleLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.textColor = DesignSystemAsset.Colors.gray50.color
    }
    
    override func setup() {
        addSubViews([
            imageView,
            titleLabel
        ])
    }
    
    override func bindConstraints() {
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(12)
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalTo(imageView.snp.right).offset(2)
        }
        
        snp.makeConstraints {
            $0.left.equalTo(imageView).priority(.high)
            $0.top.equalTo(titleLabel).priority(.high)
            $0.right.equalTo(titleLabel).priority(.high)
            $0.bottom.equalTo(titleLabel).priority(.high)
        }
    }
}
