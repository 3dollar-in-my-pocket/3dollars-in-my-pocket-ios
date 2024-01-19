import UIKit

import Combine
import Model
import DesignSystem

final class MyPageDataSource: UICollectionViewDiffableDataSource<MyPageSection, MyPageSectionItem> {

    typealias Snapshot = NSDiffableDataSourceSnapshot<MyPageSection, MyPageSectionItem>

    init(collectionView: UICollectionView) {

        collectionView.register([
            MyPageOverviewCell.self,
            MyPageStoreListCell.self,
            MyPageEmptyCell.self,
            MyPagePollTotalParticipantsCountCell.self,
            MyPagePollItemCell.self
        ])
        
        collectionView.registerSectionHeader([MyPageSectionHeaderView.self])

        super.init(collectionView: collectionView) {collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .overview(let viewModel):
                let cell: MyPageOverviewCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel: viewModel)
                return cell
            case .visitStore(let viewModel):
                let cell: MyPageStoreListCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel)
                return cell
            case .favoriteStore(let viewModel):
                let cell: MyPageStoreListCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel)
                return cell
            case .empty(let type):
                let cell: MyPageEmptyCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(type)
                return cell
            case .pollTotalParticipantsCount(let count):
                let cell: MyPagePollTotalParticipantsCountCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(count)
                return cell
            case .poll(let data, let isFirst, let isLast):
                let cell: MyPagePollItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(data, isFirst: isFirst, isLast: isLast)
                return cell
            }
        }
        
        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let section = self?.sectionIdentifier(section: indexPath.section) else {
                return nil
            }
            
            switch section.type {
            case .overview:
                return nil
            case .visitStore, .favoriteStore, .poll:
                let headerView: MyPageSectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofkind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
                if let viewModel = section.headerViewModel {
                    headerView.bind(viewModel: viewModel)
                }
                return headerView
            }
        }
    }

    func reload(_ sections: [MyPageSection]) {
        var snapshot = Snapshot()
        
        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: false)
    }
}
