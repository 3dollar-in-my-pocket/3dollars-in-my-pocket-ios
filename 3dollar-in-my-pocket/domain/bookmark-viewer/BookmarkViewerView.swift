import UIKit

final class BookmarkViewerView: BaseView {
    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_close_white"), for: .normal)
    }
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    ).then {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let item = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(BookmarkViewerStoreCollectionViewCell.height)
            ))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(BookmarkViewerStoreCollectionViewCell.height)
            ), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            
            section.boundarySupplementaryItems = [.init(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(400)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .topLeading
            )]
            return section
        }
        
        $0.collectionViewLayout = layout
        $0.register([BookmarkViewerStoreCollectionViewCell.self])
        $0.registerSectionHeader([BookmarkViewerHeaderView.self])
        $0.backgroundColor = .clear
    }
    
    override func setup() {
        self.backgroundColor = Color.gray100
        self.addSubViews([
            self.closeButton,
            self.collectionView
        ])
    }
    
    override func bindConstraints() {
        self.closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(10)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
        
        self.collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.closeButton.snp.bottom)
        }
    }
}
