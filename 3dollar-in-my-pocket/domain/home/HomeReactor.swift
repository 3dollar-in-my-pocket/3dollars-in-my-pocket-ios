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
        case updateStore(store: Store)
        case tapStore(index: Int)
        case tapVisitButton(index: Int)
        case tapMarker(index: Int)
    }
    
    enum Mutation {
        case setCategories([Categorizable])
        case setStoreCellTypes([StoreCellType])
        case setStoreType(StoreType)
        case setCurrentLocation(CLLocation)
        case setAddressText(address: String)
        case setMaxDistance(Double)
        case setCameraPosition(CLLocation)
        case selectStore(index: Int?)
        case updateStore(index: Int, store: Store)
        case setHiddenResearchButton(Bool)
        case presentVisit(store: Store)
        case pushStoreDetail(storeId: Int)
        case pushWebView(url: String)
        case showLoading(Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var storeType: StoreType = .streetFood
        var categories: [Categorizable] = []
        var storeCellTypes: [StoreCellType] = []
        var address = ""
        var isHiddenResearchButton = true
        var selectedIndex: Int?
        var mapMaxDistance: Double = 2000
        var cameraPosition: CLLocation?
        var currentLocation = CLLocation(latitude: 0, longitude: 0)
    }
    
    let initialState = State()
    let pushStoreDetailPublisher = PublishRelay<Int>()
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
        userDefaults: UserDefaultsUtil
    ) {
        self.storeService = storeService
        self.categoryService = categoryService
        self.advertisementService = advertisementService
        self.locationManager = locationManager
        self.mapService = mapService
        self.userDefaults = userDefaults
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
            
            return .merge([
                .just(.setStoreType(toggleStoreType)),
                .just(.setCategories(toggleCateogires))
            ])
            
        case .searchByAddress(let location, let address):
            return .concat([
                .just(.setCameraPosition(location)),
                .just(.setAddressText(address: address)),
                self.searchNearStores(
                    currentLocation: self.currentState.currentLocation,
                    mapLocation: self.currentState.cameraPosition,
                    distance: self.currentState.mapMaxDistance
                )
            ])
            
        case .tapResearchButton:
            return .concat([
                .just(.showLoading(true)),
                self.searchNearStores(
                    currentLocation: self.currentState.currentLocation,
                    mapLocation: self.currentState.cameraPosition,
                    distance: self.currentState.mapMaxDistance
                ),
                self.fetchAddressFromLocation(location: self.currentState.cameraPosition),
                .just(.selectStore(index: nil)),
                .just(.setHiddenResearchButton(true)),
                .just(.showLoading(false))
            ])
            
        case .tapCurrentLocationButton:
            return .concat([
                .just(.showLoading(true)),
                self.refreshCurrentLocation(),
                .just(.showLoading(false))
            ])
            
        case .selectStore(let index):
            let selectedStore = self.currentState.storeCellTypes[index]
            
            if case .store(let store) = selectedStore {
                let location = CLLocation(
                    latitude: store.latitude,
                    longitude: store.longitude
                )
                return .merge([
                    .just(.setCameraPosition(location)),
                    .just(.selectStore(index: index))
                ])
            } else {
                return .just(.selectStore(index: index))
            }
            
        case .updateStore(let store):
            return self.updateStore(store: store)
            
        case .tapStore(let index):
            let selectedStore = self.currentState.storeCellTypes[index]
            
            if self.currentState.selectedIndex == index {
                switch selectedStore {
                case .store(let store):
                    return .just(.pushStoreDetail(storeId: store.storeId))
                    
                case .advertisement(let advertisement):
                    return .just(.pushWebView(url: advertisement.linkUrl))
                    
                case .empty:
                    return .empty()
                }
            } else {
                if case .store(let store) = selectedStore {
                    let location = CLLocation(
                        latitude: store.latitude,
                        longitude: store.longitude
                    )
                    return .merge([
                        .just(.setCameraPosition(location)),
                        .just(.selectStore(index: index))
                    ])
                } else {
                    return .just(.selectStore(index: index))
                }
            }
            
        case .tapVisitButton(let index):
            if let selectedStore = self.currentState.storeCellTypes[index].value as? Store {
                return .just(.presentVisit(store: selectedStore))
            } else {
                return .empty()
            }
            
        case .tapMarker(let index):
            let selectedStore = self.currentState.storeCellTypes[index]
            
            if case .store(let store) = selectedStore {
                let location = CLLocation(
                    latitude: store.latitude,
                    longitude: store.longitude
                )
                return .merge([
                    .just(.setCameraPosition(location)),
                    .just(.selectStore(index: index))
                ])
            } else {
                return .just(.selectStore(index: index))
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setCategories(let categories):
            newState.categories = categories
            
        case .setStoreCellTypes(let storeCellTypes):
            newState.storeCellTypes = storeCellTypes
            
        case .setStoreType(let storeType):
            newState.storeType = storeType
            
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
            
        case .updateStore(let index, let store):
            newState.storeCellTypes[index] = .store(store)
            
        case .setHiddenResearchButton(let isHidden):
            newState.isHiddenResearchButton = isHidden
            
        case .presentVisit(let store):
            self.presentVisitPublisher.accept(store)
            
        case .pushStoreDetail(let storeId):
            self.pushStoreDetailPublisher.accept(storeId)
            
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
                
                return .merge([
                    .just(.setCurrentLocation(currentLocation)),
                    .just(.setCameraPosition(currentLocation)),
                    self.searchNearStores(
                        currentLocation: currentLocation,
                        mapLocation: nil,
                        distance: self.currentState.mapMaxDistance
                    ),
                    self.fetchAddressFromLocation(location: currentLocation)
                ])
            }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func searchNearStores(
        currentLocation: CLLocation,
        mapLocation: CLLocation?,
        distance: Double
    ) -> Observable<Mutation> {
        let searchNearStores = self.storeService.searchNearStores(
            currentLocation: currentLocation,
            mapLocation: mapLocation == nil ? currentLocation : mapLocation!,
            distance: distance,
            category: nil,
            orderType: nil
        )
            .map { $0.map(Store.init) }
            .map { stores in
                return stores.isEmpty
                ? [StoreCellType.empty]
                : stores.map(StoreCellType.store)
            }
        let fetchAdvertisement = self.fetchAdvertisement()
        
        return Observable.zip(searchNearStores, fetchAdvertisement)
            .map { stores, advertisement -> [StoreCellType] in
                var storeCellTypes = stores
                
                if let advertisement = advertisement {
                    storeCellTypes.insert(StoreCellType.advertisement(advertisement), at: 1)
                }
                return storeCellTypes
            }
            .map { .setStoreCellTypes($0) }
            .catchError { .just(.showErrorAlert($0)) }
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
            .catchError { .just(.showErrorAlert($0)) }
    }
    
    private func updateStore(store: Store) -> Observable<Mutation> {
        for index in self.currentState.storeCellTypes.indices {
            if case .store(let currentStore) = self.currentState.storeCellTypes[index] {
                if store == currentStore {
                    return .just(.updateStore(index: index, store: store))
                }
            }
        }
        return .empty()
    }
    
    private func getCategories(by storeType: StoreType) -> [Categorizable] {
        if storeType == .streetFood {
            return self.streetFoodCategory
        } else {
            return self.foodTruckCategory
        }
    }
}
