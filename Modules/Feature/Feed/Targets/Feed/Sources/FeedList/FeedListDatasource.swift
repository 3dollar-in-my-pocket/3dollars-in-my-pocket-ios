import UIKit
import Combine

import Model

struct FeedListSection: Hashable {
    var items: [FeedListSectionItem]

    static func == (lhs: FeedListSection, rhs: FeedListSection) -> Bool {
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine("news")
    }
}

enum FeedListSectionItem: Hashable {
    case header(SDHeader)
    case skeleton(Int)
    case empty
    case error
    case contentCard(HomeNewsContentCard)
    case admobCard(HomeListAdmobCardResponse)

    var cardId: String? {
        switch self {
        case .contentCard(let card):
            return card.cardId
        case .admobCard(let card):
            return card.cardId
        case .header, .skeleton, .empty, .error:
            return nil
        }
    }
}

final class FeedListDatasource: UICollectionViewDiffableDataSource<FeedListSection, FeedListSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<FeedListSection, FeedListSectionItem>

    let didTapRetry: PassthroughSubject<Void, Never>
    let didTapImage: PassthroughSubject<FeedListViewModel.ImageTap, Never>
    let didTapAdmob: PassthroughSubject<String, Never>

    init(collectionView: UICollectionView, rootViewController: UIViewController) {
        let didTapRetry = PassthroughSubject<Void, Never>()
        let didTapImage = PassthroughSubject<FeedListViewModel.ImageTap, Never>()
        let didTapAdmob = PassthroughSubject<String, Never>()
        self.didTapRetry = didTapRetry
        self.didTapImage = didTapImage
        self.didTapAdmob = didTapAdmob
        super.init(collectionView: collectionView) { [weak rootViewController] collectionView, indexPath, itemIdentifier in
            let cellWidth = FeedListViewController.Layout.cellWidth(in: collectionView)
            switch itemIdentifier {
            case .header(let header):
                let cell: FeedListHeaderCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(header: header)
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
            case .contentCard(let card):
                let cell: FeedContentCardCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(card: card, cellWidth: cellWidth)
                cell.onTapImage = { blockIndex, imageIndex in
                    didTapImage.send(.init(cardId: card.cardId, blockIndex: blockIndex, imageIndex: imageIndex))
                }
                return cell
            case .admobCard(let card):
                let cell: FeedAdmobCardCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                if let rootViewController {
                    cell.bind(card: card, width: cellWidth, rootViewController: rootViewController)
                }
                cell.onClickAd = { didTapAdmob.send(card.cardId) }
                return cell
            }
        }

        collectionView.register([
            FeedListHeaderCell.self,
            FeedSkeletonCell.self,
            FeedEmptyCell.self,
            FeedErrorCell.self,
            FeedContentCardCell.self,
            FeedAdmobCardCell.self
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
