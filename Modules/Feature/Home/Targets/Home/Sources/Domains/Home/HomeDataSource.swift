import UIKit

import Model

final class HomeDataSource: UICollectionViewDiffableDataSource<HomeSection, HomeSectionItem> {
    let viewModel: HomeViewModel
    
    init(
        collectionView: UICollectionView,
        viewModel: HomeViewModel,
        rootViewController: UIViewController
    ) {
        self.viewModel = viewModel
        
        collectionView.register([
            HomeStoreCardCell.self,
            HomeStoreEmptyCell.self,
            HomeCardAdvertisementCell.self
        ])
        
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .storeCard(let storeCard):
                let cell: HomeStoreCardCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                cell.bind(storeCard: storeCard)
                cell.visitButton
                    .controlPublisher(for: .touchUpInside)
                    .map { _ in indexPath.row }
                    .subscribe(viewModel.input.onTapVisitButton)
                    .store(in: &cell.cancellables)
                return cell
                
            case .empty:
                let cell: HomeStoreEmptyCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                return cell
                
            case .advertisement(let advertisement):
                let cell: HomeCardAdvertisementCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                cell.bind(advertisement: advertisement, in: rootViewController)
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
        case .empty:
            return HomeStoreEmptyCell.Layout.size
            
        case .storeCard:
            return HomeStoreCardCell.Layout.size    
            
        case .advertisement:
            return HomeCardAdvertisementCell.Layout.size
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.onTapStore.send(indexPath.item)
    }
}
