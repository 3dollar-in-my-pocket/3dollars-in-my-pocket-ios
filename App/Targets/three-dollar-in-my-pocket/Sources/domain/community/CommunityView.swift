import UIKit

import Common
import DesignSystem
import SnapKit

final class CommunityView: BaseView {

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = Colors.gray0.color
        $0.contentInset = .init(top: 0, left: 4, bottom: 0, right: 4)
        $0.showsVerticalScrollIndicator = false
        $0.isPagingEnabled = true
    }

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
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16

        return layout
    }
}
