import UIKit

struct ReportPollSection: Hashable {
    var items: [ReportPollSectionItem]
}

enum ReportPollSectionItem: Hashable {
    case reason(String)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .reason(let title):
            hasher.combine(title)
        }
    }
}

final class ReportPollDataSource: UICollectionViewDiffableDataSource<ReportPollSection, ReportPollSectionItem> {

    private typealias Snapshot = NSDiffableDataSourceSnapshot<ReportPollSection, ReportPollSectionItem>

    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .reason(let title):
                let cell: ReportPollReasonCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(title: title)
                return cell
            }
        }

        collectionView.register([ReportPollReasonCell.self])
        collectionView.delegate = self
    }

    func reloadData() {
        var snapshot = Snapshot()

        let sections: [ReportPollSection] = [
            .init(items: [
                .reason("욕설, 비방, 혐오조장"),
                .reason("홍보, 영리목적"),
                .reason("도배, 스팸"),
                .reason("불법 정보"),
                .reason("기타")
            ])
        ]

        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: true)
    }
}

extension ReportPollDataSource: UICollectionViewDelegate {

}

extension ReportPollDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: ReportPollReasonCell.Layout.height)
    }
}
