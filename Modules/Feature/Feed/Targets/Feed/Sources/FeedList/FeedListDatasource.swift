import UIKit
import Model

struct FeedListSection: Hashable {
    var items: [FeedListSectionItem]
}

enum FeedListSectionItem: Hashable, Equatable {
    case advertisement(AdvertisementResponse?)
    case feed(FeedResponse)
    
    static func == (lhs: FeedListSectionItem, rhs: FeedListSectionItem) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .advertisement(let response):
            hasher.combine(response?.advertisementId)
        case .feed(let response):
            hasher.combine(response.feedId)
        }
    }
}

final class FeedListDatasource: UICollectionViewDiffableDataSource<FeedListSection, FeedListSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<FeedListSection, FeedListSectionItem>
    
    init(collectionView: UICollectionView, rootViewController: UIViewController) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .feed(let feed):
                let cell: FeedCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(feed: feed)
                return cell
            case .advertisement(let advertisement):
                let cell: FeedAdvertisementCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(advertisement: advertisement, rootViewController: rootViewController)
                return cell
            }
        }
        
        collectionView.register([
            FeedCell.self,
            FeedAdvertisementCell.self
        ])
    }
    
    func reload(_ sections: [FeedListSection]) {
        var snapshot = Snapshot()
        
        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }
        
        apply(snapshot, animatingDifferences: true)
    }
}
