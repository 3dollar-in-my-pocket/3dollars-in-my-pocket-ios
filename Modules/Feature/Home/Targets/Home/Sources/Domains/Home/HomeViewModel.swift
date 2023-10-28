import Foundation
import Combine
import CoreLocation

import Networking
import Model
import Common

final class HomeViewModel: BaseViewModel {
    enum Constent {
        static let defaultLocation = CLLocation(latitude: 37.497941, longitude: 127.027616)
        static let cardAdvertisementIndex = 2
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
        let address = PassthroughSubject<String, Never>()
        let categoryFilter = PassthroughSubject<PlatformStoreCategory?, Never>()
        let isHiddenResearchButton = PassthroughSubject<Bool, Never>()
        let cameraPosition = PassthroughSubject<CLLocation, Never>()
        let advertisementMarker = PassthroughSubject<Advertisement, Never>()
        let advertisementCard = PassthroughSubject<Advertisement?, Never>()
        let collectionItems = PassthroughSubject<[HomeSectionItem], Never>()
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
        var advertisementMarker: Advertisement?
        var advertisementCard: Advertisement?
        var selectedIndex = 0
        var hasMore: Bool = true
        var nextCursor: String? = nil
    }
    
    enum Route {
        case presentCategoryFilter(PlatformStoreCategory?)
        case presentListView(HomeListViewModel.State)
        case pushStoreDetail(storeId: Int)
        case pushBossStoreDetail(storeId: String)
        case presentVisit(StoreCard)
        case presentPolicy
        case presentMarkerAdvertisement
        case presentSearchAddress(SearchAddressViewModel)
        case showErrorAlert(Error)
        case openURL(String)
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
        
