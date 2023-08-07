import UIKit

typealias HomeListSnapshot = NSDiffableDataSourceSnapshot<HomeListSection, HomeListSectionItem>

final class HomeListDataSource: UICollectionViewDiffableDataSource<HomeListSection, HomeListSectionItem> {
    let viewModel: HomeListViewModel
    
    init(collectionView: UICollectionView, viewModel: HomeListViewModel) {
        self.viewModel = viewModel
        
        collectionView.register([HomeListCell.self])
        collectionView.registerSectionHeader([HomeListHeaderCell.self])
        
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .storeCard(let storeCard):
                let cell: HomeListCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                cell.bind(storeCard: storeCard)
                return cell
            }
        }
        
        collectionView.delegate = self
        
        self.supplementaryViewProvider = { collectionView, type, indexPath -> UICollectionReusableView? in
            let headerView: HomeListHeaderCell = collectionView.dequeueReusableSupplementaryView(ofkind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
            
            headerView.isOnlyCertifiedButton
                .controlPublisher(for: .touchUpInside)
                .withUnretained(headerView)
                .handleEvents(receiveOutput: { headerView, _ in
                    headerView.isOnlyCertifiedButton.isSelected.toggle()
                })
                .mapVoid
                .subscribe(viewModel.input.onToggleCertifiedStore)
                .store(in: &headerView.cancellables)
            
            viewModel.output.categoryFilter
                .receive(on: DispatchQueue.main)
                .withUnretained(headerView)
                .sink { headerView, category in
                    headerView.bind(category: category)
                }
                .store(in: &headerView.cancellables)
            
            viewModel.output.isOnlyCertified
                .receive(on: DispatchQueue.main)
                .withUnretained(headerView)
                .sink { headerView, isOnlyCertified in
                    headerView.isOnlyCertifiedButton.isSelected = isOnlyCertified
                }
                .store(in: &headerView.cancellables)
            return headerView
        }
    }
}

extension HomeListDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplay.send(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.onTapStore.send(indexPath.row)
    }
}
