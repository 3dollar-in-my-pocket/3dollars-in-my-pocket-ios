import UIKit

import Common
import DesignSystem
import SnapKit

final class CommunityNavigationBar: BaseView {

    enum Layout {
        static let height: CGFloat = 56
    }

    let backButton = UIButton().then {
        $0.setImage(
            DesignSystemAsset.Icons.arrowLeft.image
                .resizeImage(scaledTo: 24)
                .withTintColor(DesignSystemAsset.Colors.gray100.color), for: .normal)
        $0.contentEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
    }

    let titleLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }

    init(title: String) {
        super.init(frame: .zero)

        titleLabel.text = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        addSubViews([
            backButton,
            titleLabel
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
