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
}

extension BookmarkListDatasource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = sectionIdentifier(section: indexPath.section)?.type else { return }
        
        switch sectionType {
        case .overview:
            break
        case .storeList:
            viewModel.input.didTapStore.send(indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let sectionType = sectionIdentifier(section: indexPath.section)?.type else { return }
        
        switch sectionType {
        case .overview:
            break
        case .storeList:
            viewModel.input.willDisplayCell.send(indexPath.item)
        }
    }
}
