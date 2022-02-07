import CoreLocation

import RxSwift
import RxCocoa
import ReactorKit
import MapKit

final class HomeReactor: BaseReactor, Reactor {
    enum Action {
        case changeMaxDistance(maxDistance: Double)
        case changeMapLocation(CLLocation)
        case searchByAddress(location: CLLocation, address: String)
        case tapResearchButton
        case tapCurrentLocationButton
        case tapStore(index: Int)
        case tapVisitButton(index: Int)
        case tapMarker(index: Int)
    }
    
    enum Mutation {
        case setStoreCellTypes([StoreCellType])
        case setCurrentLocation(CLLocation)
        case setAddressText(address: String)
        case setMaxDistance(Double)
        case setCameraPosition(CLLocation)
        case selectStore(index: Int)
        case setHiddenResearchButton(Bool)
        case presentVisit(store: Store)
        case pushStoreDetail(storeId: Int)
        case pushWebView(url: String)
        case showLoading(Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var storeCellTypes: [StoreCellType] = []
        var address = ""
        var isHiddenResearchButton = true
        var selectedIndex: Int?
        var mapMaxDistance: Double = 2000
        var cameraPosition: CLLocation?
        var currentLocation = CLLocation(latitude: 0, longitude: 0)
    }
    
    //  var selectedIndex: Int = -1
    //  var stores: [Store] = [] {
    //    didSet {
    //      self.output.isHiddenEmptyCell.accept(!stores.isEmpty)
    //      self.output.stores.accept(stores)
    //    }
    //  }
    //
    //  struct Input {
    //    let currentLocation = PublishSubject<CLLocation>()
    //    let mapMaxDistance = BehaviorSubject<Double>(value: 2000)
    //    let mapLocation = BehaviorSubject<CLLocation?>(value: nil)
    //    let locationForAddress = PublishSubject<(Double, Double)>()
    //    let tapResearch = PublishSubject<Void>()
    //    let selectStore = PublishSubject<Int>()
    //    let backFromDetail = PublishSubject<Store>()
    //    let tapStore = PublishSubject<Int>()
    //    let tapStoreVisit = PublishSubject<Int>()
    //    let deselectCurrentStore = PublishSubject<Void>()
    //    let updateStore = PublishSubject<Store>()
    //  }
    //
    //  struct Output {
    //    let address = PublishRelay<String>()
    //    let stores = PublishRelay<[Store]>()
    //    let isHiddenResearchButton = PublishRelay<Bool>()
    //    let isHiddenEmptyCell = PublishRelay<Bool>()
    //    let scrollToIndex = PublishRelay<IndexPath>()
    //    let setSelectStore = PublishRelay<(IndexPath, Bool)>()
    //    let selectMarker = PublishRelay<(Int, [Store])>()
    //    let goToDetail = PublishRelay<Int>()
    //    let presentVisit = PublishRelay<Store>()
    //  }
    
    let initialState = State()
    let pushStoreDetailPublisher = PublishRelay<Int>()
    let presentVisitPublisher = PublishRelay<Store>()
    private let storeService: StoreServiceProtocol
    private let locationManager: LocationManagerProtocol
    private let mapService: MapServiceProtocol
    private let userDefaults: UserDefaultsUtil
  
    
    init(
        storeService: StoreServiceProtocol,
        locationManager: LocationManagerProtocol,
        mapService: MapServiceProtocol,
        userDefaults: UserDefaultsUtil
    ) {
        self.storeService = storeService
        self.locationManager = locationManager
        self.mapService = mapService
        self.userDefaults = userDefaults
        super.init()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changeMaxDistance(let maxDistance):
            return .merge([
                .just(.setHiddenResearchButton(false)),
                .just(.setMaxDistance(maxDistance))
            ])
            
        case .changeMapLocation(let mapLocation):
            return .merge([
                .just(.setHiddenResearchButton(false)),
                .just(.setCameraPosition(mapLocation))
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
                .just(.showLoading(false))
            ])
            
        case .tapCurrentLocationButton:
            return .concat([
                .just(.showLoading(true)),
                self.refreshCurrentLocation(),
                .just(.showLoading(false))
            ])
            
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
                return .just(.selectStore(index: index))
            }
            
        case .tapVisitButton(let index):
            if let selectedStore = self.currentState.storeCellTypes[index].value as? Store {
                return .just(.presentVisit(store: selectedStore))
            } else {
                return .empty()
            }
            
