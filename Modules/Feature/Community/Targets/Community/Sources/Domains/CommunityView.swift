import UIKit

import Common
import DesignSystem
import SnapKit

final class CommunityView: BaseView {
    enum Layout {
        static let feedButtonHeight: CGFloat = 44
        static let feedButtonTrailing: CGFloat = 20
        static let feedButtonBottom: CGFloat = 16
        static let feedButtonSpacing: CGFloat = 8
    }

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        collectionView.backgroundColor = Colors.gray0.color
        collectionView.contentInset = .init(
            top: 0,
            left: 4,
            bottom: Layout.feedButtonHeight + Layout.feedButtonBottom + Layout.feedButtonSpacing,
            right: 4
        )
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    let feedButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.Community.feedButton, for: .normal)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.titleLabel?.font = Fonts.semiBold.font(size: 16)
        button.setImage(
            Icons.chevronRight.image.resizeImage(scaledTo: 16).withTintColor(Colors.systemWhite.color),
            for: .normal
        )
        button.semanticContentAttribute = .forceRightToLeft
        button.contentEdgeInsets = .init(top: 10, left: 16, bottom: 10, right: 12)
        button.titleEdgeInsets = .init(top: 0, left: -4, bottom: 0, right: 4)
        button.imageEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: -4)
        button.backgroundColor = Colors.mainPink.color
        button.layer.cornerRadius = Layout.feedButtonHeight / 2
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.systemBlack.color.withAlphaComponent(0.08).cgColor
        button.layer.shadowColor = Colors.systemBlack.color.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 3
        button.layer.shadowOffset = .zero
        return button
    }()

    override func setup() {
        super.setup()

        addSubViews([collectionView, feedButton])
    }

    override func bindConstraints() {
        super.bindConstraints()

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        feedButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-Layout.feedButtonTrailing)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-Layout.feedButtonBottom)
            $0.height.equalTo(Layout.feedButtonHeight)
        }
    }

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        return layout
    }
}