        let fetchAroundStore = getCurrentLocation
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, location in
                owner.state.resultCameraPosition = location
                owner.state.currentLocation = owner.state.resultCameraPosition
                owner.output.cameraPosition.send(location)
                owner.userDefaults.userCurrentLocation = location
                owner.output.showLoading.send(false)
            })
            .asyncMap { owner, _ in
                await owner.fetchAroundStore()
            }
            .share()
        
        fetchAroundStore
            .compactMapValue()
            .combineLatest(output.advertisementCard)
            .sink { [weak self] (storeCards: [StoreCard], advertisement: Advertisement?) in
                guard let self else { return }
                state.advertisementCard = advertisement
                updateCollectionItems(storeCards: storeCards, advertisementCard: advertisement)
            }
            .store(in: &cancellables)
        
        fetchAroundStore
            .compactMapError()
            .withUnretained(self)
            .sink(receiveValue: { owner, error in
                owner.output.route.send(.showErrorAlert(error))
            })
            .store(in: &cancellables)
        
        input.viewDidLoad
            .withUnretained(self)
            .asyncMap { owner, _ in
                await owner.userService.fetchUser()
            }
            .compactMapValue()
            .filter { MarketingConsent(value: $0.marketingConsent) == .unverified }
            .map { _ in Route.presentPolicy }
            .subscribe(output.route)
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
                case .success(let storeCards):
                    owner.updateCollectionItems(storeCards: storeCards)
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
                case .success(let storeCards):
                    owner.updateCollectionItems(storeCards: storeCards)
                    
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
                case .success(let storeCards):
                    owner.updateCollectionItems(storeCards: storeCards)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
                }
            })
            .store(in: &cancellables)
        
        input.onTapSearchAddress
            .withUnretained(self)
            .sink { (owner: HomeViewModel, _) in
                owner.presentSearchAddress()
            }
            .store(in: &cancellables)
        
        input.searchByAddress
            .withUnretained(self)
            .handleEvents(receiveOutput: { (owner: HomeViewModel, placeDocument: PlaceDocument) in
                owner.state.address = placeDocument.placeName
                owner.output.address.send(placeDocument.placeName)
                
                let latitude = Double(placeDocument.y) ?? 0
                let longitude = Double(placeDocument.x) ?? 0
                let location = CLLocation(latitude: latitude, longitude: longitude)
                owner.state.newCameraPosition = location
                owner.state.resultCameraPosition = location
                owner.output.cameraPosition.send(location)
            })
            .asyncMap { owner, _ in
                await owner.fetchAroundStore()
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, result in
                owner.output.showLoading.send(false)
                owner.output.isHiddenResearchButton.send(true)
                switch result {
                case .success(let storeCards):
                    owner.updateCollectionItems(storeCards: storeCards)
                    
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
                case .success(let storeCards):
                    owner.updateCollectionItems(storeCards: storeCards)
                    
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
            .withLatestFrom(output.collectionItems)
            .withUnretained(self)
            .map { (owner: HomeViewModel, items: [HomeSectionItem] ) in
                let stores = items.compactMap { $0.storeCard }
                let state = HomeListViewModel.State(
                    categoryFilter: owner.state.categoryFilter,
                    sortType: owner.state.sortType,
                    isOnlyBossStore: owner.state.isOnlyBossStore,
                    mapLocation: owner.state.resultCameraPosition,
                    currentLocation: owner.state.currentLocation,
                    stores: stores,
                    nextCursor: owner.state.nextCursor,
                    hasMore: owner.state.hasMore,
                    mapMaxDistance: owner.state.mapMaxDistance
                )
                
                return Route.presentListView(state)
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
                case .storeCard(let storeCard):
                    guard let location = storeCard.location else { return }
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
                      let store = items[safe: index]?.storeCard,
                      let location = store.location else { return }
                
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
                        guard let linkUrl = advertisement?.linkUrl else { return }
                        output.route.send(.openURL(linkUrl))
                        
                    case .storeCard(let storeCard):
                        pushStoreDetail(store: storeCard)
                        
                    default:
                        break
                    }
                } else {
                    if let storeCard = item.storeCard,
                       let location = storeCard.location {
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
                      let storeCard = item.storeCard else { return }
                
                output.route.send(.presentVisit(storeCard))
            }
            .store(in: &cancellables)
        
        input.onTapCurrentMarker
            .map { Route.presentMarkerAdvertisement }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
    
    private func updateCollectionItems(storeCards: [StoreCard], advertisementCard: Advertisement? = nil) {
        var items: [HomeSectionItem] = storeCards.map { .storeCard($0) }
        let advertisement = advertisementCard ?? state.advertisementCard
        
        if items.isEmpty {
            items = [.empty]
        } else if items.count > Constent.cardAdvertisementIndex {
            items.insert(.advertisement(advertisement), at: Constent.cardAdvertisementIndex)
        } else {
            items.append(.advertisement(advertisement))
        }
        
        output.collectionItems.send(items)
        output.scrollToIndex.send(0)
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
    
    private func fetchAdvertisementMarker() {
        Task {
            let input = FetchAdvertisementInput(position: .storeMarker, size: nil)
            let result = await advertisementService.fetchAdvertisements(input: input)
            
            switch result {
            case .success(let response):
                guard let advertisementResponse = response.first else { return }
                let advertisement = Advertisement(response: advertisementResponse)
                output.advertisementMarker.send(advertisement)
                
            case .failure(_):
                break
            }
        }
    }
    
    private func fetchAdvertisementCard() {
        Task {
            let input = FetchAdvertisementInput(position: .mainPageCard, size: nil)
            let result = await advertisementService.fetchAdvertisements(input: input)
            
            switch result {
            case .success(let response):
                if let advertisementResponse = response.first {
                    let advertisement = Advertisement(response: advertisementResponse)
                    output.advertisementCard.send(advertisement)
                } else {
                    output.advertisementCard.send(nil)
                }
                
            case .failure(_):
                output.advertisementCard.send(nil)
            }
        }
    }
    
    private func pushStoreDetail(store: StoreCard) {
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
}
