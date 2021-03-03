import RxSwift
import RxCocoa
import CoreLocation


class HomeViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  let storeService: StoreServiceProtocol
  let mapService: MapServiceProtocol
  
  var selectedIndex: Int = 0
  var stores: [StoreResponse] = [] {
    didSet {
      self.output.isHiddenEmptyCell.accept(!stores.isEmpty)
      self.output.stores.accept(stores)
    }
  }
  
  struct Input {
    let currentLocation = PublishSubject<CLLocation>()
    let mapLocation = BehaviorSubject<CLLocation?>(value: nil)
    let locationForAddress = PublishSubject<(Double, Double)>()
    let tapResearch = PublishSubject<Void>()
    let selectStore = PublishSubject<Int>()
    let tapStore = PublishSubject<Int>()
    let deselectCurrentStore = PublishSubject<Void>()
  }
  
  struct Output {
    let address = PublishRelay<String>()
    let stores = PublishRelay<[StoreResponse]>()
    let isHiddenResearchButton = PublishRelay<Bool>()
    let isHiddenEmptyCell = PublishRelay<Bool>()
    let scrollToIndex = PublishRelay<IndexPath>()
    let setSelectStore = PublishRelay<(IndexPath, Bool)>()
    let selectMarker = PublishRelay<(Int, [StoreResponse])>()
    let goToDetail = PublishRelay<Int>()
    let showLoading = PublishRelay<Bool>()
  }
  
  
  init(
    storeService: StoreServiceProtocol,
    mapService: MapServiceProtocol
  ) {
    self.storeService = storeService
    self.mapService = mapService
    super.init()
    
    self.input.currentLocation
      .withLatestFrom(self.input.mapLocation) { ($0, $1) }
      .bind(onNext: self.searchNearStores)
      .disposed(by: disposeBag)
    
    self.input.mapLocation
      .map { _ in false }
      .bind(to: self.output.isHiddenResearchButton)
      .disposed(by: disposeBag)
      
    
    self.input.locationForAddress
      .bind(onNext: self.getAddressFromLocation)
      .disposed(by: disposeBag)
    
    self.input.tapResearch
      .withLatestFrom(Observable.combineLatest(self.input.currentLocation, self.input.mapLocation)) { ($1.0, $1.1) }
      .bind(onNext: self.searchNearStores)
      .disposed(by: disposeBag)
    
    self.input.selectStore
      .map { $0 >= self.stores.count ? self.stores.count - 1 : $0 }
      .bind(onNext: self.onSelectStore(index:))
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
    mapLocation: CLLocation?
  ) {
    self.output.showLoading.accept(true)
    self.storeService.searchNearStores(
      currentLocation: currentLocation,
      mapLocation: mapLocation == nil ? currentLocation : mapLocation!
    ).subscribe(
      onNext: { [weak self] stores in
        guard let self = self else { return }
        self.stores = stores
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          self.onSelectStore(index: 0)
        }
        self.output.showLoading.accept(false)
        self.output.isHiddenResearchButton.accept(true)
      },
      onError: { [weak self] error in
        guard let self = self else { return }
        if let httpError = error as? HTTPError{
          self.httpErrorAlert.accept(httpError)
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
  
  private func onSelectStore(index: Int){
    self.output.scrollToIndex.accept(IndexPath(row: index, section: 0))
    self.output.selectMarker.accept((index, self.stores))
    self.output.setSelectStore.accept((IndexPath(row: self.selectedIndex, section: 0), false))
    self.output.setSelectStore.accept((IndexPath(row: index, section: 0), true))
    self.selectedIndex = index
  }
  
  private func onTapStore(index: Int) {
    if selectedIndex == index {
      GA.shared.logEvent(event: .store_card_button_clicked, page: .home_page)
      self.output.goToDetail.accept(self.stores[index].id)
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
