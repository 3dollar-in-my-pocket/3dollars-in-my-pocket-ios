import CoreLocation

import RxSwift
import RxCocoa
import ReactorKit

final class CategoryListReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapCurrentLocationButton
        case changeMapLocation(CLLocation)
        case tapOrderButton(StoreOrder)
        case tapCertificatedButton(isOnlyCertificated: Bool)
        case tapStore(index: Int)
    }
    
    enum Mutation {
        case setStoreCellTypes([StoreCellType])
        case setStores([Store])
        case setCurrentLocation(CLLocation)
        case setCameraPosition(CLLocation)
        case setOrderType(StoreOrder)
        case setOnlyCertificated(isOnlyCertificated: Bool)
        case pushStoreDetail(storeId: Int)
        case pushWebView(url: String)
        case showErrorAlert(Error)
    }
    
    struct State {
        var category: StoreCategory
        var cameraPosition: CLLocation?
        var storeCellTypes: [StoreCellType] = []
        var stores: [Store] = []
        var orderType: StoreOrder = .distance
        var isOnlyCertificated = false
        var currentLocation = CLLocation(latitude: 0, longitude: 0)
    }
    
    private let storeService: StoreServiceProtocol
    private let advertisementService: AdvertisementServiceProtocol
    private let locationManager: LocationManagerProtocol
    let initialState: State
    let pushStoreDetailPublisher = PublishRelay<Int>()
    
    init(
        category: StoreCategory,
        storeService: StoreServiceProtocol,
        advertisementService: AdvertisementServiceProtocol,
        locationManager: LocationManagerProtocol
    ) {
        self.initialState = State(category: category)
        self.storeService = storeService
        self.locationManager = locationManager
        self.advertisementService = advertisementService
        
        super.init()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return self.refreshCurrentLocation()
            
        case .tapCurrentLocationButton:
            return self.refreshCurrentLocation()
            
        case .changeMapLocation(let mapLocation):
            return .merge([
                .just(.setCameraPosition(mapLocation)),
                self.searchNearStores(
                    category: self.currentState.category,
                    currentLocation: self.currentState.currentLocation,
                    mapLocation: mapLocation,
                    orderType: self.currentState.orderType
                )
            ])
            
        case .tapOrderButton(let orderType):
            return .merge([
                .just(.setOrderType(orderType)),
                self.searchNearStores(
                    category: self.currentState.category,
                    currentLocation: self.currentState.currentLocation,
                    mapLocation:
                        self.currentState.cameraPosition ?? self.currentState.currentLocation,
                    orderType: orderType
                )
            ])
            
        case .tapCertificatedButton(let isOnlyCertificated):
            return .just(.setOnlyCertificated(isOnlyCertificated: isOnlyCertificated))
            
        case .tapStore(let index):
            let selectedStore = self.currentState.storeCellTypes[index]
            
            switch selectedStore {
            case .store(let store):
                return .just(.pushStoreDetail(storeId: store.storeId))
                
            case .advertisement(let advertisement):
                return .just(.pushWebView(url: advertisement.linkUrl))
                
            case .empty:
                return .empty()
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setStoreCellTypes(let storeCellTypes):
            newState.storeCellTypes = storeCellTypes
            
        case .setStores(let stores):
            newState.stores = stores
            
        case .setCurrentLocation(let location):
            newState.currentLocation = location
            
        case .setCameraPosition(let position):
            newState.cameraPosition = position
            
        case .setOrderType(let orderType):
            newState.orderType = orderType
            
        case .setOnlyCertificated(let isOnlyCertificated):
            newState.isOnlyCertificated = isOnlyCertificated
            
        case .pushStoreDetail(let storeId):
            self.pushStoreDetailPublisher.accept(storeId)
            
        case .pushWebView(let url):
            self.openURLPublisher.accept(url)
            
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
                        category: self.currentState.category,
                        currentLocation: currentLocation,
                        mapLocation: currentLocation,
                        orderType: self.currentState.orderType
                    )
                ])
            }
            .catchError { .just(.showErrorAlert($0)) }
    }
    
    private func searchNearStores(
        category: StoreCategory,
        currentLocation: CLLocation,
        mapLocation: CLLocation,
        orderType: StoreOrder
    ) -> Observable<Mutation> {
        let searchNearStores = self.storeService.searchNearStores(
            currentLocation: currentLocation,
            mapLocation: mapLocation,
            distance: 1000,
            category: category,
            orderType: orderType
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
    
    private func fetchAdvertisement() -> Observable<Advertisement?> {
        return self.advertisementService
            .fetchAdvertisements(position: .storeCategoryList)
            .map { $0.map(Advertisement.init(response:)).first }
    }
}
