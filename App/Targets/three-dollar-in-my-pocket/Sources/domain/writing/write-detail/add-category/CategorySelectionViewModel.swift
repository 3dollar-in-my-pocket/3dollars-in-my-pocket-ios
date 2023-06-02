import Foundation
import Combine

import Networking

final class CategorySelectionViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<Int, Never>()
        let deSelectCategory = PassthroughSubject<Int, Never>()
        let tapSelect = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let categories = PassthroughSubject<[PlatformStoreCategory], Never>()
        let isEnableSelectButton = PassthroughSubject<Bool, Never>()
        let error = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case dismissWithCategories([PlatformStoreCategory])
    }
    
    private struct State {
        var categories: [PlatformStoreCategory] = []
        var selectedCategories: [PlatformStoreCategory] = []
    }
    
    let input = Input()
    let output = Output()
    private var state = State()
    private var cancellables = Set<AnyCancellable>()
    private let categoryService: Networking.CategoryServiceProtocol
    private let analyticsManager: AnalyticsManagerProtocol
    
    init(
        categoryService: Networking.CategoryServiceProtocol = Networking.CategoryService(),
        analyticsManager: AnalyticsManagerProtocol = AnalyticsManager.shared
    ) {
        self.categoryService = categoryService
        self.analyticsManager = analyticsManager
        
        bind()
    }
    
    private func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.sendPageViewLog()
            })
            .asyncMap { owner, _ in
                await owner.categoryService.fetchCategoires()
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let categoryResponse):
                    let categories = categoryResponse.map(PlatformStoreCategory.init(response:))
                    
                    owner.state.categories = categories
                    owner.output.categories.send(categories)
                    
                case .failure(let error):
                    owner.output.error.send(error)
                }
            }
            .store(in: &cancellables)
        
        input.selectCategory
            .withUnretained(self)
            .sink { owner, index in
                guard let selectedCategory = owner.state.categories[safe: index] else { return }
                
                owner.state.selectedCategories.append(selectedCategory)
                owner.output.isEnableSelectButton.send(owner.state.selectedCategories.isNotEmpty)
            }
            .store(in: &cancellables)
        
        input.deSelectCategory
            .withUnretained(self)
            .sink { owner, index in
                guard let selectedCategory = owner.state.categories[safe: index],
                      let targetIndex = owner.state.selectedCategories.firstIndex(of: selectedCategory)
                else { return }
                
                owner.state.selectedCategories.remove(at: targetIndex)
                owner.output.isEnableSelectButton.send(owner.state.selectedCategories.isNotEmpty)
            }
            .store(in: &cancellables)
        
        input.tapSelect
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                let selectedCategoryIds = owner.state.selectedCategories.map { $0.id }
                
                owner.sendClickCategoryLog(categoryIds: selectedCategoryIds)
            })
            .map { owner, _ in
                Route.dismissWithCategories(owner.state.selectedCategories)
            }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
    
    private func sendPageViewLog() {
        analyticsManager.logPageView(screen: .categorySelection, type: CategorySelectionViewController.self)
    }
    
    private func sendClickCategoryLog(categoryIds: [String]) {
        analyticsManager.logEvent(event: .clickSelectCategory(categoryIds: categoryIds), screen: .categorySelection)
    }
}
