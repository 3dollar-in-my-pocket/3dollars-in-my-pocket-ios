import UIKit

import Common
import DesignSystem

final class StoreDetailOverviewInfoCellItemView: BaseView {
    enum InfoType {
        case review(Int)
        case distance(Int)
        
        var image: UIImage {
            switch self {
            case .review:
                return Icons.review.image.withTintColor(Colors.gray60.color)
                
            case .distance:
                return Icons.locationSolid.image.withTintColor(Colors.gray60.color)
            }
        }
        
        var text: String {
            switch self {
            case .review(let count):
                return "\(count)개"
                
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
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray60.color
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
