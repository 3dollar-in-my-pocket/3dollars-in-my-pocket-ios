import UIKit

import Common
import DesignSystem
import Model

import SnapKit

final class StorePreviewMoreCell: BaseCollectionViewCell {
    enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let topMargin: CGFloat = 4
        static let bottomMargin: CGFloat = 20
        static let peekHeight: CGFloat = topMargin + 9
    }

    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))

    override func setup() {
        contentView.addSubview(titleLabel)
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.topMargin)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
            $0.bottom.equalToSuperview().offset(-Layout.bottomMargin)
        }
    }

    func bind(_ section: StorePreviewMoreSection) {
        titleLabel.setSDText(section.header.title)
    }
}
