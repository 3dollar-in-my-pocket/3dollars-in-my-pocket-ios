import UIKit

import Common
import DesignSystem
import SnapKit

final class CommunityView: BaseView {

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        collectionView.backgroundColor = Colors.gray0.color
        collectionView.contentInset = .init(top: 0, left: 4, bottom: 0, right: 4)
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    override func setup() {
        super.setup()

        addSubViews([collectionView])
    }

    override func bindConstraints() {
        super.bindConstraints()

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        return layout
    }
}
