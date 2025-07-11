import UIKit

import Model

typealias HomeStoreCardSanpshot = NSDiffableDataSourceSnapshot<HomeCardSection, HomeCardSectionItem>

final class HomeDataSource: UICollectionViewDiffableDataSource<HomeCardSection, HomeCardSectionItem> {
    private let viewModel: HomeViewModel
    
    init(
        collectionView: UICollectionView,
        viewModel: HomeViewModel,
        rootViewController: UIViewController
    ) {
        self.viewModel = viewModel
        
        collectionView.register([
            HomeStoreCardCell.self,
            HomeStoreEmptyCell.self,
            HomeAdvertisementCardCell.self,
            HomeAdmobCardCell.self
        ])
        
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .store(let viewModel):
                let cell: HomeStoreCardCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel: viewModel)
                return cell
            case .advertisement(let data):
                let cell: HomeAdvertisementCardCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(data)
                return cell
            case .admob(let data):
                let cell: HomeAdmobCardCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(rootViewController: rootViewController)
                return cell
            case .empty:
                let cell: HomeStoreEmptyCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                return cell
            }
        }
        
        collectionView.delegate = self
    }
}

extension HomeDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let sectionItem = snapshot().itemIdentifiers[safe: indexPath.item] else { return .zero }
        
        switch sectionItem {
        case .store:
            return HomeStoreCardCell.Layout.size
        case .advertisement:
            return HomeAdvertisementCardCell.Layout.size
        case .admob:
            return HomeAdmobCardCell.Layout.size
        case .empty:
            return HomeStoreEmptyCell.Layout.size
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.onTapStore.send(indexPath.item)
    }
}
