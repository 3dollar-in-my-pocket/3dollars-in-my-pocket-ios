import UIKit

import Common

import SnapKit

final class HomeCurationView: BaseView {
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 24, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    override func setup() {
        backgroundColor = .clear
        addSubview(collectionView)
    }

    override func bindConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
