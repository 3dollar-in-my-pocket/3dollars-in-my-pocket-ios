import UIKit

import Common
import Model

final class FeedListHeaderCell: BaseCollectionViewCell {
    enum Layout {
        static let titleHeight: CGFloat = 28
        static let spacing: CGFloat = 4
        static let subTitleHeight: CGFloat = 20

        static func height(header: SDHeader) -> CGFloat {
            guard header.subTitle != nil else { return titleHeight }
            return titleHeight + spacing + subTitleHeight
        }
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 20)
        label.textColor = Colors.gray100.color
        return label
    }()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray60.color
        return label
    }()

    override func setup() {
        contentView.addSubViews([titleLabel, subTitleLabel])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.titleHeight)
        }

        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Layout.spacing)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.subTitleHeight)
        }
    }

    func bind(header: SDHeader) {
        titleLabel.setSDText(header.title)
        subTitleLabel.setSDText(header.subTitle)
        subTitleLabel.isHidden = header.subTitle == nil
    }
}
