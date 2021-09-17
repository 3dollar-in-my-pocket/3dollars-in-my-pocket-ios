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
  var stores: [StoreInfoResponse] = [] {
    didSet {
      self.output.isHiddenEmptyCell.accept(!stores.isEmpty)
      self.output.stores.accept(stores)
    }
  }
  
  struct Input {
    let currentLocation = PublishSubject<CLLocation>()
    let distance = BehaviorSubject<Double>(value: 2000)
    let mapLocation = BehaviorSubject<CLLocation?>(value: nil)
    let locationForAddress = PublishSubject<(Double, Double)>()
    let tapResearch = PublishSubject<Void>()
    let selectStore = PublishSubject<Int>()
    let backFromDetail = PublishSubject<Store>()
    let tapStore = PublishSubject<Int>()
    let deselectCurrentStore = PublishSubject<Void>()
  }
  
  struct Output {
    let address = PublishRelay<String>()
    let stores = PublishRelay<[StoreInfoResponse]>()
    let isHiddenResearchButton = PublishRelay<Bool>()
    let isHiddenEmptyCell = PublishRelay<Bool>()
    let scrollToIndex = PublishRelay<IndexPath>()
    let setSelectStore = PublishRelay<(IndexPath, Bool)>()
    let selectMarker = PublishRelay<(Int, [StoreInfoResponse])>()
    let goToDetail = PublishRelay<Int>()
    let showLoading = PublishRelay<Bool>()
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
      .do(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.selectedIndex = -1
      })
      .withLatestFrom(
        Observable.combineLatest(self.input.mapLocation, self.input.distance)
      ) { ($0, $1.0, $1.1) }
      .bind(onNext: self.searchNearStores)
      .disposed(by: disposeBag)
    
    self.input.mapLocation
      .filter { $0 != nil }
      .map { _ in false }
      .bind(to: self.output.isHiddenResearchButton)
      .disposed(by: disposeBag)
    
    self.input.locationForAddress
      .bind(onNext: self.getAddressFromLocation)
      .disposed(by: disposeBag)
    
    self.input.tapResearch
      .withLatestFrom(Observable.combineLatest(self.input.currentLocation, self.input.mapLocation, self.input.distance)) { ($1.0, $1.1, $1.2) }
      .do(onNext: { [weak self] locations in
        guard let self = self else { return }
        self.selectedIndex = -1
        if let mapLocation = locations.1 {
          self.getAddressFromLocation(
            lat: mapLocation.coordinate.latitude,
            lng: mapLocation.coordinate.longitude
          )
        }
      })
      .bind(onNext: self.searchNearStores)
      .disposed(by: disposeBag)
    
    self.input.selectStore
      .map { $0 >= self.stores.count ? self.stores.count - 1 : $0 }
      .bind(onNext: self.onSelectStore(index:))
      .disposed(by: disposeBag)
    
    self.input.backFromDetail
      .map { (self.selectedIndex, $0) }
      .bind(onNext: self.updateStore)
      .disposed(by: disposeBag)
    
    self.input.tapStore
      .bind(onNext: self.onTapStore(index:))
      .disposed(by: disposeBag)
    
    self.input.deselectCurrentStore
      .bind(onNext: self.deselectStore)
      .disposed(by: disposeBag)
  }
  
  private func searchNearStores(
    currentLocation: CLLocation,
    mapLocation: CLLocation?,
    distance: Double
  ) {
    self.output.showLoading.accept(true)
    self.storeService.searchNearStores(
      currentLocation: currentLocation,
      mapLocation: mapLocation == nil ? currentLocation : mapLocation!,
      distance: distance
    ).subscribe(
      onNext: { [weak self] stores in
        guard let self = self else { return }
        self.stores = stores
        self.output.selectMarker.accept((self.selectedIndex, self.stores))
        self.output.scrollToIndex.accept(IndexPath(row: 0, section: 0))
        self.output.showLoading.accept(false)
        self.output.isHiddenResearchButton.accept(true)
      },
      onError: { [weak self] error in
        guard let self = self else { return }
        if let httpError = error as? HTTPError {
          self.httpErrorAlert.accept(httpError)
        }
        if let commonError = error as? CommonError {
          let alertContent = AlertContent(title: nil, message: commonError.description)
          
          self.showSystemAlert.accept(alertContent)
        }
        self.output.showLoading.accept(false)
      }
    )
    .disposed(by: disposeBag)
  }
  
  private func getAddressFromLocation(lat: Double, lng: Double) {
    self.mapService.getAddressFromLocation(lat: lat, lng: lng)
      .subscribe(
        onNext: self.output.address.accept,
        onError: { error in
          if let httpError = error as? HTTPError {
            self.httpErrorAlert.accept(httpError)
          } else if let error = error as? CommonError {
            let alertContent = AlertContent(title: nil, message: error.description)

            self.showSystemAlert.accept(alertContent)
          }
        }
      )
      .disposed(by: disposeBag)
  }
  
  private func updateStore(index: Int, store: Store) {
    if index >= 0 {
      let newStore = StoreInfoResponse(store: store)
      self.stores[index] = newStore
      self.output.setSelectStore.accept((IndexPath(row: index, section: 0), true))
    }
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
      self.output.scrollToIndex.accept(IndexPath(row: index, section: 0))
      self.output.selectMarker.accept((index, self.stores))
      self.output.setSelectStore.accept((IndexPath(row: self.selectedIndex, section: 0), false))
      self.output.setSelectStore.accept((IndexPath(row: index, section: 0), true))
      self.selectedIndex = index
    }
  }
  
  private func deselectStore() {
    let indexPath = IndexPath(row: self.selectedIndex, section: 0)
    
    self.output.setSelectStore.accept((indexPath, false))
  }
}
