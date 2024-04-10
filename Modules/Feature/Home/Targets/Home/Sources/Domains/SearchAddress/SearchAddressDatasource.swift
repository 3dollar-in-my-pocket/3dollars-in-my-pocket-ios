import UIKit

import Model

enum SearchAddressSectionType {
    case address
    case recentSearch
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
}

final class SearchAddressDatasource: UICollectionViewDiffableDataSource<SearchAddressSection, SearchAddressSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<SearchAddressSection,SearchAddressSectionItem>
    
    let viewModel: SearchAddressViewModel
    
    init(collectionView: UICollectionView, viewModel: SearchAddressViewModel) {
        self.viewModel = viewModel
        
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .address(let document):
                let cell: AddressCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                cell.bind(document: document)
                return cell
            }
        }
        
        collectionView.register([
            AddressCell.self
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
        viewModel.input.didTapAddress.send(indexPath.item)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewModel.input.didScroll.send(())
    }
}
