import UIKit
import NMapsMap
import GoogleMobileAds
import FirebaseCrashlytics
import AppTrackingTransparency
import AdSupport

class CategoryListVC: BaseVC {
  
  private lazy var categoryListView = CategoryListView(frame: self.view.frame)
  private var category: StoreCategory
  
  private var myLocationFlag = false
  
  var locationManager = CLLocationManager()
  var markers: [NMFMarker] = []
  var currentPosition: (latitude: Double, longitude: Double)?
  
  
  init(category: StoreCategory) {
    self.category = category
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(category: StoreCategory) -> CategoryListVC {
    return CategoryListVC(category: category)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = categoryListView
    
    self.setupLocationManager()
    self.setupNaverMap()
    self.loadAdBanner()
    self.categoryListView.setCategoryTitle(category: self.category)
  }
  
  override func bindEvent() {
    self.categoryListView.currentLocationButton.rx.tap.bind { [weak self] in
      self?.myLocationFlag = true
      self?.locationManager.startUpdatingLocation()
    }.disposed(by: disposeBag)
    
    categoryListView.backButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .back_button_clicked, page: .store_list_page)
      })
      .bind(onNext: self.popVC)
      .disposed(by: disposeBag)
  }
  
  private func setupLocationManager() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  private func setupNaverMap() {
    self.categoryListView.mapView.positionMode = .direction
    self.categoryListView.mapView.addCameraDelegate(delegate: self)
  }
  
  private func popVC() {
    self.navigationController?.popViewController(animated: true)
  }
  
  private func loadAdBanner() {
    #if DEBUG
    self.categoryListView.adBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
    #else
    self.categoryListView.adBannerView.adUnitID = "ca-app-pub-1527951560812478/3327283605"
    #endif
    
    self.categoryListView.adBannerView.rootViewController = self
    self.categoryListView.adBannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(self.view.frame.width)
    self.categoryListView.adBannerView.delegate = self
    
    if #available(iOS 14, *) {
      ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
        self.categoryListView.adBannerView.load(GADRequest())
      })
    } else {
      self.categoryListView.adBannerView.load(GADRequest())
    }
  }
  
  private func clearMarkers() {
    for marker in self.markers {
      marker.mapView = nil
    }
  }
  
  func setMarker(storeCards: [StoreCard]) {
    self.clearMarkers()
    
    for store in storeCards {
      let marker = NMFMarker()
      marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
      marker.iconImage = NMFOverlayImage(name: "ic_marker_store_on")
      marker.mapView = self.categoryListView.mapView
      self.markers.append(marker)
    }
  }
}

//MARK: NMFMapViewCameraDelegate
extension CategoryListVC: NMFMapViewCameraDelegate {
  func mapViewCameraIdle(_ mapView: NMFMapView) {
    
    self.currentPosition = (mapView.cameraPosition.target.lat, mapView.cameraPosition.target.lng)
    Log.debug("cameraDidChangeByReason: \(mapView.cameraPosition.target)")
  }
}

extension CategoryListVC: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations.last
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(
      lat: location!.coordinate.latitude,
      lng: location!.coordinate.longitude
    ))
    cameraUpdate.animation = .easeIn
    
    if !self.myLocationFlag {
      self.categoryListView.mapView.moveCamera(cameraUpdate)
//      self.setupPageVC(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
      self.myLocationFlag = false
    } else {
      self.categoryListView.mapView.moveCamera(cameraUpdate)
    }
    locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    if let error = error as? CLError {
      switch error.code {
      case .denied:
        AlertUtils.show(
          controller: self,
          title: "error_location_permission_denied_title".localized,
          message: "error_location_permission_denied_message".localized
        )
      case .locationUnknown:
        AlertUtils.show(
          controller: self,
          title: "error_location_unknown_title".localized,
          message: "error_location_unknown_message".localized
        )
      default:
        AlertUtils.show(
          controller: self,
          title: "error_location_default_title".localized,
          message: "error_location_default_message".localized
        )
        Crashlytics.crashlytics().log("location Manager Error(error code: \(error.code.rawValue)")
      }
    }
  }
}

extension CategoryListVC: GADBannerViewDelegate {
  /// Tells the delegate an ad request loaded an ad.
  func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    print("adViewDidReceiveAd")
  }
  
  /// Tells the delegate an ad request failed.
  func adView(_ bannerView: GADBannerView,
              didFailToReceiveAdWithError error: GADRequestError) {
    print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
  }
  
  /// Tells the delegate that a full-screen view will be presented in response
  /// to the user clicking on an ad.
  func adViewWillPresentScreen(_ bannerView: GADBannerView) {
    print("adViewWillPresentScreen")
  }
  
  /// Tells the delegate that the full-screen view will be dismissed.
  func adViewWillDismissScreen(_ bannerView: GADBannerView) {
    print("adViewWillDismissScreen")
  }
  
  /// Tells the delegate that the full-screen view has been dismissed.
  func adViewDidDismissScreen(_ bannerView: GADBannerView) {
    print("adViewDidDismissScreen")
  }
  
  /// Tells the delegate that a user click will open another app (such as
  /// the App Store), backgrounding the current app.
  func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
    print("adViewWillLeaveApplication")
  }
}


