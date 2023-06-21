import Foundation
import Combine

import Networking

final class CategorySelectionViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let onLoadDataSource = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<Int, Never>()
        let deSelectCategory = PassthroughSubject<Int, Never>()
        let tapSelect = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let categories = PassthroughSubject<[PlatformStoreCategory], Never>()
        let selectCategories = PassthroughSubject<[PlatformStoreCategory], Never>()
        let isEnableSelectButton = PassthroughSubject<Bool, Never>()
        let error = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case dismissWithCategories([PlatformStoreCategory])
    }
    
    struct State {
        var categories: [PlatformStoreCategory] = []
        var selectedCategories: [PlatformStoreCategory] = []
    }
    
    let input = Input()
    let output = Output()
    private var state: State
    private var cancellables = Set<AnyCancellable>()
    private let analyticsManager: AnalyticsManagerProtocol
    private let metadataManager: MetadataManager
    
    init(
        state: State,
        analyticsManager: AnalyticsManagerProtocol = AnalyticsManager.shared,
        metadataManager: MetadataManager = .shared
    ) {
        self.state = state
        self.analyticsManager = analyticsManager
        self.metadataManager = metadataManager
        
        bind()
    }
    
    private func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.sendPageViewLog()
            })
            .withUnretained(self)
            .sink { owner, _ in
                let categories = owner.metadataManager.categories
                owner.state.categories = categories
                owner.output.categories.send(categories)
                owner.output.selectCategories.send(owner.state.selectedCategories)
            }
            .store(in: &cancellables)
        
        input.onLoadDataSource
            .withUnretained(self)
            .map { owner, _ in
                owner.state.selectedCategories
            }
            .subscribe(output.selectCategories)
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
