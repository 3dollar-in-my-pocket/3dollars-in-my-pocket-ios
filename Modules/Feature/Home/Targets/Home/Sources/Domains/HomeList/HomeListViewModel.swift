import Foundation
import UIKit
import Combine
import CoreLocation

import Networking
import Common
import Model
import Log
import AppInterface

extension HomeListViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let willDisplay = PassthroughSubject<Int, Never>()
        let onTapCategoryFilter = PassthroughSubject<Void, Never>()
        let onTapOnlyRecentActivity = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<StoreFoodCategoryResponse?, Never>()
        let onToggleSort = PassthroughSubject<StoreSortType, Never>()
        let onTapOnlyBoss = PassthroughSubject<Void, Never>()
        let onToggleCertifiedStore = PassthroughSubject<Void, Never>()
        let onTapStore = PassthroughSubject<StoreWithExtraResponse, Never>()
        let onTapAdvertisement = PassthroughSubject<AdvertisementResponse, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .homeList
        let dataSource = CurrentValueSubject<[HomeListSection], Never>([])
        let filterDatasource: CurrentValueSubject<[HomeFilterCollectionView.CellType], Never>
        let isOnlyCertified = CurrentValueSubject<Bool, Never>(false)
        let route = PassthroughSubject<Route, Never>()
        
        // To HomeViewModel
        let onSelectCategoryFilter = PassthroughSubject<StoreFoodCategoryResponse?, Never>()
        let onToggleSort = PassthroughSubject<StoreSortType, Never>()
        let onTapOnlyBoss = PassthroughSubject<Void, Never>()
        let onTapOnlyRecentActivity = PassthroughSubject<Void, Never>()
    }
    
    struct State {
        var stores: [StoreWithExtraResponse] = []
        var categoryFilter: StoreFoodCategoryResponse?
        var isOnlyRecentActivity: Bool
        var sortType: StoreSortType
        var isOnlyBossStore: Bool
        var isOnlyCertifiedStore = false
        var mapLocation: CLLocation?
        var nextCursor: String?
        var hasMore: Bool
        let mapMaxDistance: Double?
        var advertisement: AdvertisementResponse?
    }
    
    struct Config {
        let categoryFilter: StoreFoodCategoryResponse?
        let isOnlyRecentActivity: Bool
        let sortType: StoreSortType
        let isOnlyBossStore: Bool
        let mapLocation: CLLocation?
        let mapMaxDistance: Double?
    }
    
    enum Route {
        case pushStoreDetail(storeId: String)
        case pushBossStoreDetail(storeId: String)
        case showErrorAlert(Error)
        case presentCategoryFilter(CategoryFilterViewModel)
        case openUrl(String?)
    }
    
    struct Dependency {
        let storeRepository: StoreRepository
        let advertisementRepository: AdvertisementRepository
        let logManager: LogManagerProtocol
        let deepLinkHandler: DeepLinkHandlerProtocol
        
        init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            advertisementRepository: AdvertisementRepository =  AdvertisementRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared,
            deepLinkHandler: DeepLinkHandlerProtocol = Environment.appModuleInterface.deepLinkHandler
        ) {
            self.storeRepository = storeRepository
            self.advertisementRepository = advertisementRepository
            self.logManager = logManager
            self.deepLinkHandler = deepLinkHandler
        }
    }
}


