import UIKit

import Common
import DesignSystem

final class CategoryFilterView: BaseView {
    private let handleBar = HandleBar()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
    
    override func setup() {
        setupUI()
    }
    
    private func setupUI() {
        addSubViews([
            handleBar,
            collectionView
        ])
        
        handleBar.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalTo(safeAreaLayoutGuide)
            $0.top.equalTo(handleBar.snp.bottom)
            $0.trailing.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func generateCollectionLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            if sectionIndex == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(CategoryBannerCell.Layout.height)
                ))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(CategoryBannerCell.Layout.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 24)
                section.boundarySupplementaryItems = [ .init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(CategoryFilterHeaderView.Layout.estimatedHeight)),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                
                return section
            } else {
                let cellSize = CategoryFilterCell.Layout.size(
                    containerWidth: layoutEnvironment.container.effectiveContentSize.width
                )
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .absolute(cellSize.width),
                    heightDimension: .absolute(cellSize.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(cellSize.height)
                ), subitems: [item])
                group.interItemSpacing = NSCollectionLayoutSpacing.fixed(CategoryFilterCell.Layout.spacing)
                let section = NSCollectionLayoutSection(group: group)
                let horizontalInset = CategoryFilterCell.Layout.horizontalInset
                section.contentInsets = .init(top: 0, leading: horizontalInset, bottom: 0, trailing: horizontalInset)
                section.interGroupSpacing = CategoryFilterCell.Layout.spacing
                section.boundarySupplementaryItems = [ .init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(CategoryFilterHeaderView.Layout.estimatedHeight)),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                
                return section
            }
        }
    }
}
