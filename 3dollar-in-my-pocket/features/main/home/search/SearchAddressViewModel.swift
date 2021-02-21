import RxSwift
import RxCocoa
import CoreLocation

class SearchAddressViewModel: BaseViewModel{
  
  let input = Input()
  let output = Output()
  let mapService: MapServiceProtocol
  
  var address: [Document] = [] {
    didSet {
      self.output.addresses.accept(address)
    }
  }
  var currentLocation: (Double, Double) = (0,0)
  
  struct Input {
    let keyword = PublishSubject<String>()
    let tapcurrentLocation = PublishSubject<(Double, Double)>()
    let tapAddress = PublishSubject<Int>()
  }
  
  struct Output {
    let addresses = PublishRelay<[Document]>()
    let hideKeyboard = PublishRelay<Void>()
    let dismiss = PublishRelay<((Double, Double), String)>()
  }
  
  
  init(mapService: MapServiceProtocol) {
    self.mapService = mapService
    super.init()
    
    self.input.keyword
      .filter { !$0.isEmpty }
      .throttle(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
      .bind(onNext: self.searchAddress(keyword:))
      .disposed(by: disposeBag)
    
    self.input.tapcurrentLocation
      .do(onNext: { (lat, lng) in
        self.currentLocation = (lng, lat)
      })
      .bind(onNext: self.getMyLocation)
      .disposed(by: disposeBag)
    
    self.input.tapAddress
      .map { self.address[$0] }
      .bind(onNext: self.selectAddress(document:))
      .disposed(by: disposeBag)
  }
  
  private func searchAddress(keyword: String) {
    self.mapService.searchAddress(keyword: keyword)
      .subscribe(
        onNext: { addressResponse in
          self.address = addressResponse.documents
        },
        onError: { error in
          if let httpError = error as? HTTPError {
            self.httpErrorAlert.accept(httpError)
          }
        }
      )
      .disposed(by: disposeBag)
  }
  
  private func getMyLocation(lat: Double, lng: Double) {
    self.mapService.getCurrentAddress(lat: lat, lng: lng)
      .subscribe(
        onNext: { addressResponse in
          self.address = addressResponse.documents
        },
        onError: { error in
          if let httpError = error as? HTTPError {
            self.httpErrorAlert.accept(httpError)
          }
        }
      )
      .disposed(by: disposeBag)
  }
  
  private func selectAddress(document: Document) {
    if document is PlaceDocument {
      let placeDocument = document as! PlaceDocument
      self.output.dismiss.accept(
        ((Double(placeDocument.y)!, Double(placeDocument.x)!),placeDocument.placeName)
      )
    } else {
      let addressDocument = document as! AddressDocument
      self.output.dismiss.accept((self.currentLocation, addressDocument.roadAddress.buildingName))
    }
  }
}
