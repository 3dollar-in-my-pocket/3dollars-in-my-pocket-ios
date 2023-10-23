import UIKit

final class HomeDataSource: UICollectionViewDiffableDataSource<HomeSection, HomeSectionItem> {
    let viewModel: HomeViewModel
    
    init(collectionView: UICollectionView, viewModel: HomeViewModel) {
        self.viewModel = viewModel
        
        collectionView.register([
            HomeStoreCardCell.self,
            HomeStoreEmptyCell.self
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
            
        default:
            return .zero
        }
        
    }
}
