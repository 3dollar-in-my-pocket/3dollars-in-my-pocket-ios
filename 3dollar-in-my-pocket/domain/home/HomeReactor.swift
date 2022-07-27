import CoreLocation
import MapKit

import RxSwift
import RxCocoa
import ReactorKit

final class HomeReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case changeMaxDistance(maxDistance: Double)
        case changeMapLocation(CLLocation)
        case tapStoreTypeButton
        case searchByAddress(location: CLLocation, address: String)
        case tapResearchButton
        case tapCurrentLocationButton
        case selectStore(index: Int)
//        case updateStore(store: Store) // TODO: GlobalState로 빼야합니다. 상세화면에서 가게 업데이트
        case tapStore(index: Int)
        case tapVisitButton(index: Int)
        case tapMarker(index: Int)
    }
    
    enum Mutation {
        case setStoreType(StoreType)
        case setStoreCellTypes([StoreCellType])
        case setCategories([Categorizable])
        case setCurrentLocation(CLLocation)
        case setAddressText(address: String)
        case setMaxDistance(Double)
        case setCameraPosition(CLLocation)
        case selectStore(index: Int?)
        case updateStore(store: StoreProtocol)
        case setHiddenResearchButton(Bool)
        case presentVisit(store: Store)
        case pushStoreDetail(storeId: String)
        case pushBossStoreDetail(storeId: String)
        case pushWebView(url: String)
        case showLoading(Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var storeType: StoreType
        var categories: [Categorizable]
        var selectedCategory: Categorizable?
        var address: String
        var isHiddenResearchButton: Bool
        var selectedIndex: Int?
        var mapMaxDistance: Double
        var cameraPosition: CLLocation?
        var currentLocation: CLLocation
        var storeCellTypes: [StoreCellType] = []
    }
    
    let initialState: State
    let pushStoreDetailPublisher = PublishRelay<String>()
    let pushBossStoreDetailPublisher = PublishRelay<String>()
    let presentVisitPublisher = PublishRelay<Store>()
    private var foodTruckCategory: [Categorizable] = []
    private var streetFoodCategory: [Categorizable] = []
    private let storeService: StoreServiceProtocol
    private let categoryService: CategoryServiceProtocol
    private let advertisementService: AdvertisementServiceProtocol
    private let locationManager: LocationManagerProtocol
    private let mapService: MapServiceProtocol
    private let userDefaults: UserDefaultsUtil
    
    init(
        storeService: StoreServiceProtocol,
        categoryService: CategoryServiceProtocol,
        advertisementService: AdvertisementServiceProtocol,
        locationManager: LocationManagerProtocol,
        mapService: MapServiceProtocol,
        userDefaults: UserDefaultsUtil,
        state: State = State(
            storeType: .streetFood,
            categories: [],
            address: "",
            isHiddenResearchButton: true,
            selectedIndex: nil,
            mapMaxDistance: 2000,
            cameraPosition: nil,
            currentLocation: CLLocation(latitude: 0, longitude: 0)
        )
    ) {
        self.storeService = storeService
        self.categoryService = categoryService
        self.advertisementService = advertisementService
        self.locationManager = locationManager
        self.mapService = mapService
        self.userDefaults = userDefaults
        self.initialState = state
        
        super.init()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return Observable.zip(
                self.categoryService.fetchStreetFoodCategories(),
                self.categoryService.fetchFoodTruckCategories()
            )
            .do(onNext: { [weak self] streetFoodCategory, foodTruckCategory in
                self?.streetFoodCategory = streetFoodCategory
                self?.foodTruckCategory = foodTruckCategory
            })
            .map { Mutation.setCategories($0.0) }
            .catch { .just(.showErrorAlert($0)) }
            
        case .changeMaxDistance(let maxDistance):
            return .just(.setMaxDistance(maxDistance))
            
        case .changeMapLocation(let mapLocation):
            return .merge([
                .just(.setHiddenResearchButton(false)),
                .just(.setCameraPosition(mapLocation))
            ])
            
        case .tapStoreTypeButton:
            let toggleStoreType = self.currentState.storeType.toggle()
            let toggleCateogires = self.getCategories(by: toggleStoreType)
            
            if toggleStoreType == .streetFood {
                return .concat([
                    .just(.showLoading(true)),
                    .just(.setStoreType(toggleStoreType)),
                    .just(.setCategories(toggleCateogires)),
                    self.searchNearStores(
                        categoryId: self.currentState.selectedCategory?.id,
                        distance: self.currentState.mapMaxDistance,
                        currentLocation: self.currentState.currentLocation,
                        mapLocation: self.currentState.cameraPosition ?? self.currentState.currentLocation
                    ),
                    self.fetchAddressFromLocation(location: self.currentState.cameraPosition),
                    .just(.selectStore(index: nil)),
                    .just(.setHiddenResearchButton(true)),
                    .just(.showLoading(false))
                ])
            } else {
                return .concat([
                    .just(.showLoading(true)),
                    .just(.setStoreType(toggleStoreType)),
                    .just(.setCategories(toggleCateogires)),
                    self.searchNearBossStore(
                        categoryId: self.currentState.selectedCategory?.id,
                        distance: self.currentState.mapMaxDistance,
                        currentLocation: self.currentState.currentLocation,
                        mapLocation: self.currentState.cameraPosition ?? self.currentState.currentLocation
                    ),
                    self.fetchAddressFromLocation(location: self.currentState.cameraPosition),
                    .just(.selectStore(index: nil)),
                    .just(.setHiddenResearchButton(true)),
                    .just(.showLoading(false))
                ])
            }
            
        case .searchByAddress(let location, let address):
            if self.currentState.storeType == .streetFood {
                return .concat([
                    .just(.setCameraPosition(location)),
                    .just(.setAddressText(address: address)),
                    self.searchNearStores(
                        categoryId: self.currentState.selectedCategory?.id,
                        distance: self.currentState.mapMaxDistance,
                        currentLocation: self.currentState.currentLocation,
                        mapLocation: self.currentState.cameraPosition ?? self.currentState.currentLocation
                    )
                ])
            } else {
                return .concat([
                    .just(.setCameraPosition(location)),
                    .just(.setAddressText(address: address)),
                    self.searchNearBossStore(
                        categoryId: self.currentState.selectedCategory?.id,
                        distance: self.currentState.mapMaxDistance,
                        currentLocation: self.currentState.currentLocation,
                        mapLocation: self.currentState.cameraPosition ?? self.currentState.currentLocation
                    )
                ])
            }
            
        case .tapResearchButton:
            if self.currentState.storeType == .streetFood {
                return .concat([
                    .just(.showLoading(true)),
                    self.searchNearStores(
                        categoryId: self.currentState.selectedCategory?.id,
                        distance: self.currentState.mapMaxDistance,
                        currentLocation: self.currentState.currentLocation,
                        mapLocation: self.currentState.cameraPosition ?? self.currentState.currentLocation
                    ),
                    self.fetchAddressFromLocation(location: self.currentState.cameraPosition),
                    .just(.selectStore(index: nil)),
                    .just(.setHiddenResearchButton(true)),
                    .just(.showLoading(false))
                ])
            } else {
                return .concat([
                    .just(.showLoading(true)),
                    self.searchNearBossStore(
                        categoryId: self.currentState.selectedCategory?.id,
                        distance: self.currentState.mapMaxDistance,
                        currentLocation: self.currentState.currentLocation,
                        mapLocation: self.currentState.cameraPosition ?? self.currentState.currentLocation
                    ),
                    self.fetchAddressFromLocation(location: self.currentState.cameraPosition),
                    .just(.selectStore(index: nil)),
                    .just(.setHiddenResearchButton(true)),
                    .just(.showLoading(false))
                ])
            }
            
        case .tapCurrentLocationButton:
            return .concat([
                .just(.showLoading(true)),
                self.refreshCurrentLocation(),
                .just(.showLoading(false))
            ])
            
        case .selectStore(let index):
            let selectedStoreCell = self.currentState.storeCellTypes[index]
            
            switch selectedStoreCell {
            case .store(let store):
                if let store = store as? Store {
                    let location = CLLocation(
                        latitude: store.latitude,
                        longitude: store.longitude
                    )
                    
                    return .merge([
                        .just(.setCameraPosition(location)),
                        .just(.selectStore(index: index))
                    ])
                } else if let bossStore = store as? BossStore,
                          let latitude = bossStore.location?.latitude,
                          let longitude = bossStore.location?.longitude {
                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    
                    return .merge([
                        .just(.setCameraPosition(location)),
                        .just(.selectStore(index: index))
                    ])
                } else {
                    return .error(BaseError.unknown)
                }
                
            case .advertisement:
                return .just(.selectStore(index: index))
                
            case .empty:
                return .empty()
            }
            
        case .tapStore(let index):
            let selectedStoreCell = self.currentState.storeCellTypes[index]
            
            if index == self.currentState.selectedIndex {
                switch selectedStoreCell {
                case .store(let store):
                    if let store = store as? Store {
                        return .just(.pushStoreDetail(storeId: store.id))
                    } else {
                        return .just(.pushBossStoreDetail(storeId: store.id))
                    }
                    
                case .advertisement(let advertisement):
                    return .just(.pushWebView(url: advertisement.linkUrl))
                    
                case .empty:
                    return .empty()
                }
            } else {
                switch selectedStoreCell {
                case .store(let store):
                    if let store = store as? Store {
                        let location = CLLocation(
                            latitude: store.latitude,
                            longitude: store.longitude
                        )
                        
                        return .merge([
                            .just(.setCameraPosition(location)),
                            .just(.selectStore(index: index))
                        ])
                    } else if let bossStore = store as? BossStore,
                              let latitude = bossStore.location?.latitude,
                              let longitude = bossStore.location?.longitude {
                        let location = CLLocation(latitude: latitude, longitude: longitude)
                        
                        return .merge([
                            .just(.setCameraPosition(location)),
                            .just(.selectStore(index: index))
                        ])
                    } else {
                        return .error(BaseError.unknown)
                    }
                    
                case .advertisement(_):
                    return .just(.selectStore(index: index))
                    
                case .empty:
                    return .empty()
                }
            }
            
        case .tapVisitButton(let index):
            let selectedStoreCell = self.currentState.storeCellTypes[index]
            
            if case .store(let store) = selectedStoreCell {
                if let store = store as? Store {
                    return .just(.presentVisit(store: store))
                } else {
                    return .error(BaseError.unknown)
                }
            } else {
                return .error(BaseError.unknown)
            }
            
        case .tapMarker(let index):
            let selectedStoreCell = self.currentState.storeCellTypes[index]
            
            if case .store(let store) = selectedStoreCell {
                if let store = store as? Store {
                    let location = CLLocation(
                        latitude: store.latitude,
                        longitude: store.longitude
                    )
                    return .merge([
                        .just(.setCameraPosition(location)),
                        .just(.selectStore(index: index))
                    ])
                } else if let bossStore = store as? BossStore,
                          let latitude = bossStore.location?.latitude,
                          let longitude = bossStore.location?.longitude {
                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    
                    return .merge([
                        .just(.setCameraPosition(location)),
                        .just(.selectStore(index: index))
                    ])
                } else {
                    return .empty()
                }
            } else {
                return .just(.selectStore(index: index))
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setStoreType(let storeType):
            newState.storeType = storeType
            
        case .setStoreCellTypes(let storeCellTypes):
            newState.storeCellTypes = storeCellTypes
            
        case .setCategories(let categories):
            newState.categories = categories
            
        case .setCurrentLocation(let currentLocation):
            newState.currentLocation = currentLocation
            
        case .setAddressText(let address):
            newState.address = address
            
        case .setMaxDistance(let maxDistance):
            newState.mapMaxDistance = maxDistance
            
        case .setCameraPosition(let location):
            newState.cameraPosition = location
            
        case .selectStore(let index):
            newState.selectedIndex = index
            
        case .updateStore(let store):
            for index in newState.storeCellTypes.indices {
                if case .store = newState.storeCellTypes[index] {
                    newState.storeCellTypes[index] = StoreCellType.store(store)
                }
            }
            
        case .setHiddenResearchButton(let isHidden):
            newState.isHiddenResearchButton = isHidden
            
        case .presentVisit(let store):
            self.presentVisitPublisher.accept(store)
            
        case .pushStoreDetail(let storeId):
            self.pushStoreDetailPublisher.accept(storeId)
            
        case .pushBossStoreDetail(let storeId):
            self.pushBossStoreDetailPublisher.accept(storeId)
            
        case .pushWebView(let url):
            self.openURLPublisher.accept(url)
            
        case .showLoading(let isShow):
            self.showLoadingPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
    
    private func refreshCurrentLocation() -> Observable<Mutation> {
        return self.locationManager.getCurrentLocation()
            .flatMap { [weak self] currentLocation -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                if self.currentState.storeType == .streetFood {
                    return .merge([
                        .just(.setCurrentLocation(currentLocation)),
                        .just(.setCameraPosition(currentLocation)),
                        self.searchNearStores(
                            categoryId: self.currentState.selectedCategory?.id,
                            distance: self.currentState.mapMaxDistance,
                            currentLocation: currentLocation,
                            mapLocation: currentLocation
                        ),
                        self.fetchAddressFromLocation(location: currentLocation)
                    ])
                } else {
                    return .merge([
                        .just(.setCurrentLocation(currentLocation)),
                        .just(.setCameraPosition(currentLocation)),
                        self.searchNearBossStore(
                            categoryId: self.currentState.selectedCategory?.id,
                            distance: self.currentState.mapMaxDistance,
                            currentLocation: currentLocation,
                            mapLocation: currentLocation
                        ),
                        self.fetchAddressFromLocation(location: currentLocation)
                    ])
                }
            }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func searchNearStores(
        categoryId: String?,
        distance: Double?,
        currentLocation: CLLocation,
        mapLocation: CLLocation
    ) -> Observable<Mutation> {
        let searchNearStores = self.storeService.searchNearStores(
            categoryId: categoryId,
            distance: distance,
            currentLocation: currentLocation,
            mapLocation: mapLocation,
            orderType: .distance
        )
        let fetchAdvertisement = self.fetchAdvertisement()
        
        return Observable.zip(searchNearStores, fetchAdvertisement)
            .flatMap { [weak self] stores, advertisement -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                let storeCellTypes = self.toStoreCellTypes(
                    stores: stores,
                    advertisement: advertisement
                )
                
                return .just(.setStoreCellTypes(storeCellTypes))
            }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func searchNearBossStore(
        categoryId: String?,
        distance: Double?,
        currentLocation: CLLocation,
        mapLocation: CLLocation
    ) -> Observable<Mutation> {
        let searchNearBossStore = self.storeService.searchNearBossStores(
            categoryId: categoryId,
            distance: distance,
            currentLocation: currentLocation,
            mapLocation: mapLocation,
            orderType: .distance
        )
        let fetchAdvertisement = self.fetchAdvertisement()
        
        return Observable.zip(searchNearBossStore, fetchAdvertisement)
            .flatMap { [weak self] stores, advertisement -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                let storeCellTypes = self.toStoreCellTypes(
                    stores: stores,
                    advertisement: advertisement
                )
                
                return .just(.setStoreCellTypes(storeCellTypes))
            }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func fetchStreedFoodCategories() -> Observable<[Categorizable]> {
        return self.categoryService.fetchStreetFoodCategories()
    }
    
    private func fetchAdvertisement() -> Observable<Advertisement?> {
        return self.advertisementService
            .fetchAdvertisements(position: .mainPageCard)
            .map { $0.map(Advertisement.init(response:)).first }
    }
    
    private func fetchAddressFromLocation(location: CLLocation?) -> Observable<Mutation> {
        guard let location = location else {
            let error = BaseError.custom("올바르지 않은 위치 입니다.")
            
            return .just(.showErrorAlert(error))
        }
        
        return self.mapService.getAddressFromLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
            .map { .setAddressText(address: $0) }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func getCategories(by storeType: StoreType) -> [Categorizable] {
        if storeType == .streetFood {
            return self.streetFoodCategory
        } else {
            return self.foodTruckCategory
        }
    }
    
    private func toStoreCellTypes(
        stores: [StoreProtocol],
        advertisement: Advertisement?
    ) -> [StoreCellType] {
        var results = stores.map { StoreCellType.store($0) }
        
        if let advertisement = advertisement,
           !results.isEmpty {
            results.insert(StoreCellType.advertisement(advertisement), at: 1)
        }
        
        return results
    }
}
