import Foundation
import Combine

import Common
import Model
import Networking

extension WriteDetailCategoryBottomSheetViewModel {
    enum Constants {
        static let maximumSelectedCategoryCount = 10
    }
    
    struct Input {
        let selectCategory = PassthroughSubject<StoreFoodCategoryResponse, Never>()
        let didTapEdit = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let datasource: CurrentValueSubject<[WriteDetailCategorySection], Never>
        let selectedCategoryCount: CurrentValueSubject<Int, Never>
        let setErrorCountState = CurrentValueSubject<Bool, Never>(false)
        let finishEditCategory = PassthroughSubject<[StoreFoodCategoryResponse], Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case toast(String)
        case showErrorAlert(Error)
        case dismiss
    }
    
    struct Config {
        let categories: [StoreFoodCategoryResponse]
        let selectedCategories: [StoreFoodCategoryResponse]
        
        init(
            categories: [StoreFoodCategoryResponse],
            selectedCategories: [StoreFoodCategoryResponse]
        ) {
            self.categories = categories
            self.selectedCategories = selectedCategories
        }
    }
    
    private struct State {
        var categories: [StoreFoodCategoryResponse]
        var selectedCategories: [StoreFoodCategoryResponse]
    }
}

final class WriteDetailCategoryBottomSheetViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state: State
    
    init(config: Config) {
        let datasource = Self.updateDatasource(
            categories: config.categories,
            selectedCategories: config.selectedCategories
        )
        self.output = Output(
            datasource: .init(datasource),
            selectedCategoryCount: .init(config.selectedCategories.count))
        self.state = State(
            categories: config.categories,
            selectedCategories: config.selectedCategories
        )
        
        super.init()
    }
    
    override func bind() {
        input.selectCategory
            .sink { [weak self] category in
                guard let self else { return }
                
                if state.selectedCategories.contains(where: { $0.categoryId == category.categoryId }) {
                    state.selectedCategories.removeAll { $0.categoryId == category.categoryId }
                } else {
                    if state.selectedCategories.count < Constants.maximumSelectedCategoryCount {
                        state.selectedCategories.append(category)
                    }
                }
                
                output.setErrorCountState.send(false)
                output.selectedCategoryCount.send(state.selectedCategories.count)
            }
            .store(in: &cancellables)
        
        input.didTapEdit
            .sink { [weak self] in
                self?.validateAndComplete()
            }
            .store(in: &cancellables)
    }
    
    private static func updateDatasource(
        categories: [StoreFoodCategoryResponse],
        selectedCategories: [StoreFoodCategoryResponse]
    ) -> [WriteDetailCategorySection] {
        let groupedCategories = Dictionary(grouping: categories) { $0.classification }
        let sections = groupedCategories.map { (classification: StoreCategoryClassificationResponse, categories: [StoreFoodCategoryResponse]) in
            return WriteDetailCategorySection(
                classification: classification,
                items: categories.map { category in
                    let isSelected = selectedCategories.contains(where: { $0.categoryId == category.categoryId })
                    return .category(category, isSelected: isSelected)
                }
            )
        }
        
        return sections
    }
    
    private func validateAndComplete() {
        guard state.selectedCategories.isNotEmpty else {
            output.route.send(.toast(Strings.WriteDetailCategoryBottomSheet.Toast.needCategory))
            output.setErrorCountState.send(true)
            return
        }
        
        output.finishEditCategory.send(state.selectedCategories)
        output.route.send(.dismiss)
    }
}
