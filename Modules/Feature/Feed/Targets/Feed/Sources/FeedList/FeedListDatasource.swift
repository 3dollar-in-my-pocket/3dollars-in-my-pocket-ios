import UIKit
import Combine

import Model

struct FeedListSection: Hashable {
    var items: [FeedListSectionItem]
}

enum FeedListSectionItem: Hashable, Equatable {
    case header
    case advertisement(AdvertisementResponse?)
    case skeleton(Int)
    case empty
    case error
    case feed(FeedResponse)

    static func == (lhs: FeedListSectionItem, rhs: FeedListSectionItem) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .header:
            hasher.combine("header")
        case .advertisement(let response):
            hasher.combine("advertisement")
            hasher.combine(response?.advertisementId)
        case .skeleton(let index):
            hasher.combine("skeleton")
            hasher.combine(index)
        case .empty:
            hasher.combine("empty")
        case .error:
            hasher.combine("error")
        case .feed(let response):
            hasher.combine(response.feedId)
        }
    }
}

final class FeedListDatasource: UICollectionViewDiffableDataSource<FeedListSection, FeedListSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<FeedListSection, FeedListSectionItem>

    let didTapRetry: PassthroughSubject<Void, Never>

    init(collectionView: UICollectionView, rootViewController: UIViewController) {
        let didTapRetry = PassthroughSubject<Void, Never>()
        self.didTapRetry = didTapRetry
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .header:
                let cell: FeedListHeaderCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                return cell
            case .advertisement(let advertisement):
                let cell: FeedAdvertisementCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(advertisement: advertisement, rootViewController: rootViewController)
                return cell
            case .skeleton:
                let cell: FeedSkeletonCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                return cell
            case .empty:
                let cell: FeedEmptyCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                return cell
            case .error:
                let cell: FeedErrorCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.onTapRetry = { didTapRetry.send(()) }
                return cell
            case .feed(let feed):
                let cell: FeedCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(feed: feed, cellWidth: FeedListViewController.Layout.cellWidth(in: collectionView))
                return cell
            }
        }

        collectionView.register([
            FeedListHeaderCell.self,
            FeedAdvertisementCell.self,
            FeedSkeletonCell.self,
            FeedEmptyCell.self,
            FeedErrorCell.self,
            FeedCell.self
        ])
    }

    func reload(_ sections: [FeedListSection]) {
        var snapshot = Snapshot()

        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: false)
    }
}
