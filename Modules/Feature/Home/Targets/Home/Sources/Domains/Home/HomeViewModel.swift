import Foundation
import Combine
import CoreLocation

import Networking
import Model
import Common
import Log
import AppInterface
import MembershipInterface

extension HomeViewModel {
    enum Constant {
        static let defaultLocation = CLLocation(latitude: 37.497941, longitude: 127.027616)
        static let cardAdvertisementIndex = 2
    }
    
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let onLoadFilter = PassthroughSubject<Void, Never>()
        let onMapLoad = PassthroughSubject<Double, Never>()
        let changeMaxDistance = PassthroughSubject<Double, Never>()
        let changeMapLocation = PassthroughSubject<CLLocation, Never>()
        let onTapCategoryFilter = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<StoreFoodCategoryResponse?, Never>()
        let onTapOnlyRecentActivity = PassthroughSubject<Void, Never>()
        let onToggleSort = PassthroughSubject<StoreSortType, Never>()
        let onTapOnlyBoss = PassthroughSubject<Void, Never>()
        let onTapSearchAddress = PassthroughSubject<Void, Never>()
        let searchByAddress = PassthroughSubject<PlaceDocument, Never>()
        let onTapResearch = PassthroughSubject<Void, Never>()
        let onTapCurrentLocation = PassthroughSubject<Void, Never>()
        let onTapListView = PassthroughSubject<Void, Never>()
        let selectStore = PassthroughSubject<Int, Never>()
        let onTapStore = PassthroughSubject<Int, Never>()
        let onTapVisitButton = PassthroughSubject<Int, Never>()
        let onTapMarker = PassthroughSubject<Int, Never>()
        let onTapCurrentMarker = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .home
        let address = PassthroughSubject<String, Never>()
        let filterDatasource = CurrentValueSubject<[HomeFilterCollectionView.CellType], Never>([
            .category(nil),
            .recentActivity(false),
            .sortingFilter(.distanceAsc),
            .onlyBoss(false)
        ])
        let isHiddenResearchButton = PassthroughSubject<Bool, Never>()
        let cameraPosition = PassthroughSubject<CLLocation, Never>()
        let advertisementMarker = PassthroughSubject<AdvertisementResponse, Never>()
        let advertisementCard = PassthroughSubject<AdvertisementResponse?, Never>()
        let collectionItems = PassthroughSubject<[HomeSectionItem], Never>()
        let scrollToIndex = PassthroughSubject<Int, Never>()
        let isShowFilterTooltip = PassthroughSubject<Bool, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var address = ""
        var categoryFilter: StoreFoodCategoryResponse?
        var store: [StoreWithExtraResponse] = []
        var sortType: StoreSortType = .distanceAsc
        var isOnlyBossStore = false
        var isOnlyRecentActivity = false
        var mapMaxDistance: Double?
        var newCameraPosition: CLLocation?
        var newMapMaxDistance: Double?
        var resultCameraPosition: CLLocation?
        var currentLocation: CLLocation?
        var advertisementMarker: AdvertisementResponse?
        var advertisementCard: AdvertisementResponse?
        var selectedIndex = 0
        var hasMore: Bool = true
        var nextCursor: String? = nil
        var user: UserDetailResponse?
    }
    
    enum Route {
        case presentCategoryFilter(CategoryFilterViewModel)
        case presentListView(HomeListViewModel)
        case pushStoreDetail(storeId: Int)
        case pushBossStoreDetail(storeId: String)
        case presentVisit(StoreResponse)
        case presentPolicy
        case presentMarkerAdvertisement
        case presentSearchAddress(SearchAddressViewModel)
        case showErrorAlert(Error)
        case deepLink(AdvertisementResponse)
        case presentAccountInfo(BaseViewModel)
    }
    
    struct Dependency {
        let storeRepository: StoreRepository
        let advertisementRepository: AdvertisementRepository
        let userRepository: UserRepository
        let mapRepository: MapRepository
        let locationManager: LocationManagerProtocol
        var preference: Preference
        let logManager: LogManagerProtocol
        let appModuleInterface: AppModuleInterface
        
        init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            advertisementRepository: AdvertisementRepository = AdvertisementRepositoryImpl(),
            userRepository: UserRepository = UserRepositoryImpl(),
            mapRepository: MapRepository = MapRepositoryImpl(),
            locationManager: LocationManagerProtocol = LocationManager.shared,
            preference: Preference = .shared,
            logManager: LogManagerProtocol = LogManager.shared,
            appModuleInterface: AppModuleInterface = Environment.appModuleInterface
        ) {
            self.storeRepository = storeRepository
            self.advertisementRepository = advertisementRepository
            self.userRepository = userRepository
            self.mapRepository = mapRepository
            self.locationManager = locationManager
            self.preference = preference
            self.logManager = logManager
            self.appModuleInterface = appModuleInterface
        }
    }
}

