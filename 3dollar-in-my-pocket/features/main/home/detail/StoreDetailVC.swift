import UIKit
import Kingfisher
import RxSwift
import RxDataSources
import GoogleMobileAds
import NMapsMap

class StoreDetailVC: BaseVC {
  
  private lazy var detailView = StoreDetailView(frame: self.view.frame)
  
  private let viewModel: StoreDetailViewModel
  private let storeId: Int
  private var reviewVC: ReviewModalVC?
  private var myLocationFlag = false
  private let locationManager = CLLocationManager()
  var storeDataSource: RxTableViewSectionedReloadDataSource<StoreSection>!
  
  init(storeId: Int) {
    self.storeId = storeId
    self.viewModel = StoreDetailViewModel(
      storeId: storeId,
      userDefaults: UserDefaultsUtil(),
      storeService: StoreService()
    )
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(storeId: Int) -> StoreDetailVC {
    return StoreDetailVC(storeId: storeId)
  }
  
  override func viewDidLoad() {
    self.setupTableView()
    
    super.viewDidLoad()
    
    view = detailView
    self.setupLocationManager()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.viewModel.clearKakaoLinkIfExisted()
  }
  
  override func bindViewModel() {
    // Bind output
    self.viewModel.output.store
      .bind(to: self.detailView.tableView.rx.items(dataSource:self.storeDataSource))
      .disposed(by: disposeBag)
    
    self.viewModel.output.showLoading
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.detailView.showLoading(isShow:))
      .disposed(by: disposeBag)
    
    self.viewModel.showSystemAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showSystemAlert(alert:))
      .disposed(by: disposeBag)
    
    self.viewModel.httpErrorAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showHTTPErrorAlert(error:))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.detailView.backButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .back_button_clicked, page: .store_detail_page)
      })
      .bind(onNext: self.popupVC)
      .disposed(by: disposeBag)
    
//    self.detailView.shareButton.rx.tap
//      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
//      .do(onNext: { _ in
//        GA.shared.logEvent(event: .share_button_clicked, page: .store_detail_page)
//      })
//      .bind(to: self.viewModel.input.tapShare)
//      .disposed(by: disposeBag)
  }
  
  private func setupTableView() {
    self.detailView.tableView.register(OverviewCell.self, forCellReuseIdentifier: OverviewCell.registerId)
    self.detailView.tableView.register(StoreInfoCell.self, forCellReuseIdentifier: StoreInfoCell.registerId)
    self.detailView.tableView.register(StoreDetailMenuCell.self, forCellReuseIdentifier: StoreDetailMenuCell.registerId)
    self.detailView.tableView.register(StoreDetailPhotoCollectionCell.self, forCellReuseIdentifier: StoreDetailPhotoCollectionCell.registerId)
    self.detailView.tableView.register(StoreDetailReviewCell.self, forCellReuseIdentifier: StoreDetailReviewCell.registerId)
    
    self.detailView.tableView.rx.setDelegate(self)
      .disposed(by: disposeBag)
    self.storeDataSource = RxTableViewSectionedReloadDataSource<StoreSection> { (dataSource, tableView, indexPath, item) in
      
      switch StoreDetailSection(rawValue: indexPath.section)! {
      case .overview:
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OverviewCell.registerId, for: indexPath) as? OverviewCell else { return BaseTableViewCell() }
        
        cell.bind(store: dataSource.sectionModels[indexPath.section].store)
        cell.currentLocationButton.rx.tap
          .do { _ in
            self.myLocationFlag = true
          }.bind(onNext: self.locationManager.startUpdatingLocation)
          .disposed(by: cell.disposeBag)
        cell.shareButton.rx.tap
          .bind(to: self.viewModel.input.tapShare)
          .disposed(by: cell.disposeBag)
        cell.transferButton.rx.tap
          .bind(to: self.viewModel.input.tapTransfer)
          .disposed(by: cell.disposeBag)
        return cell
      case .info:
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoreInfoCell.registerId, for: indexPath) as? StoreInfoCell else { return BaseTableViewCell() }
        
        return cell
      case .menu:
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoreDetailMenuCell.registerId, for: indexPath) as? StoreDetailMenuCell else { return BaseTableViewCell() }
        
        cell.addMenu()
        return cell
      case .photo:
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoreDetailPhotoCollectionCell.registerId, for: indexPath) as? StoreDetailPhotoCollectionCell else { return BaseTableViewCell() }
        
        cell.bind(photos: ["", "", "", "", "", ""])
        return cell
      case .review:
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoreDetailReviewCell.registerId, for: indexPath) as? StoreDetailReviewCell else { return BaseTableViewCell() }
        
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
              return self.view.frame.inset(by: self.view.safeAreaInsets)
            } else {
              return self.view.frame
            }
          }()
          let viewWidth = frame.size.width
          cell.adBannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
          cell.adBannerView.load(GADRequest())
        } else {
//          if let store = try? self.viewModel.store.value() {
//            let review = store.reviews[indexPath.row - 1]
//
//            if UserDefaultsUtil().getUserId() == review.user.id {
//              cell.moreButton.isHidden = UserDefaultsUtil().getUserId() != review.user.id
//              cell.moreButton.rx.tap
//                .map { review.id }
//                .observeOn(MainScheduler.instance)
//                .bind(onNext: self.showDeleteActionSheet(reviewId:))
//                .disposed(by: cell.disposeBag)
//            }
//            cell.bind(review: review)
//          }
        }
        
        return cell
      }
    }
  }
  
  private func setupLocationManager() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  private func popupVC() {
    self.navigationController?.popViewController(animated: true)
  }
  
  private func moveToMyLocation(latitude: Double, longitude: Double) {
    guard let overViewCell = self.detailView.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OverviewCell else {
      return
    }
    
    overViewCell.moveToPosition(latitude: latitude, longitude: longitude)
  }
  
  private func showDeleteActionSheet(reviewId: Int) {
    let alertController = UIAlertController(title: nil, message: "옵션", preferredStyle: .actionSheet)
    let deleteAction = UIAlertAction(title: "댓글 삭제", style: .destructive) { _ in
      self.viewModel.input.deleteReview.onNext(reviewId)
    }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in }
    
    alertController.addAction(deleteAction)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)
  }
}

