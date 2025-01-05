import UIKit

import Common
import DesignSystem

final class HomeCellInfoView: BaseView {
    private let reviewImage = UIImageView(image: DesignSystemAsset.Icons.review.image.withTintColor(DesignSystemAsset.Colors.gray40.color))
    
    private let reviewCountLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.textColor = DesignSystemAsset.Colors.gray40.color
    }
    
    private let dividorView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.gray70.color
    }
    
    private let locationImage = UIImageView(image: DesignSystemAsset.Icons.locationSolid.image.withTintColor(DesignSystemAsset.Colors.gray40.color))
    
    private let locationLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.textColor = DesignSystemAsset.Colors.gray40.color
    }
    
    override func setup() {
        super.setup()
        addSubViews([
            reviewImage,
            reviewCountLabel,
            dividorView,
            locationImage,
            locationLabel
        ])
    }
    
    override func bindConstraints() {
        reviewImage.snp.makeConstraints {
            $0.width.height.equalTo(12)
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview()
        }
        
        reviewCountLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(reviewImage.snp.right).offset(2)
        }
        
        dividorView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalTo(1)
            $0.height.equalTo(8)
            $0.left.equalTo(reviewCountLabel.snp.right).offset(4)
        }
        
        locationImage.snp.makeConstraints {
            $0.width.height.equalTo(12)
            $0.centerY.equalToSuperview()
            $0.left.equalTo(dividorView.snp.right).offset(4)
        }
        
        locationLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(locationImage.snp.right).offset(2)
        }
        
        snp.makeConstraints {
            $0.left.equalTo(reviewImage).priority(.high)
            $0.height.equalTo(18)
            $0.right.equalTo(locationLabel).priority(.high)
        }
    }
    
    func bind(reviewCount: Int?, distance: Int) {
        let reviewCount = reviewCount ?? 0
        reviewCountLabel.text = "\(reviewCount)개"
        locationLabel.text = distance.distanceString
    }
}
