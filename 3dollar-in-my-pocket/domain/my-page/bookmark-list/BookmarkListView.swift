import UIKit

final class BookmarkListView: BaseView {
    let backButton = UIButton().then {
        $0.setImage(
            R.image.ic_back()?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        $0.tintColor = .white
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "즐겨찾기"
        $0.font = .semiBold(size: 16)
        $0.textColor = .white
    }
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    ).then {
        $0.backgroundColor = .clear
        $0.register(
            BookmarkOverviewCollectionViewCell.self,
            forCellWithReuseIdentifier: BookmarkOverviewCollectionViewCell.registerId
        )
        $0.register(
            BookmarkStoreCollectionViewCell.self,
            forCellWithReuseIdentifier: BookmarkStoreCollectionViewCell.registerId
        )
        $0.register(
            BookmarkSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: BookmarkSectionHeaderView.registerId
        )
    }
    
    override func setup() {
        self.backgroundColor = R.color.gray100()
        self.addSubViews([
            self.backButton,
            self.titleLabel,
            self.collectionView
        ])
        self.setCompositionalLayout()
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(15)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.backButton)
        }
        
        self.collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.backButton.snp.bottom).offset(21)
        }
    }
    
    private func setCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            if sectionIndex == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(BookmarkOverviewCollectionViewCell.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(BookmarkOverviewCollectionViewCell.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            } else {
                let storeItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(BookmarkStoreCollectionViewCell.height)
                ))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(BookmarkStoreCollectionViewCell.height)
                ), subitems: [storeItem])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(BookmarkSectionHeaderView.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                return section
            }
        }
        
        self.collectionView.collectionViewLayout = layout
    }
}
