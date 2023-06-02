import Foundation
import Combine

import Networking
import Common

final class CategorySelectionViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<Int, Never>()
        let deSelectCategory = PassthroughSubject<Int, Never>()
        let tapSelect = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let categories = PassthroughSubject<[Networking.PlatformStoreCategoryResponse], Never>()
        let error = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case dismissWithCategories([Networking.PlatformStoreCategoryResponse])
    }
    
    private struct State {
        var categories: [Networking.PlatformStoreCategoryResponse] = []
        var selectedCategories: [Networking.PlatformStoreCategoryResponse] = []
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
                // 페이지 뷰
            })
            .asyncMap { owner, _ in
                await owner.categoryService.fetchCategoires()
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let categories):
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
            }
            .store(in: &cancellables)
        
        input.deSelectCategory
            .withUnretained(self)
            .sink { owner, index in
                guard let selectedCategory = owner.state.categories[safe: index],
                      let targetIndex = owner.state.selectedCategories.firstIndex(where: { $0.categoryId == selectedCategory.categoryId })
                else { return }
                
                owner.state.selectedCategories.remove(at: targetIndex)
            }
            .store(in: &cancellables)
        
        input.tapSelect
            .withUnretained(self)
            .map { owner, _ in
                Route.dismissWithCategories(owner.state.selectedCategories)
            }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
}
