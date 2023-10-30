import UIKit

import Model

struct BossStoreFeedbackSection: Hashable {
    var items: [BossStoreFeedbackSectionItem]
}

enum BossStoreFeedbackSectionItem: Hashable {
    case feedback(item: FeedbackType, isSelected: Bool)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .feedback(let item, let isSelected):
            hasher.combine(item)
            hasher.combine(isSelected)
        }
    }
}

final class BossStoreFeedbackDataSource: UICollectionViewDiffableDataSource<BossStoreFeedbackSection, BossStoreFeedbackSectionItem> {

    private typealias Snapshot = NSDiffableDataSourceSnapshot<BossStoreFeedbackSection, BossStoreFeedbackSectionItem>

    init(viewModel: BossStoreFeedbackViewModel, collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { [weak viewModel] collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .feedback(let item, let isSelected):
                let cell: BossStoreFeedbackItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(emoji: item.emoji, title: item.description, isSelected: isSelected)
                return cell
            }
        }

        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let section = self?.sectionIdentifier(section: indexPath.section) else {
                return nil
            }

            let headerView: BossStoreFeedbackHeaderCell = collectionView.dequeueReusableSupplementaryView(ofkind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
            return headerView
        }

        collectionView.register([
            BossStoreFeedbackItemCell.self
        ])

        collectionView.registerSectionHeader([
            BossStoreFeedbackHeaderCell.self,
        ])
    }

    func reloadData(sectionItems: [BossStoreFeedbackSectionItem], completion: (() -> Void)? = nil) {
        var snapshot = Snapshot()

        let sections: [BossStoreFeedbackSection] = [
            .init(items: sectionItems)
        ]

        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: false, completion: completion)
    }
}
