import RxSwift
import RxCocoa
import CoreLocation

class HomeViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  let storeService: StoreServiceProtocol
  let mapService: MapServiceProtocol
  let userDefaults: UserDefaultsUtil
  
  var selectedIndex: Int = -1
  var stores: [Store] = [] {
    didSet {
      self.output.isHiddenEmptyCell.accept(!stores.isEmpty)
      self.output.stores.accept(stores)
    }
  }
  
  struct Input {
    let currentLocation = PublishSubject<CLLocation>()
    let mapMaxDistance = BehaviorSubject<Double>(value: 2000)
    let mapLocation = BehaviorSubject<CLLocation?>(value: nil)
    let locationForAddress = PublishSubject<(Double, Double)>()
    let tapResearch = PublishSubject<Void>()
    let selectStore = PublishSubject<Int>()
    let backFromDetail = PublishSubject<Store>()
    let tapStore = PublishSubject<Int>()
    let tapStoreVisit = PublishSubject<Int>()
    let deselectCurrentStore = PublishSubject<Void>()
  }
  
  struct Output {
    let address = PublishRelay<String>()
    let stores = PublishRelay<[Store]>()
    let isHiddenResearchButton = PublishRelay<Bool>()
    let isHiddenEmptyCell = PublishRelay<Bool>()
    let scrollToIndex = PublishRelay<IndexPath>()
    let setSelectStore = PublishRelay<(IndexPath, Bool)>()
    let selectMarker = PublishRelay<(Int, [Store])>()
    let goToDetail = PublishRelay<Int>()
    let presentVisit = PublishRelay<Store>()
  }
  
  
  init(
    storeService: StoreServiceProtocol,
    mapService: MapServiceProtocol,
    userDefaults: UserDefaultsUtil
  ) {
    self.storeService = storeService
    self.mapService = mapService
    self.userDefaults = userDefaults
    super.init()
    
    self.input.currentLocation
      .do(onNext: self.userDefaults.setUserCurrentLocation(location:))
      .withLatestFrom(
        Observable.combineLatest(self.input.mapLocation, self.input.mapMaxDistance)
      ) { ($0, $1.0, $1.1) }
      .bind(onNext: self.searchNearStores)
      .disposed(by: self.disposeBag)
    
    self.input.mapLocation
      .filter { $0 != nil }
      .map { _ in false }
      .bind(to: self.output.isHiddenResearchButton)
      .disposed(by: self.disposeBag)
    
    self.input.locationForAddress
      .bind(onNext: self.getAddressFromLocation)
      .disposed(by: self.disposeBag)
    
    self.input.tapResearch
      .withLatestFrom(Observable.combineLatest(
        self.input.currentLocation,
        self.input.mapLocation,
        self.input.mapMaxDistance
      ))
      .bind(onNext: { [weak self] (currentLocation, mapLocation, mapMaxDistance) in
        guard let self = self else { return }
        self.selectedIndex = -1
        if let mapLocation = mapLocation {
          self.getAddressFromLocation(
            lat: mapLocation.coordinate.latitude,
            lng: mapLocation.coordinate.longitude
          )
        }
        self.searchNearStores(
          currentLocation: currentLocation,
          mapLocation: mapLocation,
          distance: mapMaxDistance
        )
      })
      .disposed(by: self.disposeBag)
    
    self.input.selectStore
      .map { $0 >= self.stores.count ? self.stores.count - 1 : $0 }
      .bind(onNext: self.onSelectStore(index:))
      .disposed(by: disposeBag)
    
    self.input.backFromDetail
      .filter { _ in self.selectedIndex >= 0 }
      .map { (self.selectedIndex, $0) }
      .bind(onNext: self.updateStore)
      .disposed(by: disposeBag)
    
    self.input.tapStore
      .bind(onNext: self.onTapStore(index:))
      .disposed(by: disposeBag)
    
    self.input.tapStoreVisit
      .compactMap { [weak self] index in
        return self?.stores[index]
      }
      .bind(to: self.output.presentVisit)
      .disposed(by: self.disposeBag)
    
    self.input.deselectCurrentStore
      .bind(onNext: self.deselectStore)
      .disposed(by: disposeBag)
  }
  
  private func searchNearStores(
    currentLocation: CLLocation,
    mapLocation: CLLocation?,
    distance: Double
  ) {
    self.showLoading.accept(true)
    self.storeService.searchNearStores(
      currentLocation: currentLocation,
      mapLocation: mapLocation == nil ? currentLocation : mapLocation!,
      distance: distance,
      category: nil,
      orderType: nil
    )
      .subscribe(
        onNext: { [weak self] stores in
          guard let self = self else { return }
          self.selectedIndex = -1
          self.stores = stores
          self.output.selectMarker.accept((self.selectedIndex, stores))
          self.output.isHiddenResearchButton.accept(true)
          self.showLoading.accept(false)
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          
          self.showErrorAlert.accept(error)
          self.showLoading.accept(false)
        }
      )
      .disposed(by: disposeBag)
  }
  
  private func getAddressFromLocation(lat: Double, lng: Double) {
    self.mapService.getAddressFromLocation(lat: lat, lng: lng)
      .subscribe(
        onNext: self.output.address.accept(_:),
        onError: self.showErrorAlert.accept(_:)
      )
      .disposed(by: disposeBag)
  }
  
  private func updateStore(index: Int, store: Store) {
    self.stores[index] = store
    self.output.setSelectStore.accept((IndexPath(row: index, section: 0), true))
  }
  
  private func onSelectStore(index: Int) {
    self.output.scrollToIndex.accept(IndexPath(row: index, section: 0))
    self.output.selectMarker.accept((index, self.stores))
    self.output.setSelectStore.accept((IndexPath(row: self.selectedIndex, section: 0), false))
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
      self?.output.setSelectStore.accept((IndexPath(row: index, section: 0), true))
    }
    self.selectedIndex = index
  }
  
  private func onTapStore(index: Int) {
    if selectedIndex == index {
      GA.shared.logEvent(event: .store_card_button_clicked, page: .home_page)
      self.output.goToDetail.accept(self.stores[index].storeId)
    } else {
      self.onSelectStore(index: index)
    }
  }
  
  private func deselectStore() {
    let indexPath = IndexPath(row: self.selectedIndex, section: 0)
    
    self.output.setSelectStore.accept((indexPath, false))
  }
}
