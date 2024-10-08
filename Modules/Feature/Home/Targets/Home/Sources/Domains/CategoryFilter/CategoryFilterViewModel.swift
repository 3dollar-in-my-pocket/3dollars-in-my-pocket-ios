import Foundation
import Combine

import Common
import Networking
import Model
import Log
import AppInterface

extension CategoryFilterViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let onTapBanner = PassthroughSubject<Void, Never>()
        let onTapCategory = PassthroughSubject<String, Never>()
        let onCollectionViewLoaded = PassthroughSubject<Void, Never>()
        let onTapCategoryAdvertisement = PassthroughSubject<AdvertisementResponse, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .categoryFilter
        let dataSource = PassthroughSubject<[CategorySection], Never>()
        let selectCategory = PassthroughSubject<StoreFoodCategoryResponse?, Never>()
        let didSelectCategory = PassthroughSubject<StoreFoodCategoryResponse?, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var currentCategory: StoreFoodCategoryResponse?
        var advertisement: AdvertisementResponse?
        var categoryAdvertisement: AdvertisementResponse?
        var categories: [StoreFoodCategoryResponse] = []
    }
    
    struct Config {
        let currentCategory: StoreFoodCategoryResponse?
    }
    
    enum Route {
        case deepLink(AdvertisementResponse)
        case showErrorAlert(Error)
        case dismiss
    }
    
    struct Dependency {
        let categoryRepository: CategoryRepository
        let advertisementRepository: AdvertisementRepository
        let logManager: LogManagerProtocol
        
        init(
            categoryRepository: CategoryRepository = CategoryRepositoryImpl(),
            advertisementRepository: AdvertisementRepository = AdvertisementRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.categoryRepository = categoryRepository
            self.advertisementRepository = advertisementRepository
            self.logManager = logManager
        }
    }
}

final class CategoryFilterViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state: State
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.state = State(currentCategory: config.currentCategory, advertisement: nil)
        self.dependency = dependency
        
        super.init()
    }
    
    override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink(receiveValue: { (owner: CategoryFilterViewModel, _) in
                owner.fetchData()
            })
            .store(in: &cancellables)
        
        input.onTapBanner
            .withUnretained(self)
            .sink(receiveValue: { (owner: CategoryFilterViewModel, _) in
                owner.handleTapBanner()
            })
            .store(in: &cancellables)
        
        input.onTapCategory
            .withUnretained(self)
            .sink { owner, categoryId in
                owner.handleSelectCategory(categoryId)
            }
            .store(in: &cancellables)
        
        input.onCollectionViewLoaded
            .withUnretained(self)
            .map { owner, _ -> StoreFoodCategoryResponse? in
                return owner.state.currentCategory
            }
            .subscribe(output.selectCategory)
            .store(in: &cancellables)
        
        input.onTapCategoryAdvertisement
            .withUnretained(self)
            .sink { (owner: CategoryFilterViewModel, advertisement: AdvertisementResponse) in
                owner.handleCategoryAdvertisement(advertisement)
            }
            .store(in: &cancellables)
    }
    
    private func fetchData() {
        Task { [weak self] in
            guard let self else { return }
            
            await fetchCategories()
            await fetchCategoryAdvertisement()
            await fetchAdvertisement()
            
            updateDatasource()
        }
    }
    
    private func fetchCategories() async {
        let result = await dependency.categoryRepository.fetchCategories()
        
        switch result {
        case .success(let categories):
            state.categories = categories
        case .failure(let error):
            output.route.send(.showErrorAlert(error))
        }
    }
    
    private func fetchAdvertisement() async {
        let input = FetchAdvertisementInput(position: .menuCategoryBanner)
        let result = await dependency.advertisementRepository.fetchAdvertisements(input: input)
        
        switch result {
        case .success(let response):
            let advertisement = response.advertisements.first
            state.advertisement = advertisement
        case .failure(let error):
            output.route.send(.showErrorAlert(error))
        }
    }
    
    private func fetchCategoryAdvertisement() async {
        let input = FetchAdvertisementInput(position: .menuCategoryIcon)
        let result = await dependency.advertisementRepository.fetchAdvertisements(input: input)
        
        switch result {
        case .success(let response):
            let advertisement = response.advertisements.first
            state.categoryAdvertisement = advertisement
        case .failure(let error):
            output.route.send(.showErrorAlert(error))
        }
    }
    
    private func updateDatasource() {
        var sections: [CategorySection] = []
        let advertisementSectionItem = CategorySectionItem.advertisement(state.advertisement)
        let advertisementSection = CategorySection(title: HomeStrings.categoryFilterTitle, items: [advertisementSectionItem])
        
        sections.append(advertisementSection)
        
        let groupingByCategoryType = Dictionary(grouping: state.categories) { $0.classification }
        
        for categoryType in groupingByCategoryType.keys.sorted(by: <) {
            if let categories = groupingByCategoryType[categoryType] {
                let categorySection = CategorySection(title: categoryType.description, items: categories.map { CategorySectionItem.category($0) })
                
                sections.append(categorySection)
            }
        }
        
        if sections[safe: 1].isNotNil,
           let categoryAdvertisement = state.categoryAdvertisement {
            let exposureIndex = categoryAdvertisement.metadata?.exposureIndex ?? 0
            sections[1].items.insert(.categoryAdvertisement(categoryAdvertisement), at: exposureIndex)
        }
        
        output.dataSource.send(sections)
    }
    
    private func handleTapBanner() {
        guard let advertisement = state.advertisement else { return }
        sendClickBannerLog(advertisement)
        output.route.send(.deepLink(advertisement))
    }
    
    private func handleSelectCategory(_ categoryId: String) {
        guard var selectedCategory = state.categories.first(where: { $0.categoryId == categoryId }) else { return }
        
        if selectedCategory == state.currentCategory {
            output.didSelectCategory.send(nil)
            sendClickCategoryLog(nil)
        } else {
            output.didSelectCategory.send(selectedCategory)
            sendClickCategoryLog(selectedCategory)
        }
        output.route.send(.dismiss)
    }
    
    private func handleCategoryAdvertisement(_ advertisement: AdvertisementResponse) {
        sendClickAdCategoryLog(advertisement)
        output.route.send(.deepLink(advertisement))
    }
    
}

// MARK: Log
extension CategoryFilterViewModel {
    private func sendClickCategoryLog(_ category: StoreFoodCategoryResponse?) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickCategory,
            extraParameters: [.categoryId: category?.categoryId as Any]
        ))
    }
    
    private func sendClickBannerLog(_ advertisement: AdvertisementResponse) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickAdBanner,
            extraParameters: [.advertisementId: advertisement.advertisementId]
        ))
    }
    
    private func sendClickAdCategoryLog(_ advertisement: AdvertisementResponse) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickAdCategory,
            extraParameters: [.advertisementId: advertisement.advertisementId]
        ))
    }
}
