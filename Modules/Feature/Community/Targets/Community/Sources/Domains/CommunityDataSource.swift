import UIKit

import Combine

struct CommunitySection: Hashable {
    var items: [CommunitySectionItem]
}

enum CommunitySectionItem: Hashable {
    case poll
    case popularStore(CommunityPopularStoreTabCellViewModel)
}

final class CommunityDataSource: UICollectionViewDiffableDataSource<CommunitySection, CommunitySectionItem> {

    typealias Snapshot = NSDiffableDataSourceSnapshot<CommunitySection, CommunitySectionItem>

    private let viewModel: CommunityViewModel

    init(collectionView: UICollectionView, viewModel: CommunityViewModel) {
        self.viewModel = viewModel

        collectionView.register([
            CommunityPollListCell.self,
            CommunityPopularStoreTabCell.self
        ])

        super.init(collectionView: collectionView) { [weak viewModel] collectionView, indexPath, itemIdentifier in
            guard let viewModel else { return UICollectionViewCell() }

            switch itemIdentifier {
            case .poll:
                let cell: CommunityPollListCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.categoryButton
                    .controlPublisher(for: .touchUpInside)
                    .mapVoid
                    .subscribe(viewModel.input.didTapPollCategoryButton)
                    .store(in: &cell.cancellables)
                cell.didSelectItem
                    .subscribe(viewModel.input.didSelectPollItem)
                    .store(in: &cell.cancellables)
                return cell
            case .popularStore(let cellViewModel):
                let cell: CommunityPopularStoreTabCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel: cellViewModel)
                return cell
            }
        }

        collectionView.delegate = self
    }

    func reload(_ sections: [CommunitySection]) {
        var snapshot = Snapshot()
        
        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: true)
    }
}

extension CommunityDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch self[indexPath] {
        case .poll:
            return CommunityPollListCell.Layout.size
        case .popularStore(let viewModel):
            return CommunityPopularStoreTabCell.Layout.size(viewModel: viewModel)
        default:
            return .zero
        }
    }
}
