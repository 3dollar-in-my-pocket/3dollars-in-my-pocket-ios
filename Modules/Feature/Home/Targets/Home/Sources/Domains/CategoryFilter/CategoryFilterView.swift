import UIKit

import Common
import DesignSystem

final class CategoryFilterView: BaseView {
    private let indicatorView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.gray20.color
        $0.layer.cornerRadius = 2
        $0.layer.masksToBounds = true
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
    
    override func setup() {
        addSubViews([
            indicatorView,
            collectionView
        ])
    }
    
    override func bindConstraints() {
        indicatorView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(56)
            $0.height.equalTo(4)
            $0.top.equalToSuperview().offset(8)
        }
        
        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalTo(indicatorView.snp.bottom).offset(8)
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func generateCollectionLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            if sectionIndex == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(CategoryBannerCell.size.height)
                ))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(CategoryBannerCell.size.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 24)
                section.boundarySupplementaryItems = [ .init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(CategoryFilterHeaderView.estimatedHeight)),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                
                return section
            } else {
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .absolute(CategoryFilterCell.size.width),
                    heightDimension: .absolute(CategoryFilterCell.size.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(CategoryFilterCell.size.height)
                ), subitems: [item])
                group.interItemSpacing = NSCollectionLayoutSpacing.fixed(12)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 24)
                section.interGroupSpacing = 12
                section.boundarySupplementaryItems = [ .init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(CategoryFilterHeaderView.estimatedHeight)),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                
                return section
            }
        }
    }
}
