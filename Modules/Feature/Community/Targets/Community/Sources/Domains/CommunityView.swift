import UIKit

import Common
import DesignSystem
import SnapKit
import Then

final class CommunityView: BaseView {

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = Colors.gray0.color
        $0.contentInset = .init(top: 0, left: 4, bottom: 24, right: 4)
        $0.showsVerticalScrollIndicator = false
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
