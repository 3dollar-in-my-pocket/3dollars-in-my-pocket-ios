import CoreLocation

import RxSwift
import RxCocoa
import ReactorKit

final class StreetFoodListReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapCategory
        case tapCurrentLocationButton
        case changeMapLocation(CLLocation)
        case tapOrderButton(StoreOrder)
        case tapCertificatedButton(isOnlyCertificated: Bool)
        case tapStore(index: Int)
        case tapAdvertisement
    }
    
    enum Mutation {
        case presentCategoryFilter(selectedCategory: StreetFoodCategory)
        case setStores([Store])
        case setAdvertisement(Advertisement?)
        case setCurrentLocation(CLLocation)
        case setCameraPosition(CLLocation)
        case setOrderType(StoreOrder)
        case setOnlyCertificated(isOnlyCertificated: Bool)
        case pushStoreDetail(storeId: Int)
        case pushWebView(url: String)
        case showErrorAlert(Error)
    }
    
    struct State {
        var category: StreetFoodCategory
        var cameraPosition: CLLocation?
        var stores: [Store]
        var advertisement: Advertisement?
        var orderType: StoreOrder
        var isOnlyCertificated: Bool
        var currentLocation: CLLocation
    }
    
    let initialState: State
    let pushStoreDetailPublisher = PublishRelay<Int>()
    let presentCategoryFilterPublisher = PublishRelay<StreetFoodCategory>()
    private let storeService: StoreServiceProtocol
    private let advertisementService: AdvertisementServiceProtocol
    private let locationManager: LocationManagerProtocol
    private let metaContext: MetaContext
    
    init(
        storeService: StoreServiceProtocol,
        advertisementService: AdvertisementServiceProtocol,
        locationManager: LocationManagerProtocol,
        metaContext: MetaContext,
        state: State = State(
            category: StreetFoodCategory.totalCategory,
            cameraPosition: nil,
            stores: [],
            advertisement: nil,
            orderType: .distance,
            isOnlyCertificated: false,
            currentLocation: CLLocation(latitude: 0, longitude: 0)
        )
    ) {
        self.storeService = storeService
        self.locationManager = locationManager
        self.advertisementService = advertisementService
        self.metaContext = metaContext
        
        guard let firstCategory
                = metaContext.streetFoodCategories.first as? StreetFoodCategory else {
            fatalError("Category 정보가 없습니다.")
        }
        
        self.initialState = State(
            category: firstCategory,
            cameraPosition: state.cameraPosition,
            stores: state.stores,
            advertisement: state.advertisement,
            orderType: state.orderType,
            isOnlyCertificated: state.isOnlyCertificated,
            currentLocation: state.currentLocation
        )
        
        super.init()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .merge([
                self.refreshCurrentLocation(),
                self.fetchAdvertisement()
            ])
            
        case .tapCategory:
            return .just(.presentCategoryFilter(selectedCategory: self.currentState.category))
            
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
            var selectedIndex = index
            
            if index >= 2 {
                selectedIndex = self.currentState.advertisement == nil ? index : index + 1
            }
            
            let selectedStore = self.currentState.stores[selectedIndex]
            
            return .just(.pushStoreDetail(storeId: Int(selectedStore.id) ?? 0))
            
        case .tapAdvertisement:
            guard let advertisement = self.currentState.advertisement else { return .empty() }
            
            return .just(.pushWebView(url: advertisement.linkUrl))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .presentCategoryFilter(let selectedCategory):
            self.presentCategoryFilterPublisher.accept(selectedCategory)
            
        case .setStores(let stores):
            newState.stores = stores
            
        case .setAdvertisement(let advertisement):
            newState.advertisement = advertisement
            
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
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func searchNearStores(
        category: StreetFoodCategory,
        currentLocation: CLLocation,
        mapLocation: CLLocation,
        orderType: StoreOrder
    ) -> Observable<Mutation> {
        return self.storeService.searchNearStores(
            categoryId: category.id,
            distance: 1000,
            currentLocation: currentLocation,
            mapLocation: mapLocation,
            orderType: orderType
        )
        .map { stores in
            return stores.map { $0 as? Store ?? Store() }
        }
        .map { .setStores($0) }
    }
    
    private func fetchAdvertisement() -> Observable<Mutation> {
        return self.advertisementService
            .fetchAdvertisements(position: .storeCategoryList)
            .map { $0.map(Advertisement.init(response:)).first }
            .map { .setAdvertisement($0) }
            .catch { .just(.showErrorAlert($0)) }
    }
}
