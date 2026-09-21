import UIKit

import Common
import DesignSystem

final class SearchAddressHeaderCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 44)
    }

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.bold.font(size: 16)
        titleLabel.textColor = Colors.gray100.color
        titleLabel.textAlignment = .center
        return titleLabel
    }()

    override func setup() {
        super.setup()

        contentView.addSubViews([
            titleLabel
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
    }
    
    func bind(title: String) {
        titleLabel.text = title
    }
}
