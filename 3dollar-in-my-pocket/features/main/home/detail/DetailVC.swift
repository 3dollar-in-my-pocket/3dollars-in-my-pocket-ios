import UIKit
import GoogleMaps
import Kingfisher
import RxSwift
import GoogleMobileAds
import NMapsMap

class DetailVC: BaseVC {
  
  private lazy var detailView = DetailView(frame: self.view.frame)
  
  private var viewModel = DetailViewModel()
  private var reviewVC: ReviewModalVC?
  private var myLocationFlag = false
  var storeId: Int!
  var locationManager = CLLocationManager()
  
  static func instance(storeId: Int) -> DetailVC {
    return DetailVC.init(nibName: nil, bundle: nil).then {
      $0.storeId = storeId
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = detailView
    
    detailView.tableView.delegate = self
    detailView.tableView.dataSource = self
    detailView.tableView.register(ShopInfoCell.self, forCellReuseIdentifier: ShopInfoCell.registerId)
    detailView.tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCell.registerId)
    
    setupLocationManager()
  }
  
  override func bindViewModel() {
    viewModel.store.subscribe { [weak self] (store) in
      self?.detailView.tableView.reloadData()
    }.disposed(by: disposeBag)
    
    detailView.backBtn.rx.tap.bind { [weak self] in
      self?.navigationController?.popViewController(animated: true)
    }.disposed(by: disposeBag)
  }
  
  private func setupLocationManager() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  private func getStoreDetail(latitude: Double, longitude: Double) {
    StoreService.getStoreDetail(storeId: storeId, latitude: latitude, longitude: longitude) { [weak self] (response) in
      switch response.result {
      case .success(let store):
        self?.detailView.titleLabel.text = store.storeName
        
        self?.viewModel.store.onNext(store)
      case .failure(let error):
        AlertUtils.show(controller: self, title: "getStoreDetail error", message: error.localizedDescription)
      }
    }
  }
  
  private func moveToMyLocation(latitude: Double, longitude: Double) {
    guard let shopInfoCell = self.detailView.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ShopInfoCell else {
      return
    }
    
    let camera = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude,lng: longitude))
    
    camera.animation = .easeIn
    shopInfoCell.mapView.moveCamera(camera)
  }
}

extension DetailVC: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else {
      if let store = try? self.viewModel.store.value() {
        return store.reviews.count + 1
      } else {
        return 0
      }
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let store = try? self.viewModel.store.value() {
      if indexPath.section == 0 {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShopInfoCell.registerId, for: indexPath) as? ShopInfoCell else {
          return BaseTableViewCell()
        }
        cell.profileImage.rx.tap.bind { [weak self] (_) in
          if let vc = self {
            vc.present(ImageDetailVC.instance(title: store.storeName!, images: store.images), animated: false)
          }
        }.disposed(by: cell.disposeBag)
        
        cell.reviewBtn.rx.tap.bind { [weak self] (_) in
          if let vc = self {
            vc.reviewVC = ReviewModalVC.instance().then {
              $0.deleagete = self
              $0.storeId = self?.storeId
            }
            vc.detailView.addBgDim()
            vc.present(vc.reviewVC!, animated: true)
          }
        }.disposed(by: cell.disposeBag)
        
        cell.modifyBtn.rx.tap.bind { [weak self] (_) in
          if let vc = self,
             let store = try! vc.viewModel.store.value(){
            let modifyVC = ModifyVC.instance(store: store).then {
              $0.delegate = self
            }
            self?.navigationController?.pushViewController(modifyVC, animated: true)
          }
        }.disposed(by: cell.disposeBag)
        
        cell.mapBtn.rx.tap.bind { [weak self] in
          self?.myLocationFlag = true
          self?.locationManager.startUpdatingLocation()
        }.disposed(by: cell.disposeBag)
        
        cell.setRank(rank: store.rating)
        if !(store.images.isEmpty) {
          cell.setImage(url: store.images[0].url, count: store.images.count)
        }
        cell.otherImages.isUserInteractionEnabled = !store.images.isEmpty
        cell.profileImage.isUserInteractionEnabled = !store.images.isEmpty
        cell.setMarker(latitude: store.latitude!, longitude: store.longitude!)
        cell.setCategory(category: store.category!)
        cell.setMenus(menus: store.menus)
        cell.setDistance(distance: store.distance)
        
        return cell
      } else {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.registerId, for: indexPath) as? ReviewCell else {
          return BaseTableViewCell()
        }
        if indexPath.row == 0 {
          cell.bind(review: nil)
          #if DEBUG
          cell.adBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
          #else
          cell.adBannerView.adUnitID = "ca-app-pub-1527951560812478/3327283605"
          #endif
          
          cell.adBannerView.rootViewController = self
          
          // Step 2 - Determine the view width to use for the ad width.
          let frame = { () -> CGRect in
            // Here safe area is taken into account, hence the view frame is used
            // after the view has been laid out.
            if #available(iOS 11.0, *) {
              return view.frame.inset(by: view.safeAreaInsets)
            } else {
              return view.frame
            }
          }()
          let viewWidth = frame.size.width
          cell.adBannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
          cell.adBannerView.load(GADRequest())
        } else {
          cell.bind(review: store.reviews[indexPath.row - 1])
        }
        return cell
      }
    } else {
      return BaseTableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 1 {
      return ReviewHeaderView().then {
        if let store = try? self.viewModel.store.value() {
          $0.setReviewCount(count: store.reviews.count)
        }
      }
    } else {
      return nil
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 1 {
      return 70
    } else {
      return 0
    }
  }
}

extension DetailVC: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations.last
    
    if myLocationFlag {
      self.moveToMyLocation(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
    } else {
      self.getStoreDetail(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
    }
    self.viewModel.location = (location!.coordinate.latitude, location!.coordinate.longitude)
    locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    AlertUtils.show(title: "error locationManager", message: error.localizedDescription)
  }
}

extension DetailVC: ReviewModalDelegate {
  func onReviewSuccess() {
    self.detailView.removeBgDim()
    self.getStoreDetail(latitude: self.viewModel.location.latitude, longitude: self.viewModel.location.longitude)
  }
  
  func onTapClose() {
    reviewVC?.dismiss(animated: true, completion: nil)
    self.detailView.removeBgDim()
  }
}

extension DetailVC: ModifyDelegate {
  func onModifySuccess() {
    self.getStoreDetail(latitude: self.viewModel.location.latitude, longitude: self.viewModel.location.longitude)
  }
}

extension DetailVC: GADBannerViewDelegate {
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
