import UIKit

import RxSwift
import RxCocoa

final class StoreDetailView: BaseView {
    private let navigationView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.04
        $0.backgroundColor = .white
    }
    
    let backButton = UIButton().then {
        $0.setImage(R.image.ic_back_black(), for: .normal)
    }
    
    fileprivate let mainCategoryImage = UIImageView()
    
    let deleteRequestButton = UIButton().then {
        $0.setTitle(R.string.localization.store_detail_delete_request(), for: .normal)
        $0.setTitleColor(R.color.red(), for: .normal)
        $0.titleLabel?.font = .semiBold(size: 14)
    }
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    ).then {
        $0.register(
            StoreOverviewCollectionViewCell.self,
            forCellWithReuseIdentifier: StoreOverviewCollectionViewCell.registerId
        )
        $0.register(
            StoreVisitHistoryCollectionViewCell.self,
            forCellWithReuseIdentifier: StoreVisitHistoryCollectionViewCell.registerId
        )
        $0.register(
            StoreInfoCollectionViewCell.self,
            forCellWithReuseIdentifier: StoreInfoCollectionViewCell.registerId
        )
        $0.register(
            StoreMenuCollectionViewCell.self,
            forCellWithReuseIdentifier: StoreMenuCollectionViewCell.registerId
        )
        $0.register(
            StorePhotoCollectionViewCell.self,
            forCellWithReuseIdentifier: StorePhotoCollectionViewCell.registerId
        )
        $0.register(
            StoreAdCollectionViewCell.self,
            forCellWithReuseIdentifier: StoreAdCollectionViewCell.registerId
        )
        $0.register(
            StoreReviewCollectionViewCell.self,
            forCellWithReuseIdentifier: StoreReviewCollectionViewCell.registerId
        )
        $0.register(
            StoreDetailHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: StoreDetailHeaderView.registerId
        )
    }
    
    let visitButton = StoreDetailVisitButton()
    
    //  let storePhotoCollectionView = StorePhotoCollectionView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.collectionView.collectionViewLayout = self.generateCompositionalLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        self.collectionView.delegate = self
        self.addSubViews([
            self.navigationView,
            self.backButton,
            self.mainCategoryImage,
            self.deleteRequestButton,
            self.collectionView,
            self.visitButton
        ])
        self.backgroundColor = UIColor(r: 250, g: 250, b: 250)
    }
    
    override func bindConstraints() {
        self.navigationView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.top).offset(60)
        }
        
        self.backButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.centerY.equalTo(self.mainCategoryImage)
        }
        
        self.mainCategoryImage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
            make.bottom.equalTo(self.navigationView).offset(-3)
        }
        
        self.deleteRequestButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.mainCategoryImage)
            make.right.equalToSuperview().offset(-24)
        }
        
        self.collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(self.navigationView.snp.bottom).offset(-20)
        }
        
        self.visitButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-32)
        }
    }
    
    fileprivate func bind(category: StreetFoodCategory) {
        self.mainCategoryImage.setImage(urlString: category.imageUrl)
    }
    
    private func generateCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return .init { sectionIndex, _ in
            switch StreetFoodStoreDetailSection(rawValue: sectionIndex) {
            case .overview:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StoreOverviewCollectionViewCell.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StoreOverviewCollectionViewCell.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                return section
                
            case .visitHistory:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StoreVisitHistoryCollectionViewCell.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StoreVisitHistoryCollectionViewCell.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                return section
                
            case .info:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StoreInfoCollectionViewCell.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StoreInfoCollectionViewCell.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(StoreDetailHeaderView.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )]
                
                return section
                
            case .menus:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(StoreMenuCollectionViewCell.estimatedHeight)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(StoreMenuCollectionViewCell.estimatedHeight)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                return section
                
            case .photos:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .absolute(StorePhotoCollectionViewCell.cellSize.width),
                    heightDimension: .absolute(StorePhotoCollectionViewCell.cellSize.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .absolute(StorePhotoCollectionViewCell.cellSize.width),
                    heightDimension: .absolute(StorePhotoCollectionViewCell.cellSize.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.interGroupSpacing = 9
                section.orthogonalScrollingBehavior = .continuous
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(StoreDetailHeaderView.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )]
                
                return section
                
            case .reviewAndadvertisement:
                let advertisementItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StoreAdCollectionViewCell.height)
                ))
                let reviewItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(StoreReviewCollectionViewCell.estimatedHeight)
                ))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(StoreReviewCollectionViewCell.estimatedHeight)
                ), subitems: [advertisementItem, reviewItem])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(StoreDetailHeaderView.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )]
                
                return section
                
            case .unknown:
                return nil
                
            case .none:
                return nil
            }
        }
    }
    
    private func hideVisitButton() {
        let originalVisitButtonTransform = self.visitButton.transform
        
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, animations: { [weak self] in
            self?.visitButton.transform = originalVisitButtonTransform.translatedBy(x: 0.0, y: 90)
            self?.visitButton.alpha = 0
        })
    }
    
    private func showVisitButton() {
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, animations: { [weak self] in
            self?.visitButton.transform = .identity
            self?.visitButton.alpha = 1
        })
    }
}

extension Reactive where Base: StoreDetailView {
    var store: Binder<Store> {
        return Binder(self.base) { view, store in
            if let firstCategory = store.categories.first,
               let streetFoodCategory = MetaContext.shared.findStreetFoodCategory(
                category: firstCategory
               ) {
                view.bind(category: streetFoodCategory)
            }
        }
    }
}

extension StoreDetailView: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.hideVisitButton()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.showVisitButton()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.showVisitButton()
    }
}
