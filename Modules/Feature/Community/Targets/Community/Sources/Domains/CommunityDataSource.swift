import UIKit

import Combine
import Model

struct CommunitySection: Hashable {
    var items: [CommunitySectionItem]
}

enum CommunitySectionItem: Hashable {
    case poll(CommunityPollListCellViewModel)
    case popularStoreTab(CommunityPopularStoreTabCellViewModel)
    case popularStore(PlatformStore)

    var identifier: String {
        switch self {
        case .poll(let viewModel):
            return String(viewModel.identifier.hashValue)
        case .popularStoreTab(let viewModel):
            return String(viewModel.identifier.hashValue)
        case .popularStore(let item):
            return item.id
        }
    }

    static func == (lhs: CommunitySectionItem, rhs: CommunitySectionItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

final class CommunityDataSource: UICollectionViewDiffableDataSource<CommunitySection, CommunitySectionItem> {

    typealias Snapshot = NSDiffableDataSourceSnapshot<CommunitySection, CommunitySectionItem>

    private let viewModel: CommunityViewModel

    init(collectionView: UICollectionView, viewModel: CommunityViewModel) {
        self.viewModel = viewModel

        collectionView.register([
            CommunityPollListCell.self,
            CommunityPopularStoreTabCell.self,
            CommunityPopularStoreItemCell.self
        ])

        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .poll(let cellViewModel):
                let cell: CommunityPollListCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel: cellViewModel)
                return cell
            case .popularStoreTab(let cellViewModel):
                let cell: CommunityPopularStoreTabCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel: cellViewModel)
                return cell
            case .popularStore(let item):
                let cell: CommunityPopularStoreItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(item: item)
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

extension CommunityDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.didSelect.send(indexPath)
    }
}

extension CommunityDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch self[indexPath] {
        case .poll:
            return CommunityPollListCell.Layout.size
        case .popularStoreTab:
            return CommunityPopularStoreTabCell.Layout.size
        case .popularStore:
            return CommunityPopularStoreItemCell.Layout.size
        default:
            return .zero
        }
    }
}
