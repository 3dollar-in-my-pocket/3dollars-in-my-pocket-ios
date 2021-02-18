import UIKit
import NMapsMap
import GoogleMobileAds
import FirebaseCrashlytics
import AppTrackingTransparency
import AdSupport

class CategoryListVC: BaseVC {
  
  private lazy var categoryListView = CategoryListView(frame: self.view.frame)
  
  private var pageVC: CategoryPageVC!
  
  private var category: StoreCategory!
  
  private var myLocationFlag = false
  
  var locationManager = CLLocationManager()
  
  var markers: [NMFMarker] = []
  
  var currentPosition: (latitude: Double, longitude: Double)?
  
  
  static func instance(category: StoreCategory) -> CategoryListVC {
    return CategoryListVC(nibName: nil, bundle: nil).then {
      $0.category = category
      $0.tabBarItem = UITabBarItem(
        title: nil,
        image: UIImage(named: "ic_category"),
        tag: TabBarTag.home.rawValue
      )
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = categoryListView
    
    self.tapCategory(selectedIndex: StoreCategory.categoryToIndex(category))
    self.setupLocationManager()
    self.setupNaverMap()
    self.loadAdBanner()
  }
  
  override func bindEvent() {
    for index in categoryListView.categoryStackView.arrangedSubviews.indices {
      if let button = categoryListView.categoryStackView.arrangedSubviews[index] as? UIButton {
        button.rx.tap
          .do(onNext: { _ in
            switch index {
            case 0:
              GA.shared.logEvent(event: .filter_bungeoppang_button_clicked, page: .store_list_page)
            case 1:
              GA.shared.logEvent(event: .filter_takoyaki_button_clicked, page: .store_list_page)
            case 2:
              GA.shared.logEvent(event: .filter_gyeranppang_button_clicked, page: .store_list_page)
            case 3:
              GA.shared.logEvent(event: .filter_hotteok_button_clicked, page: .store_list_page)
            default:
              break
            }
          })
          .bind { [weak self] in
            self?.tapCategory(selectedIndex: index)
            self?.pageVC.tapCategory(index: index)
        }.disposed(by: disposeBag)
      }
    }
    
    categoryListView.myLocationBtn.rx.tap.bind { [weak self] in
      self?.myLocationFlag = true
      self?.locationManager.startUpdatingLocation()
    }.disposed(by: disposeBag)
    
    categoryListView.backBtn.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .back_button_clicked, page: .store_list_page)
      })
      .bind { [weak self] in
      self?.navigationController?.popViewController(animated: true)
    }.disposed(by: disposeBag)
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
  
  private func setupPageVC(latitude: Double, longitude: Double) {
    pageVC = CategoryPageVC.instance(
      category: self.category,
      latitude: latitude,
      longitude: longitude
    )
    addChild(pageVC)
    pageVC.pageDelegate = self
    categoryListView.pageView.addSubview(pageVC.view)
    pageVC.view.snp.makeConstraints { (make) in
      make.edges.equalTo(categoryListView.pageView)
    }
  }
  
  private func tapCategory(selectedIndex: Int) {
    categoryListView.setCategoryTitleImage(category: StoreCategory.index(selectedIndex))
    for index in self.categoryListView.categoryStackView.arrangedSubviews.indices {
      if let button = self.categoryListView.categoryStackView.arrangedSubviews[index] as? UIButton {
        button.isSelected = (index == selectedIndex)
      }
    }
  }
  
  private func markerWithSize(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
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
}

extension CategoryListVC: CategoryPageDelegate {
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
  
  func onScrollPage(index: Int) {
    self.tapCategory(selectedIndex: index)
  }
}

//MARK: NMFMapViewCameraDelegate
extension CategoryListVC: NMFMapViewCameraDelegate {
  func mapViewCameraIdle(_ mapView: NMFMapView) {
    
    self.currentPosition = (mapView.cameraPosition.target.lat, mapView.cameraPosition.target.lng)
    if self.pageVC != nil {
      self.pageVC.viewControllers?[0].viewWillAppear(false)
    }
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
      self.setupPageVC(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
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


