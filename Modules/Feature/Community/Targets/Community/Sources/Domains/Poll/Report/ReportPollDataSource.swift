import UIKit

import Model

struct ReportPollSection: Hashable {
    var items: [ReportPollSectionItem]
}

enum ReportPollSectionItem: Hashable {
    case reason(item: PollReportReason, isSelected: Bool)
    case reasonDetail

    func hash(into hasher: inout Hasher) {
        switch self {
        case .reason(let item, let isSelected):
            hasher.combine(item.type)
            hasher.combine(isSelected)
        case .reasonDetail:
            hasher.combine("reasonDetail")
        }
    }
}

final class ReportPollDataSource: UICollectionViewDiffableDataSource<ReportPollSection, ReportPollSectionItem> {
    
    private typealias Snapshot = NSDiffableDataSourceSnapshot<ReportPollSection, ReportPollSectionItem>
    
    init(viewModel: ReportPollViewModel, collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { [weak viewModel] collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .reason(let item, let isSelected):
                let cell: ReportPollReasonCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(title: item.description, isSelected: isSelected)
                return cell
            case .reasonDetail:
                let cell: ReportPollReasonDetailCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.didChangeText
                    .sink { [weak viewModel] text in
                        viewModel?.input.didChangeText.send(text)
                    }
                    .store(in: &cell.cancellables)
                return cell
            }
        }
        
        collectionView.register([
            ReportPollReasonCell.self,
            ReportPollReasonDetailCell.self
        ])
    }
    
    func reloadData(sectionItems: [ReportPollSectionItem], completion: (() -> Void)? = nil) {
        var snapshot = Snapshot()

        let sections: [ReportPollSection] = [
            .init(items: sectionItems)
        ]
        
        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }
        
        apply(snapshot, animatingDifferences: false, completion: completion)
    }
}
