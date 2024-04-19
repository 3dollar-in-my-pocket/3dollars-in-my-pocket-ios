import UIKit

import Common
import DesignSystem
import Then

final class SearchAddressHeaderCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 44)
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.gray100.color
        $0.textAlignment = .center
    }

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
