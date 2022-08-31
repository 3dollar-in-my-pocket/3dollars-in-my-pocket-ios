import CoreLocation

import RxSwift
import RxCocoa
import ReactorKit

final class FoodTruckListReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapCategory
        case tapCurrentLocationButton
        case changeMapLocation(CLLocation)
        case tapOrderButton(BossStoreOrderType)
        case tapStore(index: Int)
        case tapAdvertisement
    }
    
    enum Mutation {
        case presentCategoryFilter(selectedCategory: FoodTruckCategory)
        case setCategory(FoodTruckCategory)
        case setStores([BossStore])
        case setAdvertisement(Advertisement?)
        case setCurrentLocation(CLLocation)
        case setCameraPosition(CLLocation)
        case setOrderType(BossStoreOrderType)
        case pushBossStoreDetail(storeId: String)
        case pushWebView(url: String)
        case showErrorAlert(Error)
    }
    
    struct State {
        var category: FoodTruckCategory
        var cameraPosition: CLLocation?
        var stores: [BossStore]
        var advertisement: Advertisement?
        var orderType: BossStoreOrderType
        var currentLocation: CLLocation
    }
    
    let initialState: State
    let pushBossStoreDetailPublisher = PublishRelay<String>()
    let presentCategoryFilterPublisher = PublishRelay<FoodTruckCategory>()
    private let storeService: StoreServiceProtocol
    private let advertisementService: AdvertisementServiceProtocol
    private let locationManager: LocationManagerProtocol
    private let metaContext: MetaContext
    private let globalState: GlobalState
    
    init(
        storeService: StoreServiceProtocol,
        advertisementService: AdvertisementServiceProtocol,
        locationManager: LocationManagerProtocol,
        metaContext: MetaContext,
        globalState: GlobalState,
        state: State = State(
            category: FoodTruckCategory.totalCategory,
            cameraPosition: nil,
            stores: [],
            advertisement: nil,
            orderType: .distance,
            currentLocation: CLLocation(latitude: 0, longitude: 0)
        )
    ) {
        self.storeService = storeService
        self.locationManager = locationManager
        self.advertisementService = advertisementService
        self.metaContext = metaContext
        self.globalState = globalState
        
        guard let firstCategory
                = metaContext.foodTruckCategories.first as? FoodTruckCategory else {
            fatalError("Category 정보가 없습니다.")
        }
        
        self.initialState = State(
            category: firstCategory,
            cameraPosition: state.cameraPosition,
            stores: state.stores,
            advertisement: state.advertisement,
            orderType: state.orderType,
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
            
        case .tapStore(let index):
            let selectedIndex = self.currentState.advertisement == nil ? index : index - 1
            let selectedStore = self.currentState.stores[selectedIndex]
            
            return .just(.pushBossStoreDetail(storeId: selectedStore.id))
            
        case .tapAdvertisement:
            guard let advertisement = self.currentState.advertisement else { return .empty() }
            
            return .just(.pushWebView(url: advertisement.linkUrl))
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return .merge([
            mutation,
            self.globalState.updateCategoryFilter
                .flatMap { category -> Observable<Mutation> in
                    if let foodTruckCategory = category as? FoodTruckCategory {
                        return .merge([
                            .just(.setCategory(foodTruckCategory)),
                            self.searchNearStores(
                                category: foodTruckCategory,
                                currentLocation: self.currentState.currentLocation,
                                mapLocation: self.currentState.cameraPosition ?? self.currentState.currentLocation,
                                orderType: self.currentState.orderType
                            )
                        ])
                    } else {
                        return .empty()
                    }
                }
        ])
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .presentCategoryFilter(let selectedCategory):
            self.presentCategoryFilterPublisher.accept(selectedCategory)
            
        case .setCategory(let category):
            newState.category = category
            
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
            
        case .pushBossStoreDetail(let storeId):
            self.pushBossStoreDetailPublisher.accept(storeId)
            
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
        category: FoodTruckCategory,
        currentLocation: CLLocation,
        mapLocation: CLLocation,
        orderType: BossStoreOrderType
    ) -> Observable<Mutation> {
        return self.storeService.searchNearBossStores(
            categoryId: category.id,
            distance: 1000,
            currentLocation: currentLocation,
            mapLocation: mapLocation,
            orderType: orderType
        )
        .map { stores in
            return stores.map { $0 as? BossStore ?? BossStore() }
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
