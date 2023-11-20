import UIKit

import Combine

struct PollDetailSection: Hashable {
    enum SectionType {
        case detail
        case banner
        case comment(totalCount: Int)
    }

    var type: SectionType
    var items: [PollDetailSectionItem]

    func hash(into hasher: inout Hasher) {
        switch type {
        case .detail:
            hasher.combine("detail")
        case .banner:
            hasher.combine("banner")
        case .comment(let count):
            hasher.combine(count)
        }
    }

    static func == (lhs: PollDetailSection, rhs: PollDetailSection) -> Bool {
        switch (lhs.type, rhs.type) {
        case (.detail, .detail):
            return true
        case (.banner, .banner):
            return true
        case (.comment(let lhsCount), .comment(let rhsCount)):
            return lhsCount == rhsCount
        default:
            return false
        }
    }
}

enum PollDetailSectionItem: Hashable {
    case detail(PollItemCellViewModel)
    case banner
    case comment(PollDetailCommentCellViewModel)
    case blindComment(String)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .detail(let viewModel):
            hasher.combine(viewModel.hashValue)
        case .banner:
            hasher.combine("banner")
        case .comment(let viewModel):
            hasher.combine(viewModel.hashValue)
        case .blindComment(let id):
            hasher.combine(id)
        }
    }
}

final class PollDetailDataSource: UICollectionViewDiffableDataSource<PollDetailSection, PollDetailSectionItem> {

    private typealias Snapshot = NSDiffableDataSourceSnapshot<PollDetailSection, PollDetailSectionItem>

    init(collectionView: UICollectionView, containerVC: UIViewController) {
        collectionView.register([
            PollDetailContentCell.self,
            PollDetailCommentCell.self,
            PollDetailBlindCommentCell.self
        ])

        collectionView.registerSectionHeader([
            PollDetailCommentHeaderView.self,
        ])

        super.init(collectionView: collectionView) { [weak containerVC] collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .detail(let cellViewModel):
                let cell: PollDetailContentCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel: cellViewModel)
                return cell
            case .comment(let cellViewModel):
                let cell: PollDetailCommentCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel: cellViewModel)
                cell.containerVC = containerVC
                return cell
            case .blindComment:
                let cell: PollDetailBlindCommentCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
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
            case .comment(let totalCount):
                let headerView: PollDetailCommentHeaderView = collectionView.dequeueReusableSupplementaryView(ofkind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
                headerView.bind(count: totalCount)
                return headerView
            default:
                return nil
            }
        }
    }

    func reloadData(_ sections: [PollDetailSection]) {
        var snapshot = Snapshot()

        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: false)
    }
}
