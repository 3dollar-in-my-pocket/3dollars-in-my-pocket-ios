import UIKit

import Combine

struct PollDetailSection: Hashable {
    enum SectionType {
        case detail
        case banner
        case comment
    }

    var type: SectionType
    var items: [PollDetailSectionItem]
}

enum PollDetailSectionItem: Hashable {
    case detail
    case banner
    case comment(String)
    case blindComment

    func hash(into hasher: inout Hasher) {
        switch self {
        case .detail:
            hasher.combine("detail")
        case .banner:
            hasher.combine("banner")
        case .comment(let title):
            hasher.combine(title)
        case .blindComment:
            hasher.combine("blindComment")
        }
    }
}

final class PollDetailDataSource: UICollectionViewDiffableDataSource<PollDetailSection, PollDetailSectionItem> {

    private typealias Snapshot = NSDiffableDataSourceSnapshot<PollDetailSection, PollDetailSectionItem>

    init(collectionView: UICollectionView) {
        collectionView.register([
            PollDetailContentCell.self,
            PollDetailCommentCell.self
        ])

        collectionView.registerSectionHeader([
            PollDetailCommentHeaderView.self,
        ])

        super.init(collectionView: collectionView) {collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .detail:
                let cell: PollDetailContentCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind()
                return cell
            case .comment:
                let cell: PollDetailCommentCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind()
                return cell
            default:
                return UICollectionViewCell()
            }
        }

        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let section = self?.sectionIdentifier(section: indexPath.section) else {
                return nil
            }

            switch section.type {
            case .comment:
                let headerView: PollDetailCommentHeaderView = collectionView.dequeueReusableSupplementaryView(ofkind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
                headerView.bind(count: 24)
                return headerView
            default:
                return nil
            }
        }

        collectionView.delegate = self
    }

    func reloadData() {
        var snapshot = Snapshot()

        let sections: [PollDetailSection] = [
            .init(type: .detail, items: [.detail]),
            .init(type: .comment, items: [.comment("1"), .comment("2"), .comment("3"), .comment("4")])
        ]

        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: true)
    }
}

extension PollDetailDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width

        switch self[indexPath] {
        case .detail:
            return CGSize(width: width, height: PollDetailContentCell.Layout.height)
        case .comment:
            return CGSize(width: width, height: PollDetailCommentCell.Layout.height)
        default:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = UIScreen.main.bounds.width

        switch sectionIdentifier(section: section)?.type {
        case .comment:
            return CGSize(width: width, height: PollDetailCommentHeaderView.Layout.height)
        default:
            return .zero
        }
    }
}

extension PollDetailDataSource: UICollectionViewDelegate {

}
