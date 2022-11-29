import UIKit

import RxSwift
import RxCocoa
import NMapsMap

final class FoodTruckListView: BaseView {
    private let topContainerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        $0.backgroundColor = .white
    }
    
    private let categoryImageView = UIImageView()
    
    private let categoryLabel = UILabel().then {
        $0.font = .extraBold(size: 18)
        $0.textColor = .black
        $0.textAlignment = .left
    }
    
    let categoryButton = UIButton().then {
        $0.setImage(R.image.ic_arrow_bottom_black(), for: .normal)
    }
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    ).then {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            if sectionIndex == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StreetFoodListMapCell.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StreetFoodListMapCell.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            } else {
                let storeItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(StreetFoodListEmptyCell.height)
                ))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(FoodTruckListStoreCell.height)
                ), subitems: [storeItem])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(FoodTruckListHeaderView.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                return section
            }
        }
        $0.collectionViewLayout = layout
        $0.backgroundColor = R.color.gray0()
        $0.register(
            StreetFoodListMapCell.self,
            forCellWithReuseIdentifier: StreetFoodListMapCell.registerId
        )
        $0.register(
            FoodTruckListStoreCell.self,
            forCellWithReuseIdentifier: FoodTruckListStoreCell.registerId
        )
        $0.register(
            StreetFoodListEmptyCell.self,
            forCellWithReuseIdentifier: StreetFoodListEmptyCell.registerId
        )
        $0.register(
            StreetFoodListAdvertisementCell.self,
            forCellWithReuseIdentifier: StreetFoodListAdvertisementCell.registerId
        )
        $0.register(
            FoodTruckListHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: FoodTruckListHeaderView.registerId
        )
    }
        
    override func setup() {
        self.backgroundColor = R.color.gray0()
        self.addSubViews([
            self.collectionView,
            self.topContainerView,
            self.categoryImageView,
            self.categoryLabel,
            self.categoryButton
        ])
    }
    
    override func bindConstraints() {
        self.topContainerView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.top).offset(60)
        }
        
        self.categoryImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.bottom.equalTo(self.topContainerView.snp.bottom).offset(-20)
            make.width.equalTo(32)
            make.height.equalTo(32)
        }
        
        self.categoryLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.categoryImageView)
            make.left.equalTo(self.categoryImageView.snp.right).offset(12)
            make.right.equalTo(self.categoryButton.snp.left).offset(-12)
        }
        
        self.categoryButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(self.categoryImageView)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        self.collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.topContainerView.snp.bottom).offset(-20)
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
    
    fileprivate func bind(category: FoodTruckCategory) {
        self.categoryImageView.setImage(urlString: category.imageUrl)
        self.categoryLabel.text = category.name
    }
}

extension Reactive where Base: FoodTruckListView {
    var category: Binder<FoodTruckCategory> {
        return Binder(self.base) { view, category in
            view.bind(category: category)
        }
    }
}
