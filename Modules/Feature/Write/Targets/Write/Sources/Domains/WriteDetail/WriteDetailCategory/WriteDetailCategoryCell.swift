import UIKit

import Common
import DesignSystem
import Model

final class WriteDetailCategoryCell: BaseCollectionViewCell {
    enum Layout {
        static func calculateSize(category: StoreFoodCategoryResponse) -> CGSize {
            return Chip.Layout.size(style: .filled, text: category.name, showsIcon: true)
        }
    }

    private let chip: Chip = {
        let chip = Chip(style: .filled)
        chip.isIconHidden = false
        return chip
    }()

    override var isSelected: Bool {
        didSet {
            chip.isOn = isSelected
        }
    }

    override func setup() {
        contentView.addSubview(chip)
    }

    override func bindConstraints() {
        chip.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        chip.iconView.clear()
    }

    func bind(category: StoreFoodCategoryResponse) {
        chip.text = category.name
        chip.iconView.setImage(urlString: category.imageUrl)
    }
}