final class HomeViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state = State()
    private var dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        super.init()
    }
    
    override func bind() {
        input.onMapLoad
            .withUnretained(self)
            .sink { (owner: HomeViewModel, _) in
                owner.fetchAdvertisementMarker()
            }
            .store(in: &cancellables)
        
        let getCurrentLocation = input.onMapLoad
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, distance in
                owner.state.mapMaxDistance = distance
                owner.output.showLoading.send(true)
            })
            .flatMap { owner, _  in
                owner.dependency.locationManager.getCurrentLocationPublisher()
                    .catch { error -> AnyPublisher<CLLocation, Never> in
                        owner.output.showLoading.send(false)
                        owner.output.route.send(.showErrorAlert(error))
                        
                        return Just(Constant.defaultLocation).eraseToAnyPublisher()
                    }
            }
            .share()
        
        getCurrentLocation
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, location: CLLocation) in
                owner.dependency.preference.userCurrentLocation = location
                owner.fetchAddress(location: location)
            })
            .store(in: &cancellables)
        
        getCurrentLocation
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, location: CLLocation) in
                owner.state.resultCameraPosition = location
                owner.state.currentLocation = owner.state.resultCameraPosition
                owner.output.cameraPosition.send(location)
                owner.dependency.preference.userCurrentLocation = location
                owner.fetchAroundStores()
            })
            .store(in: &cancellables)
                
        input.viewDidLoad
            .withUnretained(self)
            .asyncMap { owner, _ in
                await owner.dependency.userRepository.fetchUser()
            }
            .compactMapValue()
            .withUnretained(self)
            .sink { (owner: HomeViewModel, user: UserDetailResponse) in
                switch MarketingConsent(value: user.settings.marketingConsent) {
                case .approve:
                    owner.subscribeMarketingTopic()
                    owner.presentAccountInfoIfNeeded(user: user)
                case .unverified:
                    owner.output.route.send(.presentPolicy)
                    
                case .deny, .unknown:
                    owner.presentAccountInfoIfNeeded(user: user)
                }
            }
            .store(in: &cancellables)
        
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: HomeViewModel, _) in
                owner.fetchAdvertisementCard()
            }
            .store(in: &cancellables)
        
        input.changeMaxDistance
            .withUnretained(self)
            .sink { owner, distance in
                owner.state.newMapMaxDistance = distance
                owner.output.isHiddenResearchButton.send(false)
            }
            .store(in: &cancellables)
        
        input.changeMapLocation
            .withUnretained(self)
            .sink { owner, location in
                owner.state.newCameraPosition = location
                owner.output.isHiddenResearchButton.send(false)
            }
            .store(in: &cancellables)
        
        input.onTapCategoryFilter
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, _) in
                owner.hiddenTooltip()
                owner.sendClickCategoryFilterLog()
                owner.presentCategoryFilter()
            })
            .store(in: &cancellables)
        
        input.selectCategory
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, category: StoreFoodCategoryResponse?) in
                owner.state.categoryFilter = category
                owner.fetchAroundStores()
                owner.hiddenTooltip()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)
        
        input.onTapOnlyRecentActivity
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, _) in
                owner.hiddenTooltip()
                owner.state.isOnlyRecentActivity.toggle()
                owner.sendClickRecentActivityFilter(value: owner.state.isOnlyRecentActivity)
                owner.fetchAroundStores()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)
        
        input.onToggleSort
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, sortType: StoreSortType) in
                owner.hiddenTooltip()
                owner.state.sortType = owner.state.sortType.toggled()
                owner.sendClickSortingFilterLog(sortType: sortType)
                owner.fetchAroundStores()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)
        
        input.onTapOnlyBoss
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, _) in
                owner.hiddenTooltip()
                owner.state.isOnlyBossStore.toggle()
                owner.sendClickOnlyBossFilterLog(isOn: owner.state.isOnlyBossStore)
                owner.fetchAroundStores()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)
        
        input.onTapSearchAddress
            .withUnretained(self)
            .sink { (owner: HomeViewModel, _) in
                owner.sendClickAddressLog()
                owner.presentSearchAddress()
            }
            .store(in: &cancellables)
        
        input.searchByAddress
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, placeDocument: PlaceDocument) in
                owner.state.address = placeDocument.placeName
                owner.output.address.send(placeDocument.placeName)
                
                let latitude = Double(placeDocument.y) ?? 0
                let longitude = Double(placeDocument.x) ?? 0
                let location = CLLocation(latitude: latitude, longitude: longitude)
                owner.state.newCameraPosition = location
                owner.state.resultCameraPosition = location
                owner.output.cameraPosition.send(location)
                owner.fetchAroundStores()
                owner.output.isHiddenResearchButton.send(true)
            })
            .store(in: &cancellables)
        
        input.onTapResearch
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, _) in
                owner.output.showLoading.send(true)
                owner.state.mapMaxDistance = owner.state.newMapMaxDistance
                owner.state.resultCameraPosition = owner.state.newCameraPosition
                owner.fetchAroundStores()
                owner.output.isHiddenResearchButton.send(true)
            })
            .store(in: &cancellables)
        
        input.onTapResearch
            .withUnretained(self)
            .asyncMap { owner, _ in
                let latitude = owner.state.newCameraPosition?.coordinate.latitude ?? Constant.defaultLocation.coordinate.latitude
                let longitude = owner.state.newCameraPosition?.coordinate.longitude ?? Constant.defaultLocation.coordinate.longitude
                
                return await owner.dependency.mapRepository.getAddressFromLocation(
                    latitude: latitude,
                    longitude: longitude
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let address):
                    owner.state.address = address
                    owner.output.address.send(address)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
                }
            }
            .store(in: &cancellables)
            
        
        input.onTapCurrentLocation
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.dependency.locationManager.getCurrentLocationPublisher()
                    .catch { error -> AnyPublisher<CLLocation, Never> in
                        owner.output.route.send(.showErrorAlert(error))
                        return Empty().eraseToAnyPublisher()
                    }
            }
            .withUnretained(self)
            .sink { owner, location in
                owner.sendClickCurrentLocationLog()
                owner.dependency.preference.userCurrentLocation = location
                owner.state.currentLocation = location
                owner.output.cameraPosition.send(location)
            }
            .store(in: &cancellables)
        
        input.onTapListView
            .withLatestFrom(output.collectionItems)
            .withUnretained(self)
            .map { (owner: HomeViewModel, items: [HomeSectionItem] ) in
                let stores = items.compactMap { $0.store }
                let state = HomeListViewModel.State(
                    stores: .init(stores),
                    categoryFilter: owner.state.categoryFilter,
                    isOnlyRecentActivity: owner.state.isOnlyRecentActivity,
                    sortType: owner.state.sortType,
                    isOnlyBossStore: owner.state.isOnlyBossStore,
                    mapLocation: owner.state.resultCameraPosition,
                    currentLocation: owner.state.currentLocation,
                    nextCursor: owner.state.nextCursor,
                    hasMore: owner.state.hasMore,
                    mapMaxDistance: owner.state.mapMaxDistance
                )
                let config = HomeListViewModel.Config(initialState: state)
                let viewModel = HomeListViewModel(config: config)
                owner.bindHomeListViewModel(viewModel)
                
                return Route.presentListView(viewModel)
            }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.selectStore
            .withLatestFrom(output.collectionItems) { ($0, $1) }
            .handleEvents(receiveOutput: { [weak self] (index: Int, items: [HomeSectionItem]) in
                self?.output.scrollToIndex.send(index)
                self?.state.selectedIndex = index
            })
            .compactMap { (index: Int, items: [HomeSectionItem]) in
                return items[safe: index]
            }
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, sectionItem: HomeSectionItem) in
                switch sectionItem {
                case .store(let storeWithExtra):
                    guard let location = storeWithExtra.store.location else { return }
                    let cameraPosition = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    owner.output.cameraPosition.send(cameraPosition)
                    
                case .empty, .advertisement:
                    break
                }
            })
            .store(in: &cancellables)
        
        input.onTapMarker
            .withLatestFrom(output.collectionItems) { ($0, $1) }
            .sink(receiveValue: { [weak self] (index: Int, items: [HomeSectionItem]) in
                guard let self,
                      let store = items[safe: index]?.store,
                      let location = store.store.location else { return }
                sendClickMarkerLog(store: store.store)
                
                let cameraPosition = CLLocation(latitude: location.latitude, longitude: location.longitude)
                output.cameraPosition.send(cameraPosition)
                output.scrollToIndex.send(index)
            })
            .store(in: &cancellables)
        
        input.onTapStore
            .withLatestFrom(output.collectionItems) { ($0, $1) }
            .sink(receiveValue: { [weak self] (index: Int, items: [HomeSectionItem]) in
                guard let self,
                      let item = items[safe: index] else { return }
                
                if index == state.selectedIndex {
                    switch item {
                    case .advertisement(let advertisement):
                        guard let advertisement = advertisement else { return }
                        sendClickAdCard(advertisement: advertisement)
                        output.route.send(.deepLink(advertisement))
                    case .store(let storeWithExtra):
                        sendClickStoreLog(storeWithExtra.store)
                        pushStoreDetail(store: storeWithExtra.store)
                        
                    default:
                        break
                    }
                } else {
                    if let store = item.store?.store,
                       let location = store.location {
                        let cameraPosition = CLLocation(latitude: location.latitude, longitude: location.longitude)
                        output.cameraPosition.send(cameraPosition)
                    }
                    output.scrollToIndex.send(index)
                    state.selectedIndex = index
                }
            })
            .store(in: &cancellables)
        
        input.onTapVisitButton
            .withLatestFrom(output.collectionItems) { ($0, $1) }
            .sink { [weak self] index, items in
                guard let self,
                      let item = items[safe: index],
                      let store = item.store?.store else { return }
                sendClickVisitStoreLog(store)
                output.route.send(.presentVisit(store))
            }
            .store(in: &cancellables)
        
        input.onTapCurrentMarker
            .filter { [weak self] in
                return self?.state.advertisementMarker != nil
            }
            .map { Route.presentMarkerAdvertisement }
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self = self,
                      let advertisement = state.advertisementMarker else { return }
                sendClickAdMarker(advertisement: advertisement)
            })
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.onLoadFilter
            .withUnretained(self)
            .sink { (owner: HomeViewModel, _) in
                if owner.dependency.preference.isShownFilterTooltip.isNot {
                    owner.output.isShowFilterTooltip.send(true)
                }
            }
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
    
    private func updateDatasource() {
        var items: [HomeSectionItem] = state.store.map { .store($0) }
        let advertisement = state.advertisementCard
        
        if items.isEmpty {
            items = [.empty]
        } else if items.count > Constant.cardAdvertisementIndex {
            items.insert(.advertisement(advertisement), at: Constant.cardAdvertisementIndex)
        } else {
            items.append(.advertisement(advertisement))
        }
        
        output.collectionItems.send(items)
        output.scrollToIndex.send(0)
    }
    
    private func fetchAroundStores() {
        Task {
            let input = createFetchAroundStoreInput()
            let result = await dependency.storeRepository.fetchAroundStores(input: input)
            
            switch result {
            case .success(let response):
                state.nextCursor = response.cursor.nextCursor
                state.hasMore = response.cursor.hasMore
                state.store = response.contents
                updateDatasource()
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
            output.showLoading.send(false)
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
            filterCertifiedStores: false,
            filterConditions: filterConditions,
            size: 10,
            cursor: nil,
            mapLatitude: state.resultCameraPosition?.coordinate.latitude ?? 0,
            mapLongitude: state.resultCameraPosition?.coordinate.longitude ?? 0
        )
    }
    
    private func fetchAdvertisementMarker() {
        Task {
            let input = FetchAdvertisementInput(position: .storeMarker, size: nil)
            let result = await dependency.advertisementRepository.fetchAdvertisements(input: input)
            
            switch result {
            case .success(let response):
                guard let advertisement = response.advertisements.first else { return }
                state.advertisementMarker = advertisement
                output.advertisementMarker.send(advertisement)
            case .failure(_):
                break
            }
        }
    }
    
    private func fetchAdvertisementCard() {
        Task {
            let input = FetchAdvertisementInput(position: .mainPageCard, size: nil)
            let result = await dependency.advertisementRepository.fetchAdvertisements(input: input)
            
            switch result {
            case .success(let response):
                if let advertisement = response.advertisements.first {
                    state.advertisementCard = advertisement
                    output.advertisementCard.send(advertisement)
                } else {
                    output.advertisementCard.send(nil)
                }
                
            case .failure(_):
                output.advertisementCard.send(nil)
            }
        }
    }
    
    private func pushStoreDetail(store: StoreResponse) {
        if store.storeType == .userStore {
            output.route.send(.pushStoreDetail(storeId: Int(store.storeId) ?? 0))
        } else {
            output.route.send(.pushBossStoreDetail(storeId: store.storeId))
        }
    }
    
    private func presentSearchAddress() {
        let viewModel = SearchAddressViewModel()
        viewModel.output.selectAddress
            .subscribe(input.searchByAddress)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.presentSearchAddress(viewModel))
    }
    
    private func bindHomeListViewModel(_ viewModel: HomeListViewModel) {
        viewModel.output.onToggleSort
            .subscribe(input.onToggleSort)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.onTapOnlyBoss
            .subscribe(input.onTapOnlyBoss)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.onSelectCategoryFilter
            .subscribe(input.selectCategory)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.onTapOnlyRecentActivity
            .subscribe(input.onTapOnlyRecentActivity)
            .store(in: &viewModel.cancellables)
    }
    
    private func subscribeMarketingTopic() {
        guard !dependency.preference.subscribedMarketingTopic else { return }
        
        dependency.appModuleInterface.subscribeMarketingFCMTopic { [weak self] error in
            if let error {
                self?.output.route.send(.showErrorAlert(error))
            } else {
                self?.dependency.preference.subscribedMarketingTopic = true
            }
        }
    }
    
    private func hiddenTooltip() {
        guard dependency.preference.isShownFilterTooltip.isNot else { return }
        dependency.preference.isShownFilterTooltip = true
        output.isShowFilterTooltip.send(false)
    }
    
    private func fetchAddress(location: CLLocation) {
        Task {
            let result = await dependency.mapRepository.getAddressFromLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            switch result {
            case .success(let address):
                state.address = address
                output.address.send(address)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func presentCategoryFilter() {
        let config = CategoryFilterViewModel.Config(currentCategory: state.categoryFilter)
        let viewModel = CategoryFilterViewModel(config: config)
        
        viewModel.output.didSelectCategory
            .subscribe(input.selectCategory)
            .store(in: &viewModel.cancellables)
        output.route.send(.presentCategoryFilter(viewModel))
    }
    
    private func presentAccountInfoIfNeeded(user: UserDetailResponse) {
        guard user.gender.isNil && user.birth.isNil,
              dependency.preference.shownAccountInfo.isNot else { return }
        let config = AccountInfoViewModelConfig(shouldPush: false)
        let viewModel = Environment.membershipInterface.createAccountInfoViewModel(config: config)
        
        output.route.send(.presentAccountInfo(viewModel))
    }
}

// MARK: Log
extension HomeViewModel {
    private func sendClickStoreLog(_ store: StoreResponse) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickStore,
            extraParameters: [
                .storeId: store.storeId,
                .type: store.storeType.rawValue
            ]))
    }
    
    private func sendClickVisitStoreLog(_ store: StoreResponse) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickVisit,
            extraParameters: [.storeId: store.storeId]
        ))
    }
    
    private func sendClickCurrentLocationLog() {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickCurrentLocation
        ))
    }
    
    private func sendClickMarkerLog(store: StoreResponse) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickMarker,
            extraParameters: [
                .storeId: store.storeId,
                .type: store.storeType.rawValue
            ]
        ))
    }
    
    private func sendClickAddressLog() {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickAddressField
        ))
    }
    
    private func sendClickCategoryFilterLog() {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickCategoryFilter
        ))
    }
    
    private func sendClickOnlyBossFilterLog(isOn: Bool) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickBossFilter,
            extraParameters: [.value: isOn]
        ))
    }
    
    private func sendClickSortingFilterLog(sortType: StoreSortType) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickSorting,
            extraParameters: [.type: sortType.rawValue]
        ))
    }
    
    private func sendClickAdCard(advertisement: AdvertisementResponse) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickAdCard,
            extraParameters: [.advertisementId: advertisement.advertisementId]
        ))
    }
    
    private func sendClickAdMarker(advertisement: AdvertisementResponse) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickAdMarker,
            extraParameters: [.advertisementId: advertisement.advertisementId]
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

extension HomeViewModel: HomeFilterSelectable {
    var onTapCategoryFilter: PassthroughSubject<Void, Never> {
        input.onTapCategoryFilter
    }
    
    var onTapOnlyRecentActivity: PassthroughSubject<Void, Never> {
        input.onTapOnlyRecentActivity
    }
    
    var onToggleSort: PassthroughSubject<Model.StoreSortType, Never> {
        input.onToggleSort
    }
    
    var onTapOnlyBoss: PassthroughSubject<Void, Never> {
        input.onTapOnlyBoss
    }
    
    var selectCategory: PassthroughSubject<StoreFoodCategoryResponse?, Never> {
        input.selectCategory
    }
    
    var filterDatasource: CurrentValueSubject<[HomeFilterCollectionView.CellType], Never> {
        output.filterDatasource
    }
}
