import UIKit

import Common
import DesignSystem
import SnapKit

public final class SDUCollectionView: UIView {
    public let collectionView: UICollectionView

    public init() {
        let layout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)

        setup()
        bindConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        collectionView.backgroundColor = Colors.systemWhite
        addSubview(collectionView)
    }

    private func bindConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    public func setLayout(_ layout: UICollectionViewLayout) {
        collectionView.collectionViewLayout = layout
    }
}
