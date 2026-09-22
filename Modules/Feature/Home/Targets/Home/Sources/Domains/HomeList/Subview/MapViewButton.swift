import UIKit

import Common
import DesignSystem

import SnapKit

final class MapViewButton: UIButton {
    enum Layout {
        static let height: CGFloat = 40
        static let bottomInset: CGFloat = 20
        static let iconSize: CGFloat = 16
        static let horizontalPadding: CGFloat = 12
        static let iconTitleSpacing: CGFloat = 4
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = Colors.gray90.color
        layer.cornerRadius = Layout.height / 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 2

        setTitle(HomeStrings.HomeList.mapViewButton, for: .normal)
        setTitleColor(Colors.systemWhite.color, for: .normal)
        titleLabel?.font = Fonts.medium.font(size: 12)
        setImage(
            Icons.map.image
                .resizeImage(scaledTo: Layout.iconSize)
                .withTintColor(Colors.systemWhite.color),
            for: .normal
        )

        let halfSpacing = Layout.iconTitleSpacing / 2
        contentEdgeInsets = UIEdgeInsets(
            top: 0,
            left: Layout.horizontalPadding + halfSpacing,
            bottom: 0,
            right: Layout.horizontalPadding + halfSpacing
        )
        titleEdgeInsets = UIEdgeInsets(top: 0, left: halfSpacing, bottom: 0, right: -halfSpacing)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -halfSpacing, bottom: 0, right: halfSpacing)

        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
    }
}
