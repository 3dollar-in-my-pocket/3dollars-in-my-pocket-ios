import UIKit

import Model

enum SearchAddressSectionType {
    case address
    case recentSearch
    case banner
}

struct SearchAddressSection: Hashable {
    var type: SearchAddressSectionType
    var items: [SearchAddressSectionItem]
    
    init(type: SearchAddressSectionType, items: [SearchAddressSectionItem]) {
        self.type = type
        self.items = items
    }
}

enum SearchAddressSectionItem: Hashable {
    case address(PlaceDocument)
    case recentSearch(RecentSearchAddressCellViewModel)
    case banner
}

final class SearchAddressDatasource: UICollectionViewDiffableDataSource<SearchAddressSection, SearchAddressSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<SearchAddressSection,SearchAddressSectionItem>
    
    let viewModel: SearchAddressViewModel
    
    init(collectionView: UICollectionView, viewModel: SearchAddressViewModel, containerVC: UIViewController) {
        self.viewModel = viewModel
        
        super.init(collectionView: collectionView) { [weak containerVC] collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .address(let document):
                let cell: AddressCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(document: document)
                return cell
            case .recentSearch(let viewModel):
                let cell: RecentSearchAddressCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel)
                return cell
            case .banner:
                let cell: SearchAddressBannerCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(in: containerVC)
                return cell
            }
        }
        
        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            switch self?.sectionIdentifier(section: indexPath.section)?.type {
            case .recentSearch:
                let headerView: SearchAddressHeaderCell = collectionView.dequeueReusableSupplementaryView(ofkind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
                headerView.bind(title: "최근 검색 위치")
                return headerView
            default:
                return nil
            }
        }

        collectionView.register([
            AddressCell.self,
            RecentSearchAddressCell.self,
            SearchAddressBannerCell.self
        ])
        collectionView.registerSectionHeader([
            SearchAddressHeaderCell.self,
        ])
        collectionView.delegate = self
    }
    
    func reload(_ sections: [SearchAddressSection]) {
        var snapshot = Snapshot()
        
        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: true)
    }
}

extension SearchAddressDatasource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch itemIdentifier(for: indexPath) {
        case .address:
            viewModel.input.didTapAddress.send(indexPath.item)
        case .recentSearch:
            viewModel.input.didTapRecentSearchAddress.send(indexPath.item)
        case .banner:
            break
        case .none:
            break
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewModel.input.didScroll.send(())
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch sectionIdentifier(section: indexPath.section)?.type {
        case .recentSearch:
            viewModel.input.willDisplayRecentSearchCell.send(indexPath.item)
        default:
            break
        }
    }
}

extension SearchAddressDatasource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch itemIdentifier(for: indexPath) {
        case .address, .recentSearch:
            AddressCell.Layout.size
        case .banner:
            SearchAddressBannerCell.Layout.size
        case .none:
            .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch sectionIdentifier(section: section)?.type {
        case .recentSearch:
            SearchAddressHeaderCell.Layout.size
        default:
            .zero
        }
    }
}
