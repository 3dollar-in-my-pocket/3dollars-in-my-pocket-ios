import UIKit

import Common

final class FeedListHeaderCell: BaseCollectionViewCell {
    enum Layout {
        static let titleHeight: CGFloat = 28
        static let spacing: CGFloat = 4
        static let descriptionHeight: CGFloat = 20
        static let height: CGFloat = titleHeight + spacing + descriptionHeight
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 20)
        label.textColor = Colors.gray100.color
        label.text = Strings.FeedList.Header.title
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray60.color
        label.text = Strings.FeedList.Header.description
        return label
    }()

    override func setup() {
        contentView.addSubViews([titleLabel, descriptionLabel])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.titleHeight)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Layout.spacing)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.descriptionHeight)
        }
    }
}
