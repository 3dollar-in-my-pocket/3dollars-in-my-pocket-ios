import UIKit

import Combine
import Model

struct CommunitySection: Hashable {
    enum SectionType {
        case pollList
        case popularStoreTab
        case popularStore
        case banner
    }

    var type: SectionType
    var items: [CommunitySectionItem]

    func hash(into hasher: inout Hasher) {
        switch type {
        case .pollList:
            hasher.combine("pollList")
        case .popularStoreTab:
            hasher.combine("popularStoreTab")
        case .popularStore:
            hasher.combine("popularStore")
        case .banner:
            hasher.combine("banner")
        }
    }
}

enum CommunitySectionItem: Hashable {
    case poll(CommunityPollListCellViewModel)
    case popularStoreTab(CommunityPopularStoreTabCellViewModel)
    case popularStore(PlatformStore)
    case banner

    var identifier: String {
        switch self {
        case .poll(let viewModel):
            return String(viewModel.identifier.hashValue)
        case .popularStoreTab(let viewModel):
            return String(viewModel.identifier.hashValue)
        case .popularStore(let item):
            return item.id
        case .banner:
            return "banner"
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

    init(collectionView: UICollectionView, viewModel: CommunityViewModel, containerVC: UIViewController) {
        self.viewModel = viewModel

        collectionView.register([
            CommunityPollListCell.self,
            CommunityPopularStoreTabCell.self,
            CommunityPopularStoreItemCell.self,
            CommunityBannerCell.self
        ])

        super.init(collectionView: collectionView) { [weak containerVC] collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .poll(let cellViewModel):
                let cell: CommunityPollListCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel: cellViewModel, rootViewController: containerVC)
                return cell
            case .popularStoreTab(let cellViewModel):
                let cell: CommunityPopularStoreTabCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel: cellViewModel)
                return cell
            case .popularStore(let item):
                let cell: CommunityPopularStoreItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(item: item)
                return cell
            case .banner:
                let cell: CommunityBannerCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(in: containerVC)
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

        apply(snapshot, animatingDifferences: false)
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
        case .banner:
            return CommunityBannerCell.Layout.size
        default:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch self.sectionIdentifier(section: section)?.type {
        case .popularStore:
            return .zero
        default:
            return 16
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch self.sectionIdentifier(section: section)?.type {
        case .popularStore:
            return .init(top: 0, left: 0, bottom: 24, right: 0)
        default:
            return .zero
        }
    }
}