extension StoreDetailVC: UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 5
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    switch StoreDetailSection(rawValue: section) {
    case .overview:
      return UIView(frame: .zero)
    case .info:
      return StoreDetailHeaderView()
    case .menu:
      return StoreDetailMenuHeaderView()
    case .photo:
      return StoreDetailHeaderView()
    case .review:
      return StoreDetailHeaderView()
    default:
      return UIView(frame: .zero)
    }
  }
}

//extension DetailVC: UITableViewDelegate, UITableViewDataSource {
//
//  func numberOfSections(in tableView: UITableView) -> Int {
//    return 2
//  }
//
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    if section == 0 {
//      return 1
//    } else {
//      if let store = try? self.viewModel.store.value() {
//        return store.reviews.count + 1
//      } else {
//        return 0
//      }
//    }
//  }
//
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    if let store = try? self.viewModel.store.value() {
//      if indexPath.section == 0 {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShopInfoCell.registerId, for: indexPath) as? ShopInfoCell else {
//          return BaseTableViewCell()
//        }
//        cell.profileImage.rx.tap.bind { [weak self] (_) in
//          if let vc = self {
//            vc.present(ImageDetailVC.instance(title: store.storeName, images: store.images), animated: false)
//          }
//        }.disposed(by: cell.disposeBag)
//
//        cell.reviewBtn.rx.tap
//          .do(onNext: { _ in
//            GA.shared.logEvent(event: .review_write_button_clicked, page: .store_detail_page)
//          })
//          .bind { [weak self] (_) in
//          if let vc = self {
//            vc.reviewVC = ReviewModalVC.instance(storeId: vc.storeId).then {
//              $0.deleagete = self
//            }
////            vc.detailView.addBgDim()
//            vc.present(vc.reviewVC!, animated: true)
//          }
//        }.disposed(by: cell.disposeBag)
//
//        cell.modifyBtn.rx.tap
//          .do(onNext: { _ in
//            GA.shared.logEvent(event: .store_modify_button_clicked, page: .store_detail_page)
//          })
//          .bind { [weak self] (_) in
//          if let vc = self,
//             let store = try! vc.viewModel.store.value(){
//            let modifyVC = ModifyVC.instance(store: store).then {
//              $0.delegate = self
//            }
//            self?.navigationController?.pushViewController(modifyVC, animated: true)
//          }
//        }.disposed(by: cell.disposeBag)
//
//        cell.mapBtn.rx.tap.bind { [weak self] in
//          self?.myLocationFlag = true
//          self?.locationManager.startUpdatingLocation()
//        }.disposed(by: cell.disposeBag)
//
//        cell.setRank(rank: store.rating)
//        if !(store.images.isEmpty) {
//          cell.setImage(url: store.images[0].url, count: store.images.count)
//        }
//        cell.otherImages.isUserInteractionEnabled = !store.images.isEmpty
//        cell.profileImage.isUserInteractionEnabled = !store.images.isEmpty
//        cell.setMarker(latitude: store.latitude, longitude: store.longitude)
//        cell.setCategory(category: store.category)
//        cell.setMenus(menus: store.menus)
//        cell.setDistance(distance: store.distance)
//
//        return cell
//      } else {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.registerId, for: indexPath) as? ReviewCell else {
//          return BaseTableViewCell()
//        }
//        if indexPath.row == 0 {
//          cell.bind(review: nil)
//          #if DEBUG
//          cell.adBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//          #else
//          cell.adBannerView.adUnitID = "ca-app-pub-1527951560812478/3327283605"
//          #endif
//
//          cell.adBannerView.rootViewController = self
//
//          // Step 2 - Determine the view width to use for the ad width.
//          let frame = { () -> CGRect in
//            // Here safe area is taken into account, hence the view frame is used
//            // after the view has been laid out.
//            if #available(iOS 11.0, *) {
//              return view.frame.inset(by: view.safeAreaInsets)
//            } else {
//              return view.frame
//            }
//          }()
//          let viewWidth = frame.size.width
//          cell.adBannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
//          cell.adBannerView.load(GADRequest())
//        } else {
//          let review = store.reviews[indexPath.row - 1]
//
//          if UserDefaultsUtil().getUserId() == review.user.id {
//            cell.moreButton.isHidden = UserDefaultsUtil().getUserId() != review.user.id
//            cell.moreButton.rx.tap
//              .map { review.id }
//              .observeOn(MainScheduler.instance)
//              .bind(onNext: self.showDeleteActionSheet(reviewId:))
//              .disposed(by: cell.disposeBag)
//          }
//          cell.bind(review: review)
//        }
//        return cell
//      }
//    } else {
//      return BaseTableViewCell()
//    }
//  }
//
//  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//    if section == 1 {
//      return ReviewHeaderView().then {
//        if let store = try? self.viewModel.store.value() {
//          $0.setReviewCount(count: store.reviews.count)
//        }
//      }
//    } else {
//      return nil
//    }
//  }
//
//  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//    if section == 1 {
//      return 70
//    } else {
//      return 0
//    }
//  }
//}

extension StoreDetailVC: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    
    if myLocationFlag {
      self.moveToMyLocation(
        latitude: location.coordinate.latitude,
        longitude: location.coordinate.longitude
      )
    } else {
      self.viewModel.input.currentLocation.onNext((location.coordinate.latitude, location.coordinate.longitude))
    }
    locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//    AlertUtils.show(title: "error locationManager", message: error.localizedDescription)
  }
}

extension StoreDetailVC: ReviewModalDelegate {
  func onReviewSuccess() {
    self.reviewVC?.dismiss(animated: true, completion: nil)
//    self.getStoreDetail(latitude: self.viewModel.location.latitude, longitude: self.viewModel.location.longitude)
  }
  
  func onTapClose() {
    reviewVC?.dismiss(animated: true, completion: nil)
  }
}

extension StoreDetailVC: ModifyDelegate {
  func onModifySuccess() {
//    self.getStoreDetail(latitude: self.viewModel.location.latitude, longitude: self.viewModel.location.longitude)
  }
}

extension StoreDetailVC: GADBannerViewDelegate {
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

enum StoreDetailSection: Int {
  case overview = 0
  case info = 1
  case menu = 2
  case photo = 3
  case review = 4
}
