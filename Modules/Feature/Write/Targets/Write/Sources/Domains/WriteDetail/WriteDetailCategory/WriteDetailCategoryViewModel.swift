import Foundation
import Combine

import Common
import Model
import Networking

extension WriteDetailCategoryViewModel {
    enum Constants {
        static let maximumSelectedCategoryCount = 10
    }
    
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<StoreFoodCategoryResponse, Never>()
        let didTapNext = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let datasource = CurrentValueSubject<[WriteDetailCategorySection], Never>([])
        let selectedCategoryCount = CurrentValueSubject<Int, Never>(0)
        let setErrorCountState = CurrentValueSubject<Bool, Never>(false)
        let finishSelectCategory = PassthroughSubject<[StoreFoodCategoryResponse], Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case toast(String)
        case showErrorAlert(Error)
    }
    
    private struct State {
        var categories: [StoreFoodCategoryResponse] = []
        var selectedCategories: [StoreFoodCategoryResponse] = []
    }
    
    struct Dependency {
        let categoryRepository: CategoryRepository
        
        init(categoryRepository: CategoryRepository = CategoryRepositoryImpl()) {
            self.categoryRepository = categoryRepository
        }
    }
}


final class WriteDetailCategoryViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private let dependency: Dependency
    private var state = State()
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        super.init()
    }
    
    override func bind() {
        input.viewDidLoad
            .sink { [weak self] in
                self?.fetchCategories()
            }
            .store(in: &cancellables)
        
        input.selectCategory
            .sink { [weak self] category in
                guard let self else { return }
                toggleCategorySelection(category)
                output.setErrorCountState.send(false)
                output.selectedCategoryCount.send(state.selectedCategories.count)
            }
            .store(in: &cancellables)
        
        input.didTapNext
            .sink { [weak self] in
                self?.validateCategory()
            }
            .store(in: &cancellables)
    }
    
    private func fetchCategories() {
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let response = try await self.dependency.categoryRepository.fetchCategories().get()
                state.categories = response
                updateDatasource()
            } catch {
                output.route.send(.showErrorAlert(error))
            }
        }.store(in: taskBag)
    }
    
    private func updateDatasource() {
        let groupedCategories = Dictionary(grouping: state.categories) { $0.classification }
        let sections = groupedCategories.map { (classification: StoreCategoryClassificationResponse, value: [StoreFoodCategoryResponse]) in
            return WriteDetailCategorySection(
                classification: classification,
                items: value.map { .category($0, isSelected: false) }
            )
        }
        
        output.datasource.send(sections)
    }
    
    private func toggleCategorySelection(_ category: StoreFoodCategoryResponse) {
        if state.selectedCategories.contains([category]) {
            state.selectedCategories.removeAll(where: { $0 == category })
        } else {
            state.selectedCategories.append(category)
        }
    }
    
    private func validateCategory() {
        guard state.selectedCategories.isNotEmpty else {
            output.route.send(.toast("1개 이상의 음식 카테고리를 선택해주세요"))
            output.setErrorCountState.send(true)
            return
        }
        
        output.finishSelectCategory.send(state.selectedCategories)
    }
}
