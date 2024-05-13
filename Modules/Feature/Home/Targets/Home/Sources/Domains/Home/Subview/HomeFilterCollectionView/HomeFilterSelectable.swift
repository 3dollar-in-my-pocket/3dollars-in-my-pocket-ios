import Combine

import Model

protocol HomeFilterSelectable {
    // Input
    var onTapCategoryFilter: PassthroughSubject<Void, Never> { get }
    var onTapOnlyRecentActivity: PassthroughSubject<Void, Never> { get }
    var onToggleSort: PassthroughSubject<StoreSortType, Never> { get }
    var onTapOnlyBoss: PassthroughSubject<Void, Never> { get }
    var selectCategory: PassthroughSubject<PlatformStoreCategory?, Never> { get }
    
    // Output
    var filterDatasource: CurrentValueSubject<[HomeFilterCollectionView.CellType], Never> { get }
}
