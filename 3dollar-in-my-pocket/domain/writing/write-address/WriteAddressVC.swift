import UIKit
import RxSwift
import NMapsMap

protocol WriteAddressDelegate: class {
  func onWriteSuccess(storeId: Int)
}

class WriteAddressVC: BaseVC {
  
  private lazy var writeAddressView = WriteAddressView(frame: self.view.frame)
  private let viewModel = WriteAddressViewModel(mapService: MapService())
  private let locationManager = CLLocationManager()
  weak var delegate: WriteAddressDelegate?
  
  static func instance(delegate: WriteAddressDelegate) -> UINavigationController {
    let writeAddressVC = WriteAddressVC(nibName: nil, bundle: nil).then {
      $0.delegate = delegate
      $0.tabBarItem = UITabBarItem(
        title: nil,
        image: UIImage(named: "ic_write"),
        tag: TabBarTag.write.rawValue
      )
    }
    
    return UINavigationController(rootViewController: writeAddressVC).then {
      $0.modalPresentationStyle = .overCurrentContext
      $0.isNavigationBarHidden = true
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = writeAddressView
    
    self.setupMap()
    self.setupLocationManager()
  }
  
  override func bindViewModel() {
    // Bind input
    self.writeAddressView.addressButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .set_address_button_clicked, page: .store_register_address_page)
      })
      .bind(to: self.viewModel.input.tapSetAddressButton)
      .disposed(by: disposeBag)
    
    // Bind output
    self.viewModel.output.addressText
      .bind(to: self.writeAddressView.addressLabel.rx.text)
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToWriteDetail
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToWriteDetail)
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.writeAddressView.closeButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .close_button_clicked, page: .store_register_address_page)
      })
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.dismiss)
      .disposed(by: disposeBag)
    
    self.writeAddressView.currentLocationButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .current_location_button_clicked, page: .store_register_address_page)
      })
      .bind(onNext: self.locationManager.startUpdatingLocation)
      .disposed(by: disposeBag)
  }
  
  private func dismiss() {
    self.dismiss(animated: true, completion: nil)
  }
  
  private func setupMap() {
    self.writeAddressView.mapView.positionMode = .direction
    self.writeAddressView.mapView.zoomLevel = 17
    self.writeAddressView.mapView.addCameraDelegate(delegate: self)
  }
  
  private func setupLocationManager() {
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.startUpdatingLocation()
  }
  
  private func goToWriteDetail(address: String, location: (Double, Double)) {
    let writingDetailVC = WriteDetailVC.instance(
      address: address,
      location: location
    ).then {
      $0.deleagte = self
    }
    
    self.navigationController?.pushViewController(writingDetailVC, animated: true)
  }
}

extension WriteAddressVC: NMFMapViewCameraDelegate {
  
  func mapViewCameraIdle(_ mapView: NMFMapView) {
    let currentPosition = (mapView.cameraPosition.target.lat, mapView.cameraPosition.target.lng)
    
    self.viewModel.input.currentPosition.onNext(currentPosition)
  }
}

extension WriteAddressVC: WriteDetailDelegate {
  
  func onWriteSuccess(storeId: Int) {
    self.delegate?.onWriteSuccess(storeId: storeId)
  }
}

extension WriteAddressVC: CLLocationManagerDelegate {
  
  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    locationManager.stopUpdatingLocation()
    if let latitude = locations.last?.coordinate.latitude,
       let longitude = locations.last?.coordinate.longitude {
      self.viewModel.input.currentPosition.onNext((latitude, longitude))
      self.writeAddressView.moveCamera(latitude: latitude, longitude: longitude)
    }
  }
}

