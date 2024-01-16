import UIKit

import Combine
import Model
import DesignSystem

struct MyMedalSection: Hashable {
    enum MyMedalSectionType {
        case currentMedal
        case medal
    }
    
    var type: MyMedalSectionType
    var items: [MyMedalSectionItem]
}

enum MyMedalSectionItem: Hashable {
    case currentMedal(Medal)
    case medal(Medal)
    
    var identifier: String {
        switch self {
        case .currentMedal(let medal):
            "currentMedal\(medal.medalId ?? 0)"
        case .medal(let medal):
            "medal\(medal.medalId ?? 0)"
        }
    }
    
    static func == (lhs: MyMedalSectionItem, rhs: MyMedalSectionItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

final class MyMedalDataSource: UICollectionViewDiffableDataSource<MyMedalSection, MyMedalSectionItem> {

    typealias Snapshot = NSDiffableDataSourceSnapshot<MyMedalSection, MyMedalSectionItem>

    init(collectionView: UICollectionView, viewModel: MyMedalViewModel) {

        collectionView.register([
            MyMedalCollectionCell.self,
            MedalCollectionCell.self
        ])
        
        collectionView.registerSectionHeader([
            MedalHeaderView.self
        ])
        
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .currentMedal(let medal):
                let cell: MyMedalCollectionCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(medal: medal)
                return cell
            case .medal(let medal):
                let cell: MedalCollectionCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(medal: medal)
                return cell
            default:
                return UICollectionViewCell()
            }
        }
        
        supplementaryViewProvider = { [weak self, weak viewModel] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let section = self?.sectionIdentifier(section: indexPath.section) else {
                return nil
            }
            
            switch section.type {
            case .currentMedal:
                return nil
            case .medal:
                let headerView: MedalHeaderView = collectionView.dequeueReusableSupplementaryView(ofkind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
                headerView.infoButton
                    .controlPublisher(for: .touchUpInside)
                    .sink { [weak viewModel] _ in
                        viewModel?.input.didSelectInfoButton.send()
                    }
                    .store(in: &headerView.cancellables)
                return headerView
            }
        }
    }

    func reload(_ sections: [MyMedalSection]) {
        var snapshot = Snapshot()
        
        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: false)
    }
}

