import UIKit

import Common

final class BookmarkListDatasource: UICollectionViewDiffableDataSource<BookmarkListSection, BookmarkListSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<BookmarkListSection, BookmarkListSectionItem>
    
    private let viewModel: BookmarkListViewModel
    
    init(
        collectionView: UICollectionView,
        viewModel: BookmarkListViewModel
    ) {
        self.viewModel = viewModel
        
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .overview(let title, let introduction):
                let cell: BookmarkOverviewCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                cell.bind(title: title, introduction: introduction)
                return cell
            case .store(let viewModel):
                let cell: BookmarkStoreCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                cell.bind(viewModel, index: indexPath.item)
                return cell
            case .empty:
                let cell: BookmarkEmptyCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                return cell
            }
        }
        
        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let section = self?.sectionIdentifier(section: indexPath.section) else { return nil }
            
            switch section.type {
            case .overview:
                return nil
            case .storeList(let viewModel):
                let headerView: BookmarkSectionHeaderView = collectionView.dequeueReusableSupplementaryView(
                    ofkind: UICollectionView.elementKindSectionHeader,
                    indexPath: indexPath
                )
                
                headerView.bind(viewModel)
                return headerView
            case .empty:
                return nil
            }
        }
        
        collectionView.register([
            BookmarkEmptyCell.self,
            BookmarkStoreCell.self,
            BookmarkOverviewCell.self
        ])
        collectionView.registerSectionHeader([
            BookmarkSectionHeaderView.self
        ])
        collectionView.delegate = self
    }
    
    func reload(_ sections: [BookmarkListSection]) {
        var snapshot = Snapshot()
        
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        apply(snapshot, animatingDifferences: false)
    }
    
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self, let sectionType = sectionIdentifier(section: sectionIndex)?.type else {
                fatalError("정의되지 않은 섹션입니다.")
            }
            
            switch sectionType {
            case.empty:
                let emptyItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(BookmarkEmptyCell.Layout.height)
                ))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(BookmarkEmptyCell.Layout.height)
                ), subitems: [emptyItem])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
                
                return section
            case .overview:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(BookmarkOverviewCell.Layout.estimatedHeight)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(BookmarkOverviewCell.Layout.estimatedHeight)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
                
                return section
            case .storeList:
                let storeItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(BookmarkStoreCell.Layout.height)
                ))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(BookmarkStoreCell.Layout.height)
                ), subitems: [storeItem])
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(BookmarkSectionHeaderView.Layout.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
                return section
            }
        }
    }
}

extension BookmarkListDatasource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = sectionIdentifier(section: indexPath.section)?.type else { return }
        
        switch sectionType {
        case .overview:
            break
        case .storeList:
            viewModel.input.didTapStore.send(indexPath.item)
        case .empty:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let sectionType = sectionIdentifier(section: indexPath.section)?.type else { return }
        
        switch sectionType {
        case .overview:
            break
        case .storeList:
            viewModel.input.willDisplayCell.send(indexPath.item)
        case .empty:
            break
        }
    }
}
