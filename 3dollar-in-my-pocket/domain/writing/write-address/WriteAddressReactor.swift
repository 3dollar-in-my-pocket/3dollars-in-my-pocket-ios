import RxSwift
import RxCocoa
import ReactorKit

final class WriteAddressReactor: BaseReactor, Reactor {
    enum Action {
        case moveMapCenter(latitude: Double, longitude: Double)
        case tapCurrentLocation
        case tapSetAddress
    }
    
    enum Mutation {
        case setNearStores(stores: [Store])
        case moveCamera(latitude: Double, longitude: Double)
        case setAddressText(address: String)
        case pushAddressDetail(address: String, location: (Double, Double))
        case showErrorAlert(Error)
    }
    
    struct State {
        var address = ""
        var nearStores: [Store] = []
        var cameraPosition: (Double, Double)?
    }
    
    let initialState = State()
    let pushWriteDetailPublisher = PublishRelay<(String, (Double, Double))>()
    private let mapService: MapServiceProtocol
    private let storeService: StoreServiceProtocol
    private let locationManager: LocationManagerProtocol
    
    init(
        mapService: MapServiceProtocol,
        storeService: StoreServiceProtocol,
        locationManager: LocationManagerProtocol
    ) {
        self.mapService = mapService
        self.storeService = storeService
        self.locationManager = locationManager
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .moveMapCenter(latitude, longitude):
            return .merge([
                self.fetchNearStores(latitude: latitude, longitude: longitude),
                self.fetchAddressFromLocation(latitude: latitude, longitude: longitude)
            ])
            
        case .tapCurrentLocation:
            return self.fetchMyLocation()
            
        case .tapSetAddress:
            return self.isStoreExistedNear()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setNearStores(let stores):
            newState.nearStores = stores
            
        case .moveCamera(let latitude, let longitude):
            newState.cameraPosition = (latitude, longitude)
            
        case .setAddressText(let address):
            newState.address = address
            
        case .pushAddressDetail(let address, let location):
            self.pushWriteDetailPublisher.accept((address, location))
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
    
    private func fetchNearStores(latitude: Double, longitude: Double) -> Observable<Mutation> {
        return .empty()
    }
    
    private func fetchMyLocation() -> Observable<Mutation> {
        return self.locationManager.getCurrentLocation()
            .map { .moveCamera(
                latitude: $0.coordinate.latitude,
                longitude: $0.coordinate.longitude
            ) }
            .catchError { .just(.showErrorAlert($0)) }
    }
    
    private func isStoreExistedNear() -> Observable<Mutation> {
        return .empty()
    }
    
    private func fetchAddressFromLocation(
        latitude: Double,
        longitude: Double
    ) -> Observable<Mutation> {
        return self.mapService.getAddressFromLocation(latitude: latitude, longitude: longitude)
            .map { .setAddressText(address: $0) }
            .catchError { .just(.showErrorAlert($0)) }
    }
}
