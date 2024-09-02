import UIKit

import Model

struct HomeListSection: Hashable {
    public var items: [HomeListSectionItem]
    
    public init(items: [HomeListSectionItem]) {
        self.items = items
    }
}
        
enum HomeListSectionItem: Hashable {
    case store(StoreWithExtraResponse)
    case ad(HomeListAdCellViewModel)
    case emptyStore
}

typealias HomeListSnapshot = NSDiffableDataSourceSnapshot<HomeListSection, HomeListSectionItem>

final class HomeListDataSource: UICollectionViewDiffableDataSource<HomeListSection, HomeListSectionItem> {
    let viewModel: HomeListViewModel
    
    init(collectionView: UICollectionView, viewModel: HomeListViewModel) {
        self.viewModel = viewModel
        
        collectionView.register([
            HomeListCell.self,
            HomeListAdCell.self,
            HomeListEmptyCell.self
        ])
        collectionView.registerSectionHeader([HomeListHeaderCell.self])
        
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .store(let storeWithExtra):
                let cell: HomeListCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(storeWithExtra)
                return cell
            case .ad(let viewModel):
                let cell: HomeListAdCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(viewModel: viewModel)
                return cell
            case .emptyStore:
                let cell: HomeListEmptyCell = collectionView.dequeueReusableCell(indexPath: indexPath)
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
            
            viewModel.output.isOnlyCertified
                .receive(on: DispatchQueue.main)
                .withUnretained(headerView)
                .sink { headerView, isOnlyCertified in
                    headerView.isOnlyCertifiedButton.isSelected = isOnlyCertified
                }
                .store(in: &headerView.cancellables)
            
            viewModel.output.filterDatasource
                .receive(on: DispatchQueue.main)
                .withUnretained(headerView)
                .sink { (headerView: HomeListHeaderCell, cellTypeList: [HomeFilterCollectionView.CellType]) in
                    for cellType in cellTypeList {
                        switch cellType {
                        case .category(let category):
                            headerView.bind(category: category)
                        case .recentActivity:
                            continue
                        case .sortingFilter:
                            continue
                        case .onlyBoss(let isOnlyBoss):
                            headerView.isOnlyCertifiedButton.isHidden = isOnlyBoss
                        }
                    }
                }
                .store(in: &headerView.cancellables)
            return headerView
        }
    }
    
    func reload(_ sections: [HomeListSection]) {
        var snapshot = HomeListSnapshot()
        
        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }
        
        apply(snapshot, animatingDifferences: true)
    }
}

extension HomeListDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch itemIdentifier(for: indexPath) {
        case .store(_):
            viewModel.input.willDisplay.send(indexPath.row)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch itemIdentifier(for: indexPath) {
        case .store(let storeWithExtra):
            viewModel.input.onTapStore.send(storeWithExtra)
        case .ad(let adCellViewModel):
            viewModel.input.onTapAdvertisement.send(adCellViewModel.output.item)
        default:
            break
        }
    }
}

extension HomeListDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch itemIdentifier(for: indexPath) {
        case .store:
            return HomeListCell.Layout.size
        case .ad:
            return HomeListAdCell.Layout.size
        case .emptyStore:
            return HomeListEmptyCell.Layout.size
        case .none:
            return .zero
        }
    }
}