        case .tapMarker(let index):
            return .just(.selectStore(index: index))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setStoreCellTypes(let storeCellTypes):
            newState.storeCellTypes = storeCellTypes
            
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
//    super.init()
//
//    self.input.currentLocation
//      .do(onNext: self.userDefaults.setUserCurrentLocation(location:))
//      .withLatestFrom(
//        Observable.combineLatest(self.input.mapLocation, self.input.mapMaxDistance)
//      ) { ($0, $1.0, $1.1) }
//      .bind(onNext: self.searchNearStores)
//      .disposed(by: self.disposeBag)
//
//    self.input.mapLocation
//      .filter { $0 != nil }
//      .map { _ in false }
//      .bind(to: self.output.isHiddenResearchButton)
//      .disposed(by: self.disposeBag)
//
//    self.input.locationForAddress
//      .bind(onNext: self.getAddressFromLocation)
//      .disposed(by: self.disposeBag)
//
//    self.input.tapResearch
//      .withLatestFrom(Observable.combineLatest(
//        self.input.currentLocation,
//        self.input.mapLocation,
//        self.input.mapMaxDistance
//      ))
//      .bind(onNext: { [weak self] (currentLocation, mapLocation, mapMaxDistance) in
//        guard let self = self else { return }
//        self.selectedIndex = -1
//        if let mapLocation = mapLocation {
//          self.getAddressFromLocation(
//            lat: mapLocation.coordinate.latitude,
//            lng: mapLocation.coordinate.longitude
//          )
//        }
//        self.searchNearStores(
//          currentLocation: currentLocation,
//          mapLocation: mapLocation,
//          distance: mapMaxDistance
//        )
//      })
//      .disposed(by: self.disposeBag)
//
//    self.input.selectStore
//      .map { $0 >= self.stores.count ? self.stores.count - 1 : $0 }
//      .bind(onNext: self.onSelectStore(index:))
//      .disposed(by: disposeBag)
//
//    self.input.backFromDetail
//      .filter { _ in self.selectedIndex >= 0 }
//      .map { (self.selectedIndex, $0) }
//      .bind(onNext: self.updateStore)
//      .disposed(by: disposeBag)
//
//    self.input.tapStore
//      .bind(onNext: self.onTapStore(index:))
//      .disposed(by: disposeBag)
//
//    self.input.tapStoreVisit
//      .compactMap { [weak self] index in
//        return self?.stores[index]
//      }
//      .bind(to: self.output.presentVisit)
//      .disposed(by: self.disposeBag)
//
//    self.input.deselectCurrentStore
//      .bind(onNext: self.deselectStore)
//      .disposed(by: disposeBag)
//
//    self.input.updateStore
//      .bind { [weak self] store in
//        guard let self = self else { return }
//
//        if let index = self.stores.firstIndex(of: store) {
//          self.stores[index] = store
//        }
//      }
//      .disposed(by: self.disposeBag)
//  }
    
    private func refreshCurrentLocation() -> Observable<Mutation> {
        return self.locationManager.getCurrentLocation()
            .flatMap { [weak self] currentLocation -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                return .merge([
                    .just(.setCurrentLocation(currentLocation)),
                    .just(.setCameraPosition(currentLocation)),
                    self.searchNearStores(
                        currentLocation: currentLocation,
                        mapLocation: self.currentState.cameraPosition,
                        distance: self.currentState.mapMaxDistance
                    ),
                    self.fetchAddressFromLocation(location: currentLocation)
                ])
            }
            .catchError { .just(.showErrorAlert($0)) }
    }
    
    private func searchNearStores(
        currentLocation: CLLocation,
        mapLocation: CLLocation?,
        distance: Double
    ) -> Observable<Mutation> {
        return self.storeService.searchNearStores(
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
            .map { .setStoreCellTypes($0) }
            .catchError { .just(.showErrorAlert($0)) }
    }
//      .subscribe(
//        onNext: { [weak self] stores in
//          guard let self = self else { return }
//          self.selectedIndex = -1
//          self.stores = stores
//          self.output.selectMarker.accept((self.selectedIndex, stores))
//          self.output.isHiddenResearchButton.accept(true)
//          self.showLoading.accept(false)
//        },
//        onError: { [weak self] error in
//          guard let self = self else { return }
//
//          self.showErrorAlert.accept(error)
//
//        }
//      )
//      .disposed(by: disposeBag)
//  }
  
    private func fetchAddressFromLocation(location: CLLocation) -> Observable<Mutation> {
        return self.mapService.getAddressFromLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
            .map { .setAddressText(address: $0) }
            .catchError { .just(.showErrorAlert($0)) }
    }
//
//  private func updateStore(index: Int, store: Store) {
//    self.stores[index] = store
//    self.output.setSelectStore.accept((IndexPath(row: index, section: 0), true))
//  }
//
//  private func onSelectStore(index: Int) {
//    self.output.scrollToIndex.accept(IndexPath(row: index, section: 0))
//    self.output.selectMarker.accept((index, self.stores))
//    self.output.setSelectStore.accept((IndexPath(row: self.selectedIndex, section: 0), false))
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//      self?.output.setSelectStore.accept((IndexPath(row: index, section: 0), true))
//    }
//    self.selectedIndex = index
//  }
//
//  private func onTapStore(index: Int) {
//    if selectedIndex == index {
//      GA.shared.logEvent(event: .store_card_button_clicked, page: .home_page)
//      self.output.goToDetail.accept(self.stores[index].storeId)
//    } else {
//      self.onSelectStore(index: index)
//    }
//  }
//
//  private func deselectStore() {
//    let indexPath = IndexPath(row: self.selectedIndex, section: 0)
//
//    self.output.setSelectStore.accept((indexPath, false))
//  }
}
