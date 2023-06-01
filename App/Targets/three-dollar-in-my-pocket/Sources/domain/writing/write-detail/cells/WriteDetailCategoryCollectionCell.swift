import UIKit

import DesignSystem

final class WriteDetailCategoryCollectionCell: BaseCollectionViewCell {
    enum Layout {
        static func size(count: Int) -> CGSize {
            return CGSize(width: UIScreen.main.bounds.width, height: WriteDetailCollectionItemCell.Layout.size.height + 24)
        }
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
        $0.contentInset = .init(top: 12, left: 12, bottom: 12, right: 12)
        $0.register([WriteDetailCollectionItemCell.self])
    }
    
    private func generateLayout() -> UICollectionViewFlowLayout {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.itemSize = WriteDetailCollectionItemCell.Layout.size
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 10
        
        return layout
    }
    
    override func setup() {
        backgroundColor = DesignSystemAsset.Colors.gray0.color
        contentView.addSubview(collectionView)
        
        
        collectionView.dataSource = self
    }
    
    override func bindConstraints() {
        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

extension WriteDetailCategoryCollectionCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: WriteDetailCollectionItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        
        return cell
    }
}
