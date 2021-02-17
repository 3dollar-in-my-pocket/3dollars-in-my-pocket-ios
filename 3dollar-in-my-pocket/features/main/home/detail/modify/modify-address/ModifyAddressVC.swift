import UIKit
import RxSwift
import NMapsMap

protocol ModifyAddressDelegate: class {
  func onModifyAddress(address: String, location: (Double, Double))
}

class ModifyAddressVC: BaseVC {
  
  private lazy var modifyAddressView = ModifyAddressView(frame: self.view.frame)
  private let viewModel: ModifyAddressViewModel
  private let locationManager = CLLocationManager()
  weak var delegate: ModifyAddressDelegate?
  
  init(store: Store) {
    self.viewModel = ModifyAddressViewModel(
      store: store,
      mapService: MapService()
    )
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(store: Store) -> ModifyAddressVC {
    return  ModifyAddressVC(store: store)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = modifyAddressView
    
    self.setupMap()
    self.setupLocationManager()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.viewModel.fetchLocation()
  }
  
  override func bindViewModel() {
    // Bind input
    self.modifyAddressView.addressButton.rx.tap
      .bind(to: self.viewModel.input.tapSetAddressButton)
      .disposed(by: disposeBag)
    
    // Bind output
    self.viewModel.output.addressText
      .bind(to: self.modifyAddressView.addressLabel.rx.text)
      .disposed(by: disposeBag)
    
    self.viewModel.output.moveCamera
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.modifyAddressView.moveCamera)
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToModify
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.popVC)
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.modifyAddressView.backButton.rx.tap
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.popVC)
      .disposed(by: disposeBag)
    
    self.modifyAddressView.currentLocationButton.rx.tap
      .bind(onNext: self.locationManager.startUpdatingLocation)
      .disposed(by: disposeBag)
  }
  
  private func dismiss() {
    self.dismiss(animated: true, completion: nil)
  }
  
  private func setupMap() {
    self.modifyAddressView.mapView.positionMode = .direction
    self.modifyAddressView.mapView.zoomLevel = 17
    self.modifyAddressView.mapView.addCameraDelegate(delegate: self)
  }
  
  private func setupLocationManager() {
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
  }
  
  private func popVC(address: String, location: (Double, Double)) {
    self.navigationController?.popViewController(animated: true)
    self.delegate?.onModifyAddress(address: address, location: location)
  }
  
  private func popVC() {
    self.navigationController?.popViewController(animated: true)
  }
}

extension ModifyAddressVC: NMFMapViewCameraDelegate {
  
  func mapViewCameraIdle(_ mapView: NMFMapView) {
    let currentPosition = (mapView.cameraPosition.target.lat, mapView.cameraPosition.target.lng)
    
    self.viewModel.input.currentPosition.onNext(currentPosition)
  }
}

extension ModifyAddressVC: CLLocationManagerDelegate {
  
  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    locationManager.stopUpdatingLocation()
    if let latitude = locations.last?.coordinate.latitude,
       let longitude = locations.last?.coordinate.longitude {
      self.viewModel.input.currentPosition.onNext((latitude, longitude))
      self.modifyAddressView.moveCamera(latitude: latitude, longitude: longitude)
    }
  }
}

