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
            case .callout(let viewModel):
                let cell: SDUCalloutCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel)
                return cell

            case .iconText(let viewModel):
                let cell: SDUIconTextCardCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel)
                return cell
            }
        }
    }

    public func reload(_ items: [SDUItem]) {
        let section = SDUSection(type: .main, items: items)
        reload(sections: [section])
    }

    public func reload(sections: [SDUSection]) {
        var snapshot = Snapshot()

        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        apply(snapshot, animatingDifferences: false)
    }
}

public struct SDUSection: Hashable {
    public let type: SDUSectionType
    public let items: [SDUItem]

    public enum SDUSectionType: Hashable {
        case main
    }
}

public enum SDUItem: Hashable {
    case callout(SDUCalloutCellViewModel)
    case iconText(SDUIconTextCardCellViewModel)
}
