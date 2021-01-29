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
  private var myLocationFlag = false
  private let locationManager = CLLocationManager()
  var storeDataSource: RxTableViewSectionedReloadDataSource<StoreSection>!
  
  init(storeId: Int) {
    self.storeId = storeId
    self.viewModel = StoreDetailViewModel(
      storeId: storeId,
      userDefaults: UserDefaultsUtil(),
      storeService: StoreService(),
      reviewService: ReviewService()
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
    
    self.viewModel.output.showDeleteModal
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showDeleteModal(storeId:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToModify
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToModify(store:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.showReviewModal
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showReviewModal)
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
    
    self.detailView.deleteRequestButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .delete_request_button_clicked, page: .store_edit_page)
      })
      .bind(to: self.viewModel.input.tapDeleteRequest)
      .disposed(by: disposeBag)
  }
  
  private func setupTableView() {
    self.detailView.tableView.register(
      OverviewCell.self,
      forCellReuseIdentifier: OverviewCell.registerId
    )
    self.detailView.tableView.register(
      StoreInfoCell.self,
      forCellReuseIdentifier: StoreInfoCell.registerId
    )
    self.detailView.tableView.register(
      StoreDetailMenuCell.self,
      forCellReuseIdentifier: StoreDetailMenuCell.registerId
    )
    self.detailView.tableView.register(
      StoreDetailPhotoCollectionCell.self,
      forCellReuseIdentifier: StoreDetailPhotoCollectionCell.registerId
    )
    self.detailView.tableView.register(
      StoreDetailReviewCell.self,
      forCellReuseIdentifier: StoreDetailReviewCell.registerId
    )
    self.detailView.tableView.register(
      StoreDetailHeaderView.self,
      forHeaderFooterViewReuseIdentifier: StoreDetailHeaderView.registerId
    )
    self.detailView.tableView.register(
      StoreDetailMenuHeaderView.self,
      forHeaderFooterViewReuseIdentifier: StoreDetailMenuHeaderView.registerId
    )
    
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
          .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
          .do(onNext: { _ in
            GA.shared.logEvent(event: .share_button_clicked, page: .store_detail_page)
          })
          .bind(to: self.viewModel.input.tapShare)
          .disposed(by: cell.disposeBag)
        cell.transferButton.rx.tap
          .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
          .bind(to: self.viewModel.input.tapTransfer)
          .disposed(by: cell.disposeBag)
        return cell
      case .info:
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoreInfoCell.registerId, for: indexPath) as? StoreInfoCell else { return BaseTableViewCell() }
        
        cell.bind(store: dataSource.sectionModels[indexPath.section].store)
        return cell
      case .menu:
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoreDetailMenuCell.registerId, for: indexPath) as? StoreDetailMenuCell else { return BaseTableViewCell() }
        
        cell.addMenu()
        return cell
      case .photo:
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoreDetailPhotoCollectionCell.registerId, for: indexPath) as? StoreDetailPhotoCollectionCell else { return BaseTableViewCell() }
        let photos = self.storeDataSource.sectionModels[0].store.images
        
        cell.bind(photos: photos)
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
          
          let viewWidth = self.view.frame.size.width
          cell.adBannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
          cell.adBannerView.load(GADRequest())
        } else {
          let review = dataSource.sectionModels[StoreDetailSection.review.rawValue].items[indexPath.row]
          
          cell.bind(review: review)
          
          if let review = review,
             UserDefaultsUtil().getUserId() == review.user.id {
            cell.moreButton.isHidden = UserDefaultsUtil().getUserId() != review.user.id
            cell.moreButton.rx.tap
              .map { review }
              .observeOn(MainScheduler.instance)
              .bind(onNext: self.showMoreActionSheet(review:))
              .disposed(by: cell.disposeBag)
          }
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
  
  private func showDeleteModal(storeId: Int) {
    let deleteVC = DeleteModalVC.instance(storeId: storeId).then {
      $0.deleagete = self
    }
    
    self.detailView.showDim(isShow: true)
    self.present(deleteVC, animated: true, completion: nil)
  }
  
  private func showReviewModal(storeId: Int, review: Review? = nil) {
    let reviewVC = ReviewModalVC.instance(storeId: storeId, review: review).then {
      $0.deleagete = self
    }
    
    self.detailView.showDim(isShow: true)
    self.present(reviewVC, animated: true, completion: nil)
  }
  
  private func goToModify(store: Store) {
    let modifyVC = ModifyVC.instance(store: store).then {
      $0.delegate = self
    }
    self.navigationController?.pushViewController(modifyVC, animated: true)
  }
  
  private func showMoreActionSheet(review: Review) {
    let alertController = UIAlertController(title: nil, message: "옵션", preferredStyle: .actionSheet)
    let modifyAction = UIAlertAction(title: "댓글 수정", style: .default) { _ in
      self.viewModel.input.tapModifyReview.onNext(review)
    }
    let deleteAction = UIAlertAction(title: "댓글 삭제", style: .destructive) { _ in
      self.viewModel.input.deleteReview.onNext(review.id)
    }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in }
    
    alertController.addAction(deleteAction)
    alertController.addAction(modifyAction)
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
      guard let headerView = tableView.dequeueReusableHeaderFooterView(
              withIdentifier: StoreDetailHeaderView.registerId
      ) as? StoreDetailHeaderView else { return UITableViewHeaderFooterView() }
      
      headerView.bind(section: .info, count: nil)
      headerView.rightButton.rx.tap
        .do(onNext: { _ in
          GA.shared.logEvent(event: .store_modify_button_clicked, page: .store_detail_page)
        })
        .bind(to: self.viewModel.input.tapModify)
        .disposed(by: headerView.disposeBag)
      return headerView
      
    case .menu:
      guard let headerView = tableView.dequeueReusableHeaderFooterView(
              withIdentifier: StoreDetailMenuHeaderView.registerId
      ) as? StoreDetailMenuHeaderView else { return UITableViewHeaderFooterView() }
      
      return headerView
      
    case .photo:
      guard let headerView = tableView.dequeueReusableHeaderFooterView(
              withIdentifier: StoreDetailHeaderView.registerId
      ) as? StoreDetailHeaderView else { return UITableViewHeaderFooterView() }
      
      headerView.bind(section: .photo, count: self.storeDataSource.sectionModels[0].store.images.count)
      return headerView
      
    case .review:
      guard let headerView = tableView.dequeueReusableHeaderFooterView(
              withIdentifier: StoreDetailHeaderView.registerId
      ) as? StoreDetailHeaderView else { return UITableViewHeaderFooterView() }
      
      headerView.bind(section: .review, count: self.storeDataSource.sectionModels[0].store.reviews.count)
      headerView.rightButton.rx.tap
        .do(onNext: { _ in
          GA.shared.logEvent(event: .review_write_button_clicked, page: .store_detail_page)
        })
        .bind(to: self.viewModel.input.tapWriteReview)
        .disposed(by: headerView.disposeBag)
      
      return headerView
      
    default:
      return UIView(frame: .zero)
    }
  }
}

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
    self.myLocationFlag = false
    self.locationManager.startUpdatingLocation()
    self.detailView.showDim(isShow: false)
  }
  
  func onTapClose() {
    self.detailView.showDim(isShow: false)
  }
}

extension StoreDetailVC: DeleteModalDelegate {
  
  func onRequest() {
    self.detailView.showDim(isShow: false)
    self.navigationController?.popToRootViewController(animated: true)
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
