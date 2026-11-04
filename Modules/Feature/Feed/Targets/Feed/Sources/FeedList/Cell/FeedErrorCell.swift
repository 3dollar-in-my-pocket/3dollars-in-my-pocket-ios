import UIKit

import Common

final class FeedErrorCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 200
        static let retryButtonHeight: CGFloat = 36
    }

    var onTapRetry: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.FeedList.Error.title
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray70.color
        label.textAlignment = .center
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.FeedList.Error.retry, for: .normal)
        button.setTitleColor(Colors.gray80.color, for: .normal)
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)
        button.contentEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
        button.backgroundColor = Colors.systemWhite.color
        button.layer.cornerRadius = Layout.retryButtonHeight / 2
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.gray30.color.cgColor
        return button
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        onTapRetry = nil
    }

    override func setup() {
        contentView.addSubViews([titleLabel, retryButton])
        retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(contentView.snp.centerY).offset(-8)
        }

        retryButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(contentView.snp.centerY).offset(8)
            $0.height.equalTo(Layout.retryButtonHeight)
        }
    }

    @objc private func didTapRetry() {
        onTapRetry?()
    }
}
