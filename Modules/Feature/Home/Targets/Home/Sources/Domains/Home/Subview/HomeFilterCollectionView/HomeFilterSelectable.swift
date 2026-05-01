import Combine

import Model

protocol HomeFilterSelectable {
    // Input
    var onTapCategoryFilter: PassthroughSubject<Void, Never> { get }
    var onTapRadioOption: PassthroughSubject<(paramKey: String, optionIndex: Int), Never> { get }
    var onTapActionLink: PassthroughSubject<SDLink, Never> { get }
    var onTapCloseSelectedCategory: PassthroughSubject<Void, Never> { get }
    var selectCategory: PassthroughSubject<StoreFoodCategoryResponse?, Never> { get }

    // Output
    var filterDatasource: CurrentValueSubject<[HomeFilterCollectionView.CellType], Never> { get }
}
