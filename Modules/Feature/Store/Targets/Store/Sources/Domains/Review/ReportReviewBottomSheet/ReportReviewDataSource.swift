import UIKit

import Model

struct ReportReviewSection: Hashable {
    var items: [ReportReviewSectionItem]
}

enum ReportReviewSectionItem: Hashable {
    case reason(item: ReportReason)
    case reasonDetail
}

final class ReportReviewDataSource: UICollectionViewDiffableDataSource<ReportReviewSection, ReportReviewSectionItem> {
    private typealias Snapshot = NSDiffableDataSourceSnapshot<ReportReviewSection, ReportReviewSectionItem>
    
    private let viewModel: ReportReviewBottomSheetViewModel
    
    init(viewModel: ReportReviewBottomSheetViewModel, collectionView: UICollectionView) {
        self.viewModel = viewModel
        super.init(collectionView: collectionView) { [weak viewModel] collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .reason(let reason):
                let cell: ReportReviewReasonCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(title: reason.description)
                
                return cell
                
            case .reasonDetail:
                let cell: ReportReviewReasonDetailCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.didChangeText
                    .sink { [weak viewModel] text in
                        viewModel?.input.inputReasonDetail.send(text)
                    }
                    .store(in: &cell.cancellables)
                return cell
            }
        }
        
        collectionView.register([
            ReportReviewReasonCell.self,
            ReportReviewReasonDetailCell.self
        ])
        collectionView.delegate = self
    }
    
    func reloadData(sectionItems: [ReportReviewSectionItem], completion: (() -> Void)? = nil) {
        var snapshot = Snapshot()

        let sections: [ReportReviewSection] = [
            .init(items: sectionItems)
        ]
        
        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }
        
        apply(snapshot, animatingDifferences: false, completion: completion)
    }
}

extension ReportReviewDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let sectionItems = snapshot().sectionIdentifiers.first?.items,
              let item = sectionItems[safe: indexPath.item] else { return .zero }
        
        switch item {
        case .reason:
            return ReportReviewReasonCell.Layout.size
            
        case .reasonDetail:
            return ReportReviewReasonDetailCell.Layout.size
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.didTapReason.send(indexPath.item)
    }
}
