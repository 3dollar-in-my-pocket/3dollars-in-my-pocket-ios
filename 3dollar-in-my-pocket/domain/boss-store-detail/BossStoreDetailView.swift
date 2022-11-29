import UIKit

import RxSwift
import RxCocoa

final class BossStoreDetailView: BaseView {
    private let navigationContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    let backButton = UIButton().then {
        $0.setImage(R.image.ic_back_black(), for: .normal)
    }
    
    private let categoryImageView = UIImageView()
    
    let feedbackButton = UIButton().then {
        $0.setTitle(R.string.localization.boss_store_feedback(), for: .normal)
        $0.titleLabel?.font = .semiBold(size: 14)
        $0.setTitleColor(R.color.green(), for: .normal)
    }
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    ).then {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            if sectionIndex == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(BossStoreOverviewCell.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(BossStoreOverviewCell.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            } else if sectionIndex == 1 {
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(BossStoreInfoCell.estimatedHeight)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(BossStoreInfoCell.estimatedHeight)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(BossStoreHeaderView.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                return section
            } else if sectionIndex == 2 {
                let menuItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(BossStoreMenuCell.height)
                ))
                let emptyMenuItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(BossStoreEmptyMenuCell.height)
                ))
                let moreItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(BossStoreMoreMenuCell.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(BossStoreMenuCell.height)
                ), subitems: [menuItem, moreItem, emptyMenuItem])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(BossStoreHeaderView.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                return section
            } else if sectionIndex == 3 {
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(BossStoreWorkdayCell.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(BossStoreWorkdayCell.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(BossStoreHeaderView.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                return section
            } else {
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(BossStoreFeedbacksCell.estimatedHeight)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(BossStoreFeedbacksCell.estimatedHeight)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(BossStoreHeaderView.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                section.contentInsets = .init(top: 0, leading: 0, bottom: 20, trailing: 0)
                return section
            }
        }
        
        $0.collectionViewLayout = layout
        $0.backgroundColor = R.color.gray0()
        $0.register(
            BossStoreOverviewCell.self,
            forCellWithReuseIdentifier: BossStoreOverviewCell.registerId
        )
        $0.register(
            BossStoreInfoCell.self,
            forCellWithReuseIdentifier: BossStoreInfoCell.registerId
        )
        $0.register(
            BossStoreMenuCell.self,
            forCellWithReuseIdentifier: BossStoreMenuCell.registerId
        )
        $0.register(
            BossStoreMoreMenuCell.self,
            forCellWithReuseIdentifier: BossStoreMoreMenuCell.registerId
        )
        $0.register(
            BossStoreEmptyMenuCell.self,
            forCellWithReuseIdentifier: BossStoreEmptyMenuCell.registerId
        )
        $0.register(
            BossStoreWorkdayCell.self,
            forCellWithReuseIdentifier: BossStoreWorkdayCell.registerId
        )
        $0.register(
            BossStoreFeedbacksCell.self,
            forCellWithReuseIdentifier: BossStoreFeedbacksCell.registerId
        )
        $0.register(
            BossStoreHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: BossStoreHeaderView.registerId
        )
    }
    
    fileprivate let storeClosedTagView = PaddingLabel(
        topInset: 10,
        bottomInset: 10,
        leftInset: 16,
        rightInset: 16
    ).then {
        $0.backgroundColor = R.color.gray95()
        $0.layer.cornerRadius = 20
        $0.text = R.string.localization.boss_store_closed()
        $0.font = .medium(size: 14)
        $0.textColor = .white
        $0.layer.masksToBounds = true
        $0.isHidden = true
    }
    
    override func setup() {
        self.addSubViews([
            self.collectionView,
            self.navigationContainerView,
            self.backButton,
            self.categoryImageView,
            self.feedbackButton,
            self.storeClosedTagView
        ])
    }
    
    override func bindConstraints() {
        self.navigationContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.top).offset(59)
        }
        
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.bottom.equalTo(self.navigationContainerView).offset(-21)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        self.categoryImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.backButton)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        
        self.feedbackButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(self.backButton)
        }
        
        self.collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(self.navigationContainerView.snp.bottom).offset(-20)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.storeClosedTagView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(40)
        }
    }
    
    fileprivate func bind(category: Categorizable) {
        if let foodTruckCategory = category as? FoodTruckCategory {
            self.categoryImageView.setImage(urlString: foodTruckCategory.imageUrl)
        }
    }
}

extension Reactive where Base: BossStoreDetailView {
    var category: Binder<Categorizable> {
        return Binder(self.base) { view, category in
            view.bind(category: category)
        }
    }
    
    var isStoreOpen: Binder<Bool> {
        return base.storeClosedTagView.rx.isHidden
    }
}
