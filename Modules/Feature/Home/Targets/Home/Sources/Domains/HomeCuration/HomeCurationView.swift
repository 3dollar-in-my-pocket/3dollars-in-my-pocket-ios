import UIKit

import Common
import DesignSystem

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

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray70.color
        label.textAlignment = .center
        label.text = Strings.HomeCuration.Empty.title
        label.isHidden = true
        return label
    }()

    override func setup() {
        backgroundColor = .clear
        addSubViews([collectionView, emptyLabel])
    }

    override func bindConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(HomeCurationCarouselCell.Layout.emptyVerticalInset)
            $0.leading.trailing.equalToSuperview().inset(HomeCurationCarouselCell.Layout.horizontalInset)
            $0.height.equalTo(HomeCurationCarouselCell.Layout.emptyLabelHeight)
        }
    }

    func setEmpty(_ isEmpty: Bool) {
        emptyLabel.isHidden = isEmpty.isNot
    }
}
