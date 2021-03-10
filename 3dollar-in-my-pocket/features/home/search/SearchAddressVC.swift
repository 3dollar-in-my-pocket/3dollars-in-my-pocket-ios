import RxSwift
import CoreLocation
import FirebaseCrashlytics

protocol SearchAddressDelegate: class {
  func selectAddress(location: (Double, Double), name: String)
}

class SearchAddressVC: BaseVC {
  
  private lazy var searchAddressView = SearchAddressView(frame: self.view.frame)
  private let viewModel = SearchAddressViewModel(mapService: MapService())
  private let locationManager = CLLocationManager()
  weak var delegate: SearchAddressDelegate?
  
  static func instacne() -> SearchAddressVC {
    return SearchAddressVC(nibName: nil, bundle: nil).then {
      $0.modalPresentationStyle = .overCurrentContext
    }
  }
  
  
  deinit {
    self.locationManager.stopUpdatingLocation()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view = searchAddressView
    self.setupTableView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.searchAddressView.showKeyboard()
  }
  
  override func bindViewModel() {
    // Bind input
    self.searchAddressView.addressField.rx.text.orEmpty
      .bind(to: self.viewModel.input.keyword)
      .disposed(by: disposeBag)
    
    // Bind output
    self.viewModel.output.addresses
      .bind(to: self.searchAddressView.addressTableVIew.rx.items(
        cellIdentifier: AddressCell.registerId,
        cellType: AddressCell.self
      )) { row, document, cell in
        if document is PlaceDocument {
          cell.bind(document: document as! PlaceDocument)
        } else {
          cell.bind(document: document as! AddressDocument)
        }
      }
      .disposed(by: disposeBag)
    
    self.viewModel.output.hideKeyboard
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.searchAddressView.hideKeyboard)
      .disposed(by: disposeBag)
    
    self.viewModel.output.dismiss
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.dismissWithAddress)
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.searchAddressView.closeButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .close_button_clicked, page: .search_page)
      })
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.dismiss)
      .disposed(by: disposeBag)
    
    self.searchAddressView.currentLocationButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .current_location_button_clicked, page: .search_page)
      })
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.initilizeLocationManager)
      .disposed(by: disposeBag)
  }
  
  private func setupTableView() {
    self.searchAddressView.addressTableVIew.register(
      AddressCell.self,
      forCellReuseIdentifier: AddressCell.registerId
    )
    self.searchAddressView.addressTableVIew.rx
      .setDelegate(self)
      .disposed(by: disposeBag)
    
    self.searchAddressView.addressTableVIew.rx.itemSelected
      .do(onNext: { _ in
        GA.shared.logEvent(event: .location_item_clicked, page: .search_page)
      })
      .map { $0.row }
      .debug()
      .bind(to: self.viewModel.input.tapAddress)
      .disposed(by: disposeBag)
  }
  
  private func initilizeLocationManager() {
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    
    if CLLocationManager.locationServicesEnabled() {
      switch CLLocationManager.authorizationStatus() {
      case .authorizedAlways, .authorizedWhenInUse:
        self.locationManager.startUpdatingLocation()
      case .notDetermined:
        self.locationManager.requestWhenInUseAuthorization()
      case .denied, .restricted:
        self.showDenyAlert()
      default:
        let alertContent = AlertContent(
          title: "location_unknown_status".localized,
          message: "\(CLLocationManager.authorizationStatus())"
        )
        self.showSystemAlert(alert: alertContent)
        break
      }
    } else {
      Log.debug("위치 기능 활성화 필요!")
    }
  }
  
  private func dismiss() {
    self.dismiss(animated: true, completion: nil)
  }
  
  private func dismissWithAddress(location: (Double, Double), name: String) {
    self.delegate?.selectAddress(location: location, name: name)
    self.dismiss(animated: true, completion: nil)
  }
  
  private func showDenyAlert() {
    AlertUtils.showWithAction(
      title: "location_deny".localized,
      message: "location_deny_description".localized
    ) { action in
      UIControl().sendAction(
        #selector(URLSessionTask.suspend),
        to: UIApplication.shared, for: nil
      )
    }
  }
}

extension SearchAddressVC: UITableViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.searchAddressView.hideKeyboard()
  }
}

extension SearchAddressVC: CLLocationManagerDelegate {
  
  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    switch status {
    case .denied:
      AlertUtils.showWithAction(
        title: "location_deny_title".localized,
        message: "location_deny_description".localized
      ) { action in
        UIControl().sendAction(
          #selector(URLSessionTask.suspend),
          to: UIApplication.shared, for: nil
        )
      }
    case .authorizedAlways, .authorizedWhenInUse:
      self.initilizeLocationManager()
    default:
      break
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if !locations.isEmpty {
      let location = (
        locations.last!.coordinate.latitude,
        locations.last!.coordinate.longitude
      )
      
      self.viewModel.input.tapcurrentLocation.onNext(location)
    }
    locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    if let error = error as? CLError {
      switch error.code {
      case .denied:
        AlertUtils.show(
          controller: self,
          title: "location_deny_title".localized,
          message: "location_deny_description".localized
        )
      case .locationUnknown:
        AlertUtils.show(
          controller: self,
          title: "location_unknown_title".localized,
          message: "location_unknown_description".localized
        )
      default:
        AlertUtils.show(
          controller: self,
          title: "location_unknown_error_title".localized,
          message: "location_unknown_error_description".localized
        )
        Crashlytics.crashlytics().log("location Manager Error(error code: \(error.code.rawValue)")
      }
    }
  }
}

