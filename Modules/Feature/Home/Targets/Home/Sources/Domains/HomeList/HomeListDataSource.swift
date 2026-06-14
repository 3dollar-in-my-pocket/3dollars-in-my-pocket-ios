import UIKit

import Common
import Model

typealias HomeListSnapshot = NSDiffableDataSourceSnapshot<HomeListSection, HomeListSectionItem>

final class HomeListDataSource: UICollectionViewDiffableDataSource<HomeListSection, HomeListSectionItem> {
    private let viewModel: HomeListViewModel

    init(
        collectionView: UICollectionView,
        viewModel: HomeListViewModel,
        rootViewController: UIViewController
    ) {
        self.viewModel = viewModel

        collectionView.register([
            HomeListStoreCell.self,
            HomeListAdmobCell.self,
            HomeListEmptyCell.self
        ])

        super.init(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .basicCard(let card):
                let cell: HomeListStoreCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(card)
                return cell
            case .admobCard:
                let cell: HomeListAdmobCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(rootViewController: rootViewController)
                return cell
            case .emptyCard:
                let cell: HomeListEmptyCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                return cell
            }
        }

        collectionView.delegate = self
    }

    func reload(_ sections: [HomeListSection]) {
        var snapshot = HomeListSnapshot()
        for section in sections {
            snapshot.appendSections([section])
            snapshot.appendItems(section.items, toSection: section)
        }
        apply(snapshot, animatingDifferences: false)
    }
}

extension HomeListDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.didTapCard.send(indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplay.send(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIUtils.windowBounds.width
        
        switch itemIdentifier(for: indexPath) {
        case .basicCard(let response):
            let height = HomeListStoreCell.Layout.height(response: response)
            return CGSize(width: width, height: height)
        case .admobCard:
            let height = HomeListAdmobCell.Layout.height
            return CGSize(width: width, height: height)
        case .emptyCard:
            let height = HomeListEmptyCell.Layout.height
            return CGSize(width: width, height: height)
        case .none:
            return .zero
        }
    }
}