final class HomeListViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state: State
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(
            filterDatasource: .init([
                .category(config.categoryFilter),
                .recentActivity(config.isOnlyRecentActivity),
                .sortingFilter(config.sortType),
                .onlyBoss(config.isOnlyBossStore)
            ])
        )
        self.state = State(
            isOnlyRecentActivity: config.isOnlyRecentActivity,
            sortType: config.sortType,
            isOnlyBossStore: config.isOnlyBossStore,
            hasMore: true,
            mapMaxDistance: config.mapMaxDistance
        )
        self.dependency = dependency
        super.init()
        
        bindRelay()
    }
    
    override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: HomeListViewModel, _) in
                owner.fetchDatas()
            }
            .store(in: &cancellables)
        
        input.willDisplay
            .removeDuplicates()
            .withUnretained(self)
            .filter { owner, index in
                owner.canLoad(index: index)
            }
            .sink(receiveValue: { (owner: HomeListViewModel, _) in
                owner.fetchAroundStore()
            })
            .store(in: &cancellables)
        
        input.onTapCategoryFilter
            .withUnretained(self)
            .sink { owner, _ in
                owner.sendClickCategoryFilterLog()
                owner.presentCategoryFilter()
            }
            .store(in: &cancellables)
        
        input.selectCategory
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, category: StoreFoodCategoryResponse?) in
                owner.clearData()
                owner.state.categoryFilter = category
                owner.updateFilterDatasource()
                owner.fetchAroundStore()
            })
            .store(in: &cancellables)
        
        input.onTapOnlyRecentActivity
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, _) in
                owner.state.isOnlyRecentActivity.toggle()
                owner.clearData()
                owner.sendClickRecentActivityFilter(value: owner.state.isOnlyRecentActivity)
                owner.fetchAroundStore()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)
        
        input.onToggleCertifiedStore
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, _) in
                owner.clearData()
                owner.state.isOnlyCertifiedStore.toggle()
                owner.sendClickOnlyVisitFilterLog(owner.state.isOnlyCertifiedStore)
                owner.output.isOnlyCertified.send(owner.state.isOnlyCertifiedStore)
                owner.fetchAroundStore()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)
        
        input.onToggleSort
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, sortType: StoreSortType) in
                owner.clearData()
                owner.state.sortType = owner.state.sortType.toggled()
                owner.sendClickSortingLog(owner.state.sortType)
                owner.fetchAroundStore()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)
        
        input.onTapOnlyBoss
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, _) in
                owner.clearData()
                owner.state.isOnlyBossStore.toggle()
                owner.sendClickOnlyBossFilterLog(owner.state.isOnlyBossStore)
                owner.fetchAroundStore()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)
        
        input.onTapStore
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, storeWithExtra: StoreWithExtraResponse) in
                owner.sendClickStore(storeWithExtra.store)
                
                switch storeWithExtra.store.storeType {
                case .bossStore:
                    owner.output.route.send(.pushBossStoreDetail(storeId: storeWithExtra.store.storeId))
                case .userStore:
                    owner.output.route.send(.pushStoreDetail(storeId: storeWithExtra.store.storeId))
                case .unknown:
                    break
                }
            })
            .store(in: &cancellables)
        
        input.onTapAdvertisement
            .withUnretained(self)
            .sink { owner, advertisement in
                owner.sendClickAdBannerLog(advertisement)
                guard let link = advertisement.link else { return }
                owner.dependency.deepLinkHandler.handleAdvertisementLink(link)
            }
            .store(in: &cancellables)
    }
    
    private func bindRelay() {
        input.onToggleSort
            .subscribe(output.onToggleSort)
            .store(in: &cancellables)
        
        input.onTapOnlyBoss
            .subscribe(output.onTapOnlyBoss)
            .store(in: &cancellables)
        
        input.selectCategory
            .subscribe(output.onSelectCategoryFilter)
            .store(in: &cancellables)
        
        input.onTapOnlyRecentActivity
            .subscribe(output.onTapOnlyRecentActivity)
            .store(in: &cancellables)
    }
    
    private func updateFilterDatasource() {
        let datasource: [HomeFilterCollectionView.CellType] = [
            .category(state.categoryFilter),
            .recentActivity(state.isOnlyRecentActivity),
            .sortingFilter(state.sortType),
            .onlyBoss(state.isOnlyBossStore)
        ]
        
        output.filterDatasource.send(datasource)
    }
    
    private func canLoad(index: Int) -> Bool {
        var contentsCount = state.stores.count
        if state.advertisement.isNotNil {
            contentsCount += 1
        }
        return index >= contentsCount - 1 && state.nextCursor != nil && state.hasMore
    }
    
    private func fetchAroundStore() {
        Task {
            let input = createFetchAroundStoreInput()
            let result = await dependency.storeRepository.fetchAroundStores(input: input)
            
            switch result {
            case .success(let response):
                state.hasMore = response.cursor.hasMore
                state.nextCursor = response.cursor.nextCursor
                state.stores.append(contentsOf: response.contents)
                updateDataSource()
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func createFetchAroundStoreInput() -> FetchAroundStoreInput {
        var categoryIds: [String]? = nil
        if let filterCategory = state.categoryFilter {
            categoryIds = [filterCategory.categoryId]
        }
        let targetStores: [StoreType] = state.isOnlyBossStore ? [.bossStore] : [.userStore, .bossStore]
        let filterConditions: [ActivitiesStatus] = state.isOnlyRecentActivity ? [.recentActivity] : [.recentActivity, .noRecentActivity]
        
        return FetchAroundStoreInput(
            distanceM: state.mapMaxDistance ?? 0,
            categoryIds: categoryIds,
            targetStores: targetStores,
            sortType: state.sortType,
            filterCertifiedStores: state.isOnlyCertifiedStore,
            filterConditions: filterConditions,
            size: 10,
            cursor: state.nextCursor,
            mapLatitude: state.mapLocation?.coordinate.latitude ?? 0,
            mapLongitude: state.mapLocation?.coordinate.longitude ?? 0
        )
    }
    
    private func fetchDatas() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let advertisementInput = FetchAdvertisementInput(position: .storeList, size: nil)
                let advertisements = try await dependency.advertisementRepository.fetchAdvertisements(input: advertisementInput).get()
                
                if let advertisement = advertisements.advertisements.first {
                    state.advertisement = advertisement
                }
                
                let input = createFetchAroundStoreInput()
                let response = try await dependency.storeRepository.fetchAroundStores(input: input).get()
                
                state.hasMore = response.cursor.hasMore
                state.nextCursor = response.cursor.nextCursor
                state.stores.append(contentsOf: response.contents)
                updateDataSource()
            } catch {
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func updateDataSource() {
        var sectionItems = state.stores.map { HomeListSectionItem.store($0) }
        
        if sectionItems.isEmpty {
            sectionItems.append(.emptyStore)
        }
        
        if let advertisement = state.advertisement {
            let index = min(1, sectionItems.count) // 두번째 구좌에 노출
            let config = HomeListAdCellViewModel.Config(ad: advertisement)
            let viewModel = HomeListAdCellViewModel(config: config)
            
            sectionItems.insert(.ad(viewModel), at: index)
        }
        
        output.dataSource.send([HomeListSection(items: sectionItems)])
    }
    
    private func presentCategoryFilter() {
        let config = CategoryFilterViewModel.Config(currentCategory: state.categoryFilter)
        let viewModel = CategoryFilterViewModel(config: config)
        
        viewModel.output.didSelectCategory
            .subscribe(input.selectCategory)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.presentCategoryFilter(viewModel))
    }
    
    private func clearData() {
        state.nextCursor = nil
        state.hasMore = false
        state.stores = []
    }
}

// MARK: Log
extension HomeListViewModel {
    private func sendClickStore(_ store: StoreResponse) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickStore,
            extraParameters: [
                .storeId: store.storeId,
                .type: store.storeType.rawValue
            ]
        ))
    }
    
    private func sendClickCategoryFilterLog() {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickCategoryFilter
        ))
    }
    
    private func sendClickSortingLog(_ sortType: StoreSortType) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickSorting,
            extraParameters: [.type: sortType.rawValue]
        ))
    }
    
    private func sendClickAdBannerLog(_ advertisement: AdvertisementResponse) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickAdBanner,
            extraParameters: [.advertisementId: "\(advertisement.advertisementId)"]
        ))
    }
    
    private func sendClickOnlyBossFilterLog(_ isOn: Bool) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickBossFilter,
            extraParameters: [.value: isOn]
        ))
    }
    
    private func sendClickOnlyVisitFilterLog(_ isOn: Bool) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickOnlyVisit,
            extraParameters: [.value: isOn]
        ))
    }
    
    private func sendClickRecentActivityFilter(value: Bool) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickRecentActivityFilter,
            extraParameters: [.value: value]
        ))
    }
}

extension HomeListViewModel: HomeFilterSelectable {
    var onTapCategoryFilter: PassthroughSubject<Void, Never> {
        return input.onTapCategoryFilter
    }
    
    var onTapOnlyRecentActivity: PassthroughSubject<Void, Never> {
        return input.onTapOnlyRecentActivity
    }
    
    var onToggleSort: PassthroughSubject<Model.StoreSortType, Never> {
        return input.onToggleSort
    }
    
    var onTapOnlyBoss: PassthroughSubject<Void, Never> {
        return input.onTapOnlyBoss
    }
    
    var selectCategory: PassthroughSubject<StoreFoodCategoryResponse?, Never> {
        return input.selectCategory
    }
    
    var filterDatasource: CurrentValueSubject<[HomeFilterCollectionView.CellType], Never> {
        return output.filterDatasource
    }
}
