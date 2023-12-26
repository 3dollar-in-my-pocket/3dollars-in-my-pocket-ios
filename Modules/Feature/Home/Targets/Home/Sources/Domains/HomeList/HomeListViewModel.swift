import Foundation
import UIKit
import Combine
import CoreLocation

import Networking
import Common
import Model
import Log

final class HomeListViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let willDisplay = PassthroughSubject<Int, Never>()
        let onTapCategoryFilter = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<PlatformStoreCategory?, Never>()
        let onToggleSort = PassthroughSubject<StoreSortType, Never>()
        let onTapOnlyBoss = PassthroughSubject<Void, Never>()
        let onToggleCertifiedStore = PassthroughSubject<Void, Never>()
        let onTapStore = PassthroughSubject<StoreCard, Never>()
        let onTapAdvertisement = PassthroughSubject<Advertisement, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .homeList
        let categoryFilter: CurrentValueSubject<PlatformStoreCategory?, Never>
        let dataSource = CurrentValueSubject<[HomeListSection], Never>([])
        
        let sortType: CurrentValueSubject<StoreSortType, Never>
        let isOnlyBoss: CurrentValueSubject<Bool, Never>
        let isOnlyCertified = CurrentValueSubject<Bool, Never>(false)
        let route = PassthroughSubject<Route, Never>()
        
        // To HomeViewModel
        let onToggleSort = PassthroughSubject<StoreSortType, Never>()
        let onTapOnlyBoss = PassthroughSubject<Void, Never>()
    }
    
    struct State {
        let stores: CurrentValueSubject<[StoreCard], Never>
        var categoryFilter: PlatformStoreCategory?
        var sortType: StoreSortType = .distanceAsc
        var isOnlyBossStore = false
        var isOnleyCertifiedStore = false
        var mapLocation: CLLocation?
        let currentLocation: CLLocation?
        var nextCursor: String?
        var hasMore: Bool
        let mapMaxDistance: Double?
        var advertisement = CurrentValueSubject<Advertisement?, Never>(nil)
    }
    
    struct Config {
        let initialState: State
    }
    
    enum Route {
        case pushStoreDetail(storeId: String)
        case pushBossStoreDetail(storeId: String)
        case showErrorAlert(Error)
        case presentCategoryFilter(PlatformStoreCategory?)
        case openUrl(String?)
    }
    
    let input = Input()
    let output: Output
    private var state: State
    private let storeService: StoreServiceProtocol
    private let advertisementService: AdvertisementServiceProtocol
    private let logManager: LogManagerProtocol
    
    init(
        config: Config,
        storeService: StoreServiceProtocol = StoreService(),
        advertisementService: AdvertisementServiceProtocol = AdvertisementService(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.output = Output(
            categoryFilter: .init(config.initialState.categoryFilter),
            sortType: .init(config.initialState.sortType),
            isOnlyBoss: .init(config.initialState.isOnlyBossStore)
        )
        self.state = config.initialState
        self.storeService = storeService
        self.advertisementService = advertisementService
        self.logManager = logManager
        super.init()
        
        bindRelay()
    }
    
    override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: HomeListViewModel, _) in
                owner.fetchAdvertisement()
            }
            .store(in: &cancellables)
        
        input.willDisplay
            .withUnretained(self)
            .filter { owner, index in
                owner.canLoad(index: index)
            }
            .asyncMap { owner, _ in
                await owner.fetchAroundStore()
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let storeCards):
                    var stores = owner.state.stores.value
                    stores += storeCards
                    owner.state.stores.send(stores)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
                }
            }
            .store(in: &cancellables)
        
        input.onTapCategoryFilter
            .withUnretained(self)
            .sink { owner, _ in
                let currentCategory = owner.state.categoryFilter
                
                owner.sendClickCategoryFilterLog()
                owner.output.route.send(.presentCategoryFilter(currentCategory))
            }
            .store(in: &cancellables)
        
        input.selectCategory
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, category in
                owner.state.hasMore = true
                owner.state.nextCursor = nil
                owner.state.categoryFilter = category
                owner.output.categoryFilter.send(category)
            })
            .asyncMap { owner, _ in
                await owner.fetchAroundStore()
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let stores):
                    owner.state.stores.send(stores)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
                }
            }
            .store(in: &cancellables)
        
        input.onToggleCertifiedStore
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.state.hasMore = true
                owner.state.nextCursor = nil
                owner.state.isOnleyCertifiedStore.toggle()
                owner.sendClickOnlyVisitFilterLog(owner.state.isOnleyCertifiedStore)
                owner.output.isOnlyCertified.send(owner.state.isOnleyCertifiedStore)
            })
            .asyncMap { owner, _ in
                await owner.fetchAroundStore()
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let stores):
                    owner.state.stores.send(stores)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
                }
            }
            .store(in: &cancellables)
        
        input.onToggleSort
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.state.hasMore = true
                owner.state.nextCursor = nil
                owner.state.sortType = owner.state.sortType.toggled()
                owner.sendClickSortingLog(owner.state.sortType)
            })
            .asyncMap { owner, _ in
                await owner.fetchAroundStore()
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let stores):
                    owner.state.stores.send(stores)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
                }
            }
            .store(in: &cancellables)
        
        input.onTapOnlyBoss
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.state.hasMore = true
                owner.state.nextCursor = nil
                owner.state.isOnlyBossStore.toggle()
                owner.sendClickOnlyBossFilterLog(owner.state.isOnlyBossStore)
            })
            .asyncMap { owner, _ in
                await owner.fetchAroundStore()
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.isOnlyBoss.send(owner.state.isOnlyBossStore)
                
                switch result {
                case .success(let stores):
                    owner.state.stores.send(stores)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
                }
            }
            .store(in: &cancellables)
        
        input.onTapStore
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, store: StoreCard) in
                owner.sendClickStore(store)
                
                switch store.storeType {
                case .bossStore:
                    owner.output.route.send(.pushBossStoreDetail(storeId: store.storeId))
                    
                case .userStore:
                    owner.output.route.send(.pushStoreDetail(storeId: store.storeId))
                }
            })
            .store(in: &cancellables)
        
        state.stores
            .combineLatest(state.advertisement)
            .sink { [weak self] stores, advertisement in
                self?.updateDataSource(storeCards: stores, advertisement: advertisement)
            }
            .store(in: &cancellables)
    
        input.onTapAdvertisement
            .withUnretained(self)
            .sink { owner, advertisement in
                owner.output.route.send(.openUrl(advertisement.linkUrl))
                owner.sendClickAdBannerLog(advertisement)
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
    }
    
    private func canLoad(index: Int) -> Bool {
        return index == state.stores.value.count - 1 && state.nextCursor != nil && state.hasMore
    }
    
    private func fetchAroundStore() async -> Result<[StoreCard], Error> {
        var categoryIds: [String]? = nil
        if let filterCategory = state.categoryFilter {
            categoryIds = [filterCategory.category]
        }
        let targetStores: [StoreType] = state.isOnlyBossStore ? [.bossStore] : [.userStore, .bossStore]
        let input = FetchAroundStoreInput(
            distanceM: state.mapMaxDistance,
            categoryIds: categoryIds,
            targetStores: targetStores.map { $0.rawValue },
            sortType: state.sortType.rawValue,
            filterCertifiedStores: state.isOnleyCertifiedStore,
            size: 10,
            cursor: state.nextCursor,
            mapLatitude: state.mapLocation?.coordinate.latitude ?? 0,
            mapLongitude: state.mapLocation?.coordinate.longitude ?? 0
        )
        
        return await storeService.fetchAroundStores(
            input: input,
            latitude: state.currentLocation?.coordinate.latitude ?? 0,
            longitude: state.currentLocation?.coordinate.longitude ?? 0
        )
        .map{ [weak self] response in
            self?.state.hasMore = response.cursor.hasMore
            self?.state.nextCursor = response.cursor.nextCursor
            return response.contents.map(StoreCard.init(response:))
        }
    }
    
    private func fetchAdvertisement() {
        Task {
            let input = FetchAdvertisementInput(position: .storeList, size: nil)
            let result = await advertisementService.fetchAdvertisements(input: input)
            
            switch result {
            case .success(let response):
                if let advertisementResponse = response.first {
                    let advertisement = Advertisement(response: advertisementResponse)
                    state.advertisement.send(advertisement)
                } else {
                    state.advertisement.send(nil)
                }
            case .failure(_):
                state.advertisement.send(nil)
            }
        }
    }
    
    private func updateDataSource(storeCards: [StoreCard], advertisement: Advertisement?) {
        var sectionItems = storeCards.map { HomeListSectionItem.storeCard($0) }
        
        if storeCards.isEmpty {
            sectionItems.append(.emptyStore)
        }
        
        if let advertisement {
            let index = min(1, sectionItems.count) // 두번째 구좌에 노출
            sectionItems.insert(.ad(HomeListAdCellViewModel(config: .init(ad: advertisement))), at: index)
        }
        
        output.dataSource.send([HomeListSection(items: sectionItems)])
    }
    
    private func sendClickStore(_ storeCard: StoreCard) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickStore,
            extraParameters: [
                .storeId: storeCard.storeId,
                .type: storeCard.storeType.rawValue
            ]
        ))
    }
    
    private func sendClickCategoryFilterLog() {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickCategoryFilter
        ))
    }
    
    private func sendClickSortingLog(_ sortType: StoreSortType) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickSorting,
            extraParameters: [.type: sortType.rawValue]
        ))
    }
    
    private func sendClickAdBannerLog(_ advertisement: Advertisement) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickAdBanner,
            extraParameters: [.advertisementId: advertisement.advertisementId]
        ))
    }
    
    private func sendClickOnlyBossFilterLog(_ isOn: Bool) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickBossFilter,
            extraParameters: [.value: isOn]
        ))
    }
    
    private func sendClickOnlyVisitFilterLog(_ isOn: Bool) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickOnlyVisit,
            extraParameters: [.value: isOn]
        ))
    }
}
