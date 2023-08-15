import UIKit

import Common
import DesignSystem
import SnapKit

final class SplashView: BaseView {
    private let splashImage = UIImageView(image: MembershipAsset.imageSplash.image)
    
    override func setup() {
        backgroundColor = DesignSystemAsset.Colors.mainPink.color
        addSubViews([splashImage])
    }
    
    override func bindConstraints() {
        splashImage.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.equalToSuperview().offset(32)
            $0.right.equalToSuperview().offset(-32)
        }
    }
}
