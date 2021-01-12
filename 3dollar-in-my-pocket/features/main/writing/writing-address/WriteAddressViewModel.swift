import RxSwift
import RxCocoa

class WriteAddressViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  let mapService: MapServiceProtocol
  
  struct Input {
    let currentPosition = PublishSubject<(Double, Double)>()
    let tapSetAddressButton = PublishSubject<Void>()
  }
  
  struct Output {
    let addressText = PublishRelay<String>()
    let goToWrite = PublishRelay<String>()
  }
  
  
  init(mapService: MapServiceProtocol) {
    self.mapService = mapService
    super.init()
    
    self.input.currentPosition
      .bind(onNext: self.getAddressFromLocation)
      .disposed(by: disposeBag)
  }
  
  private func getAddressFromLocation(lat: Double, lng: Double) {
    self.mapService.getAddressFromLocation(lat: lat, lng: lng)
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
