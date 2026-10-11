import UIKit

import Common
import DesignSystem
import Model

import SnapKit

final class HomeCurationCategoryChipCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 36
        static let horizontalInset: CGFloat = 12

        static func size(_ category: HomeCurationCategoryViewData) -> CGSize {
            sizingCell.bind(category)
            let labelWidth = sizingCell.titleLabel.intrinsicContentSize.width
            return CGSize(width: ceil(labelWidth) + horizontalInset * 2, height: height)
        }

        private static let sizingCell = HomeCurationCategoryChipCell()
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray100.color
        label.textAlignment = .center
        return label
    }()

    override func setup() {
        contentView.layer.cornerRadius = Layout.height / 2
        contentView.layer.masksToBounds = true
        contentView.addSubview(titleLabel)
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.centerY.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.attributedText = nil
        titleLabel.text = nil
    }

    func bind(_ category: HomeCurationCategoryViewData) {
        let chip = category.chip
        titleLabel.font = Fonts.medium.font(size: 12)
        titleLabel.setSDText(chip.text)
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = nil
        contentView.backgroundColor = .clear
        if let style = chip.style {
            contentView.setSDChipStyle(style)
        }
        accessibilityTraits = category.isSelected ? [.button, .selected] : .button
    }
}
