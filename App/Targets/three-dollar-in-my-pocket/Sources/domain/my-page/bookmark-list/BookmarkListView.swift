import UIKit

final class BookmarkListView: BaseView {
    private let topBackgroundView = UIView().then {
        $0.backgroundColor = Color.gray95
    }
    
    let backButton = UIButton().then {
        $0.setImage(
            UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        $0.tintColor = .white
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "bookmark_list_title".localized
        $0.font = .semiBold(size: 16)
        $0.textColor = .white
    }
    
    let shareButton = UIButton().then {
        $0.setImage(
            UIImage(named: "ic_share")?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        $0.tintColor = Color.pink
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
            BookmarkEmptyCollectionViewCell.self,
            forCellWithReuseIdentifier: BookmarkEmptyCollectionViewCell.registerId
        )
        $0.register(
            BookmarkSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: BookmarkSectionHeaderView.registerId
        )
    }
    
    override func setup() {
        self.backgroundColor = Color.gray100
        self.addSubViews([
            self.topBackgroundView,
            self.backButton,
            self.titleLabel,
            self.shareButton,
            self.collectionView
        ])
        self.setCompositionalLayout()
        self.collectionView.rx.contentOffset
            .filter { $0.y < 0 }
            .map { abs($0.y) }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] offset in
                guard let self = self else { return }
                
                self.topBackgroundView.snp.updateConstraints { make in
                    make.bottom.equalTo(self.collectionView.snp.top).offset(offset)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    override func bindConstraints() {
        self.topBackgroundView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(self.collectionView.snp.top)
        }
        
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
        
        self.shareButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(self.backButton)
            make.width.equalTo(24)
            make.height.equalTo(24)
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
                let emptyItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(BookmarkEmptyCollectionViewCell.height)
                ))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(BookmarkEmptyCollectionViewCell.height)
                ), subitems: [storeItem, emptyItem])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(BookmarkSectionHeaderView.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                section.decorationItems = [
                    .background(elementKind: MyPageDecorationView.registerId)
                ]
                return section
            }
        }
        
        layout.register(
            MyPageDecorationView.self,
            forDecorationViewOfKind: MyPageDecorationView.registerId
        )
        
        self.collectionView.collectionViewLayout = layout
    }
}
