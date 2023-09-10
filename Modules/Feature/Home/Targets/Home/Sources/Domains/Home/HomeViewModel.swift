import Foundation
import Combine
import CoreLocation

import Networking
import Model
import Common

final class HomeViewModel: BaseViewModel {
    enum Constent {
        static let defaultLocation = CLLocation(latitude: 37.497941, longitude: 127.027616)
    }
    
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let onMapLoad = PassthroughSubject<Double, Never>()
        let changeMaxDistance = PassthroughSubject<Double, Never>()
        let changeMapLocation = PassthroughSubject<CLLocation, Never>()
        let onTapCategoryFilter = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<PlatformStoreCategory?, Never>()
        let onToggleSort = PassthroughSubject<StoreSortType, Never>()
        let onTapOnlyBoss = PassthroughSubject<Void, Never>()
        let searchByAddress = PassthroughSubject<CLLocation, Never>()
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
        let address = PassthroughSubject<String, Never>()
        let categoryFilter = PassthroughSubject<PlatformStoreCategory?, Never>()
        let isHiddenResearchButton = PassthroughSubject<Bool, Never>()
        let cameraPosition = PassthroughSubject<CLLocation, Never>()
        let advertisementMarker = PassthroughSubject<Advertisement, Never>()
        let storeCards = PassthroughSubject<[StoreCard], Never>()
        let scrollToIndex = PassthroughSubject<Int, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var address = ""
        var categoryFilter: PlatformStoreCategory?
        var sortType: StoreSortType = .distanceAsc
        var isOnlyBossStore = false
        var mapMaxDistance: Double?
        var newCameraPosition: CLLocation?
        var newMapMaxDistance: Double?
        var resultCameraPosition: CLLocation?
        var currentLocation: CLLocation?
        var advertisementMarker: Advertisement? // Splash에서 조회하여 Context로 전달 받아야 함
        var stores: [StoreCard] = []
        var selectedIndex = 0
        var hasMore: Bool = true
        var nextCursor: String? = nil
    }
    
    enum Route {
        case presentCategoryFilter(PlatformStoreCategory?)
        case presentListView(HomeListViewModel.State)
        case pushStoreDetail(storeId: String)
        case presentVisit(StoreCard)
        case presentPolicy
        case presentMarkerAdvertisement
        case showErrorAlert(Error)
    }
    
    let input = Input()
    let output = Output()
    private var state: State
    private let storeService: StoreServiceProtocol
    private let advertisementService: AdvertisementServiceProtocol
    private let userService: UserServiceProtocol
    private let mapService: MapServiceProtocol
    private let locationManager: LocationManagerProtocol
    private var userDefaults: UserDefaultsUtil
    
    init(
        state: State = State(),
        storeService: StoreServiceProtocol = StoreService(),
        advertisementService: AdvertisementServiceProtocol = AdvertisementService(),
        userService: UserServiceProtocol = UserService(),
        mapService: MapServiceProtocol = MapService(),
        locationManager: LocationManagerProtocol = LocationManager.shared,
        userDefaults: UserDefaultsUtil = .shared
    ) {
        self.state = state
        self.storeService = storeService
        self.advertisementService = advertisementService
        self.userService = userService
        self.mapService = mapService
        self.locationManager = locationManager
        self.userDefaults = userDefaults
        super.init()
    }
    
    override func bind() {
        let getCurrentLocation = input.onMapLoad
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, distance in
                owner.state.mapMaxDistance = distance
                owner.output.showLoading.send(true)
            })
            .flatMap { owner, _  in
                owner.locationManager.getCurrentLocationPublisher()
                    .catch { error -> AnyPublisher<CLLocation, Never> in
                        owner.output.showLoading.send(false)
                        owner.output.route.send(.showErrorAlert(error))
                        
                        return Just(Constent.defaultLocation).eraseToAnyPublisher()
                    }
            }
            .share()
        
        getCurrentLocation
            .withUnretained(self)
            .asyncMap { owner, locaiton in
                await owner.mapService.getAddressFromLocation(
                    latitude: locaiton.coordinate.latitude,
                    longitude: locaiton.coordinate.longitude
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
        
        getCurrentLocation
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, location in
                owner.state.resultCameraPosition = location
                owner.state.currentLocation = owner.state.resultCameraPosition
                owner.output.cameraPosition.send(location)
                owner.userDefaults.userCurrentLocation = location
            })
            .asyncMap { owner, _ in
                await owner.fetchAroundStore()
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success(let storeCards):
                    owner.state.stores = storeCards
                    owner.output.storeCards.send(storeCards)
                    owner.output.scrollToIndex.send(0)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
                }
            })
            .store(in: &cancellables)
        
        input.viewDidLoad
            .withUnretained(self)
            .asyncMap { owner, _ in
                await owner.userService.fetchUser()
            }
            .compactMapValue()
            .filter { $0.marketingConsent == .unverified }
            .map { _ in Route.presentPolicy }
            .subscribe(output.route)
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
            .map { owner, _ in
                Route.presentCategoryFilter(owner.state.categoryFilter)
            }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.selectCategory
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, categoryFilter in
                owner.state.categoryFilter = categoryFilter
            })
            .asyncMap { owner, _ in
                await owner.fetchAroundStore()
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, result in
                owner.output.showLoading.send(false)
                
                switch result {
                case .success(let storeCard):
                    owner.state.stores = storeCard
                    owner.output.storeCards.send(storeCard)
                    owner.output.scrollToIndex.send(0)
                    owner.output.categoryFilter.send(owner.state.categoryFilter)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
                }
            })
            .store(in: &cancellables)
        
        input.onToggleSort
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, sortType in
                owner.state.sortType = sortType
            })
            .asyncMap { owner, _ in
                await owner.fetchAroundStore()
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, result in
                owner.output.showLoading.send(false)
                
                switch result {
                case .success(let storeCard):
                    owner.state.stores = storeCard
                    owner.output.storeCards.send(storeCard)
                    owner.output.scrollToIndex.send(0)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
                }
            })
            .store(in: &cancellables)
        
        input.onTapOnlyBoss
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, isOnlyBoss in
                owner.state.isOnlyBossStore.toggle()
            })
            .asyncMap { owner, _ in
                await owner.fetchAroundStore()
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, result in
                switch result {
                case .success(let storeCard):
                    owner.state.stores = storeCard
                    owner.output.storeCards.send(storeCard)
                    owner.output.scrollToIndex.send(0)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
                }
            })
            .store(in: &cancellables)
        
        input.onTapResearch
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
                owner.state.mapMaxDistance = owner.state.newMapMaxDistance
                owner.state.resultCameraPosition = owner.state.newCameraPosition
            })
            .asyncMap { owner, _ in
                await owner.fetchAroundStore()
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, result in
                owner.output.showLoading.send(false)
                owner.output.isHiddenResearchButton.send(true)
                
                switch result {
                case .success(let storeCard):
                    owner.state.stores = storeCard
                    owner.output.storeCards.send(storeCard)
                    owner.output.scrollToIndex.send(0)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
                }
            })
            .store(in: &cancellables)
        
        input.onTapResearch
            .withUnretained(self)
            .asyncMap { owner, _ in
                let latitude = owner.state.newCameraPosition?.coordinate.latitude ?? Constent.defaultLocation.coordinate.latitude
                let longitude = owner.state.newCameraPosition?.coordinate.longitude ?? Constent.defaultLocation.coordinate.longitude
                
                return await owner.mapService.getAddressFromLocation(
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
                owner.locationManager.getCurrentLocationPublisher()
                    .catch { error -> AnyPublisher<CLLocation, Never> in
                        owner.output.route.send(.showErrorAlert(error))
                        return Empty().eraseToAnyPublisher()
                    }
            }
            .withUnretained(self)
            .sink { owner, location in
                owner.userDefaults.userCurrentLocation = location
                owner.state.currentLocation = location
                owner.output.cameraPosition.send(location)
            }
            .store(in: &cancellables)
        
        input.onTapListView
            .withUnretained(self)
            .map { owner, _ in
                let state = HomeListViewModel.State(
                    categoryFilter: owner.state.categoryFilter,
                    sortType: owner.state.sortType,
                    isOnlyBossStore: owner.state.isOnlyBossStore,
                    mapLocation: owner.state.resultCameraPosition,
                    currentLocation: owner.state.currentLocation,
                    stores: owner.state.stores,
                    nextCursor: owner.state.nextCursor,
                    hasMore: owner.state.hasMore,
                    mapMaxDistance: owner.state.mapMaxDistance
                )
                
                return Route.presentListView(state)
            }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.selectStore
            .withUnretained(self)
            .sink { owner, selectIndex in
                guard let store = owner.state.stores[safe: selectIndex],
                      let location = store.location else { return }
                let cameraPosition = CLLocation(latitude: location.latitude, longitude: location.longitude)
                owner.output.cameraPosition.send(cameraPosition)
                owner.output.scrollToIndex.send(selectIndex)
            }
            .store(in: &cancellables)
        
        input.onTapMarker
            .withUnretained(self)
            .sink { owner, selectIndex in
                guard let store = owner.state.stores[safe: selectIndex],
                      let location = store.location else { return }
                let cameraPosition = CLLocation(latitude: location.latitude, longitude: location.longitude)
                owner.output.cameraPosition.send(cameraPosition)
                owner.output.scrollToIndex.send(selectIndex)
            }
            .store(in: &cancellables)
        
        input.onTapStore
            .withUnretained(self)
            .sink { owner, selectIndex in
                guard let store = owner.state.stores[safe: selectIndex],
                      let location = store.location else { return }
                
                if selectIndex == owner.state.selectedIndex {
                    owner.output.route.send(.pushStoreDetail(storeId: store.storeId))
                } else {
                    let cameraPosition = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    owner.output.cameraPosition.send(cameraPosition)
                    owner.output.scrollToIndex.send(selectIndex)
                    owner.state.selectedIndex = selectIndex
                }
            }
            .store(in: &cancellables)
        
        input.onTapVisitButton
            .withUnretained(self)
            .sink { owner, selectIndex in
                guard let store = owner.state.stores[safe: selectIndex] else { return }
                
                owner.output.route.send(.presentVisit(store))
            }
            .store(in: &cancellables)
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
            filterCertifiedStores: state.isOnlyBossStore,
            size: 10,
            cursor: nil,
            mapLatitude: state.resultCameraPosition?.coordinate.latitude ?? 0,
            mapLongitude: state.resultCameraPosition?.coordinate.longitude ?? 0
        )
        
        return await storeService.fetchAroundStores(
            input: input,
            latitude: state.currentLocation?.coordinate.latitude ?? 0,
            longitude: state.currentLocation?.coordinate.longitude ?? 0
        )
        .map{ [weak self] response in
            self?.state.nextCursor = response.cursor.nextCursor
            self?.state.hasMore = response.cursor.hasMore
            
            return response.contents.map(StoreCard.init(response:))
        }
    }
}
