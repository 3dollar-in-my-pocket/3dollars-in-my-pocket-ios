import Foundation
import Combine

import Common
import Networking
import Model
import AppInterface
import DependencyInjection

final class CategorySelectionViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let onLoadDataSource = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<Int, Never>()
        let deSelectCategory = PassthroughSubject<Int, Never>()
        let tapSelect = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let categories: CurrentValueSubject<[PlatformStoreCategory], Never>
        let selectCategories = PassthroughSubject<[PlatformStoreCategory], Never>()
        let isEnableSelectButton = PassthroughSubject<Bool, Never>()
        let error = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
        
        let onSelectCategories = PassthroughSubject<[PlatformStoreCategory], Never>()
    }
    
    enum Route {
        case dismiss
    }
    
    struct State {
        var categories: [PlatformStoreCategory]
        var selectedCategories: [PlatformStoreCategory]
    }
    
    struct Config {
        let categories: [PlatformStoreCategory]
        let selectedCategories: [PlatformStoreCategory]
    }
    
    let input = Input()
    let output: Output
    private var state: State
    private let analyticsManager: AnalyticsManagerProtocol
    
    init(config: Config) {
        self.output = Output(categories: .init(config.categories))
        self.state = State(categories: config.categories, selectedCategories: config.selectedCategories)
        
        guard let appModuleInterface = DIContainer.shared.container.resolve(AppModuleInterface.self) else {
            fatalError("AppModuleInterface가 정의되지 않았습니다.")
        }
        
        self.analyticsManager = appModuleInterface.analyticsManager
        
        super.init()
    }
    
    override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.sendPageViewLog()
            })
            .withUnretained(self)
            .sink { owner, _ in
//                let categories = owner.metadataManager.categories
//                owner.state.categories = categories
//                owner.output.categories.send(categories)
//                owner.output.selectCategories.send(owner.state.selectedCategories)
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
                let selectedCategoryIds = owner.state.selectedCategories.map { $0.categoryId }
                
                owner.sendClickCategoryLog(categoryIds: selectedCategoryIds)
            })
            .sink(receiveValue: { (owner: CategorySelectionViewModel, _) in
                owner.output.onSelectCategories.send(owner.state.selectedCategories)
                owner.output.route.send(.dismiss)
            })
            .store(in: &cancellables)
    }
    
    private func sendPageViewLog() {
        analyticsManager.logPageView(screen: .categorySelection, type: CategorySelectionViewController.self)
    }
    
    private func sendClickCategoryLog(categoryIds: [String]) {
        analyticsManager.logEvent(event: .clickSelectCategory(categoryIds: categoryIds), screen: .categorySelection)
    }
}
