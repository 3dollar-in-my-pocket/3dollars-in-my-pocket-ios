import Foundation
import Combine

import Common
import Networking
import Model
import Log

final class CategorySelectionViewModel: BaseViewModel {
    struct Input {
        let onLoadDataSource = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<String, Never>()
        let deSelectCategory = PassthroughSubject<String, Never>()
        let tapSelect = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .categorySelection
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
    private let logManager: LogManagerProtocol
    
    init(config: Config, logManager: LogManagerProtocol = LogManager.shared) {
        self.output = Output(categories: .init(config.categories))
        self.state = State(categories: config.categories, selectedCategories: config.selectedCategories)
        self.logManager = logManager
        
        super.init()
    }
    
    override func bind() {
        input.onLoadDataSource
            .withUnretained(self)
            .map { owner, _ in
                owner.state.selectedCategories
            }
            .subscribe(output.selectCategories)
            .store(in: &cancellables)
        
        input.selectCategory
            .withUnretained(self)
            .sink { owner, categoryId in
                guard let selectedCategory = owner.state.categories.first(where: { $0.categoryId == categoryId }) else { return }
                
                owner.state.selectedCategories.append(selectedCategory)
                owner.output.isEnableSelectButton.send(owner.state.selectedCategories.isNotEmpty)
            }
            .store(in: &cancellables)
        
        input.deSelectCategory
            .withUnretained(self)
            .sink { owner, categoryId in
                guard let selectedCategory = owner.state.categories.first(where: { $0.categoryId == categoryId }),
                      let targetIndex = owner.state.selectedCategories.firstIndex(of: selectedCategory)
                else { return }
                
                owner.state.selectedCategories.remove(at: targetIndex)
                owner.output.isEnableSelectButton.send(owner.state.selectedCategories.isNotEmpty)
            }
            .store(in: &cancellables)
        
        input.tapSelect
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.sendClickCategoryLog(categories: owner.state.selectedCategories)
            })
            .sink(receiveValue: { (owner: CategorySelectionViewModel, _) in
                owner.output.onSelectCategories.send(owner.state.selectedCategories)
                owner.output.route.send(.dismiss)
            })
            .store(in: &cancellables)
    }
    
    private func sendClickCategoryLog(categories: [PlatformStoreCategory]) {
        let categoryNames = categories.map { $0.name }.joined(separator: ",")
        logManager.sendEvent(LogEvent(
            screen: output.screenName,
            eventName: .clickCategory,
            extraParameters: [.categoryName: categoryNames]
        ))
    }
}
