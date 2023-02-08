import UIKit

final class BookmarkViewerView: BaseView {
    private let topBackgroundView = UIView().then {
        $0.backgroundColor = Color.gray95
    }
    
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
            self.collectionView,
            self.topBackgroundView,
            self.closeButton
        ])
        
        self.collectionView.rx.contentOffset
            .filter { $0.y <= 0 }
            .map { abs($0.y) }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] offset in
                guard let self = self else { return }
                let topSafeAreaInset = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
                
                self.topBackgroundView.snp.updateConstraints({ make in
                    make.height.equalTo(topSafeAreaInset + 35 + offset)
                })
            })
            .disposed(by: self.disposeBag)
    }
    
    override func bindConstraints() {
        self.topBackgroundView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
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
