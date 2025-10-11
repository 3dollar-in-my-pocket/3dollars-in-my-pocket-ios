import UIKit
import Model

final class WriteDetailCategoryDatasource: UICollectionViewDiffableDataSource<WriteDetailCategorySection, WriteDetailCategorySectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<WriteDetailCategorySection, WriteDetailCategorySectionItem>
    
    private let viewModel: WriteDetailCategoryViewModel
    
    init(collectionView: UICollectionView, viewModel: WriteDetailCategoryViewModel) {
        self.viewModel = viewModel
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .category(let category, _):
                let cell: WriteDetailCategoryCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(category: category)
                return cell
            }
        }
        
        supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let section = self.snapshot().sectionIdentifiers[safe: indexPath.section] else { return nil }
            
            if kind == UICollectionView.elementKindSectionHeader {
                let headerView: WriteDetailCategorySectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofkind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
                
                headerView.setClassification(section.classification)
                return headerView
            }
            return nil
        }
        collectionView.delegate = self
        collectionView.register([WriteDetailCategoryCell.self])
        collectionView.registerSectionHeader([WriteDetailCategorySectionHeaderView.self])
    }
    
    func reload(_ sections: [WriteDetailCategorySection]) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        for section in sections {
            snapshot.appendItems(section.items, toSection: section)
        }
        apply(snapshot, animatingDifferences: false)
    }
}

extension WriteDetailCategoryDatasource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = self[indexPath] else { return .zero }
        switch item {
        case .category(let category, _):
            return WriteDetailCategoryCell.Layout.calculateSize(category: category)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return WriteDetailCategorySectionHeaderView.Layout.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = itemIdentifier(for: indexPath) else { return }
        switch item {
        case .category(let category, _):
            viewModel.input.selectCategory.send(category)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let item = itemIdentifier(for: indexPath) else { return }
        switch item {
        case .category(let category, _):
            viewModel.input.selectCategory.send(category)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return viewModel.output.selectedCategoryCount.value < WriteDetailCategoryViewModel.Constants.maximumSelectedCategoryCount
    }
}

struct WriteDetailCategorySection: Hashable {
    let classification: StoreCategoryClassificationResponse
    let items: [WriteDetailCategorySectionItem]
}

enum WriteDetailCategorySectionItem: Hashable {
    case category(StoreFoodCategoryResponse, isSelected: Bool)
    
    var isSelected: Bool {
        switch self {
        case .category(_, let isSelected):
            return isSelected
        }
    }
}
