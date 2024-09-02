import UIKit

import Common

final class BookmarkViewerDatasource: UICollectionViewDiffableDataSource<BookmarkViewerSection, BookmarkViewerSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<BookmarkViewerSection, BookmarkViewerSectionItem>
    
    private let viewModel: BookmarkViewerViewModel
    
    init(
        collectionView: UICollectionView,
        viewModel: BookmarkViewerViewModel
    ) {
        self.viewModel = viewModel
        
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .overview(let uiModel):
                let cell: BookmarkViewerOverviewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(uiModel: uiModel)
                return cell
            case .store(let store):
                let cell: BookmarkStoreCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(store: store)
                return cell
            }
        }
        
        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            
            guard let section = self?.sectionIdentifier(section: indexPath.section) else { return nil }
            
            switch section.type {
            case .overview:
                return nil
            case .storeList(let count):
                let headerView: BookmarkViewerSectionHeaderView = collectionView.dequeueReusableSupplementaryView(
                    ofkind: UICollectionView.elementKindSectionHeader,
                    indexPath: indexPath
                )
                
                headerView.bind(totalCount: count)
                return headerView
            }
        }
        
        collectionView.register([
            BookmarkViewerOverviewCell.self,
            BookmarkStoreCell.self
        ])
        collectionView.registerSectionHeader([
            BookmarkViewerSectionHeaderView.self
        ])
        
        collectionView.delegate = self
    }
    
    func reload(_ sections: [BookmarkViewerSection]) {
        var snapshot = Snapshot()
        
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        apply(snapshot, animatingDifferences: false)
    }
    
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self,
                  let sectionIdentifier = sectionIdentifier(section: sectionIndex) else {
                fatalError("정의되지 않은 섹션입니다.")
            }
            
            switch sectionIdentifier.type {
            case .overview:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(BookmarkViewerOverviewCell.Layout.estimatedHeight)
                ))
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(BookmarkViewerOverviewCell.Layout.estimatedHeight)
                    ),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                return section
            case .storeList:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(BookmarkStoreCell.Layout.height)
                ))
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(BookmarkStoreCell.Layout.height)
                    ),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(BookmarkViewerSectionHeaderView.Layout.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                section.interGroupSpacing = 12
                section.contentInsets = .init(top: 0, leading: 20, bottom: 20, trailing: 20)
                
                return section
            }
        }
    }
}

extension BookmarkViewerDatasource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = sectionIdentifier(section: indexPath.section)?.type else { return }
        
        switch sectionType {
        case .overview:
            break
        case .storeList:
            viewModel.input.didTapStore.send(indexPath.item)
        }
    }
}
