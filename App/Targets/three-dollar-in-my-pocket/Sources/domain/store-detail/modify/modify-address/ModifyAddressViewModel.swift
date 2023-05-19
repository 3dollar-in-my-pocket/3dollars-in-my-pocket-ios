import RxSwift
import RxCocoa

class ModifyAddressViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  let store: Store
  let mapService: MapServiceProtocol
  
  struct Input {
    let currentPosition = PublishSubject<(Double, Double)>()
    let tapSetAddressButton = PublishSubject<Void>()
  }
  
  struct Output {
    let addressText = PublishRelay<String>()
    let moveCamera = PublishRelay<(Double, Double)>()
    let goToModify = PublishRelay<(String, (Double, Double))>()
  }
  
  
  init(
    store: Store,
    mapService: MapServiceProtocol
  ) {
    self.store = store
    self.mapService = mapService
    super.init()
    
    self.input.currentPosition
      .bind(onNext: self.getAddressFromLocation)
      .disposed(by: disposeBag)
    
    self.input.tapSetAddressButton
      .withLatestFrom(Observable.combineLatest(self.output.addressText, self.input.currentPosition))
      .bind(to: self.output.goToModify)
      .disposed(by: disposeBag)
  }
  
  func fetchLocation() {
    self.getAddressFromLocation(lat: self.store.latitude, lng: self.store.longitude)
    self.output.moveCamera.accept((self.store.latitude, self.store.longitude))
  }
  
  private func getAddressFromLocation(lat: Double, lng: Double) {
    self.mapService.getAddressFromLocation(latitude: lat, longitude: lng)
      .subscribe(
        onNext: self.output.addressText.accept,
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
}
