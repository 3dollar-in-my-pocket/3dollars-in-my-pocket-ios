import RxSwift
import RxCocoa

class WritingAddressViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  struct Input {
    let currentPosition = PublishSubject<(Double, Double)>()
    let tapSetAddressButton = PublishSubject<Void>()
  }
  
  struct Output {
    let addressText = PublishRelay<String>()
    let goToWrite = PublishRelay<String>()
  }
  
  
  override init() {
    super.init()
    
    self.input.currentPosition
      .bind(onNext: self.getAddressFromLocation)
      .disposed(by: disposeBag)
  }
  
  private func getAddressFromLocation(lat: Double, lng: Double) {
    Log.debug("latitude: \(lat), longitude: \(lng)")
  }
}
