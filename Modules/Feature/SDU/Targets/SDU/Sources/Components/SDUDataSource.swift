import UIKit

import Common
import Model

public final class SDUDataSource: UICollectionViewDiffableDataSource<SDUSection, SDUItem> {
    public typealias Snapshot = NSDiffableDataSourceSnapshot<SDUSection, SDUItem>

    public init(collectionView: UICollectionView) {
        collectionView.register([
            SDUCalloutCell.self,
            SDUIconTextCardCell.self
        ])

        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .callout(let data):
                let cell: SDUCalloutCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(data)
                return cell

            case .iconText(let data):
                let cell: SDUIconTextCardCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(data)
                return cell
            }
        }
    }

    public func reload(_ items: [SDUItem], in section: SDUSection = .main) {
        var snapshot = Snapshot()
        snapshot.appendSections([section])
        snapshot.appendItems(items, toSection: section)
        apply(snapshot, animatingDifferences: false)
    }
}

public enum SDUSection: Hashable {
    case main
}

public enum SDUItem: Hashable {
    case callout(CalloutCard)
    case iconText(IconTextCardData)
}
