import UIKit
import Kingfisher
import RxSwift
import RxDataSources
import GoogleMobileAds
import NMapsMap
import AppTrackingTransparency
import AdSupport
import SPPermissions

protocol StoreDetailDelegate: AnyObject {
  func popup(store: Store)
}

class StoreDetailViewController: BaseVC, StoreDetailCoordinator {
  
  weak var delegate: StoreDetailDelegate?
  private let storeDetailView = StoreDetailView()
  private let viewModel: StoreDetailViewModel
  fileprivate weak var coordinator: StoreDetailCoordinator?
  private var myLocationFlag = false
  private lazy var imagePicker = UIImagePickerController().then {
    $0.delegate = self
  }
  
  init(storeId: Int) {
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
  
  static func instance(storeId: Int) -> StoreDetailViewController {
    return StoreDetailViewController(storeId: storeId).then {
      $0.hidesBottomBarWhenPushed = true
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view = storeDetailView
    self.coordinator = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.tabBarController?.tabBar.barTintColor = .white
    self.viewModel.clearKakaoLinkIfExisted()
    self.fetchMyLocation()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.viewModel.input.popup.onNext(())
  }
  
  override func bindViewModel() {
    // Bind output
    self.viewModel.output.category
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.storeDetailView.bind)
      .disposed(by: disposeBag)
    
    self.viewModel.output.store
      .asDriver(onErrorJustReturn: Store())
      .drive(self.storeDetailView.rx.store)
      .disposed(by: self.disposeBag)
        
    self.viewModel.output.showDeleteModal
      .observeOn(MainScheduler.instance)
      .bind(onNext: { [weak self] storeId in
        self?.coordinator?.showDeleteModal(storeId: storeId)
      })
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToModify
      .observeOn(MainScheduler.instance)
      .bind(onNext: { [weak self] store in
        self?.coordinator?.goToModify(store: store)
      })
      .disposed(by: disposeBag)
    
    self.viewModel.output.showPhotoDetail
      .observeOn(MainScheduler.instance)
      .bind(onNext: { [weak self] (storeId, index, photos) in
        self?.coordinator?.showPhotoDetail(storeId: storeId, index: index, photos: photos)
      })
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToPhotoList
      .observeOn(MainScheduler.instance)
      .bind(onNext: { [weak self] storeId in
        self?.coordinator?.goToPhotoList(storeId: storeId)
      })
      .disposed(by: disposeBag)
    
    self.viewModel.output.showReviewModal
      .observeOn(MainScheduler.instance)
      .bind(onNext: { [weak self] (storeId, review) in
        self?.coordinator?.showReviewModal(storeId: storeId, review: review)
      })
      .disposed(by: disposeBag)
    
    self.viewModel.output.showLoading
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showRootLoading(isShow:))
      .disposed(by: disposeBag)
    
    self.viewModel.showSystemAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showSystemAlert(alert:))
      .disposed(by: disposeBag)
    
    self.viewModel.httpErrorAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showHTTPErrorAlert(error:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.popup
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.passStore(store:))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.storeDetailView.backButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .back_button_clicked, page: .store_detail_page)
      })
      .bind(onNext: { [weak self] in
        self?.coordinator?.popup()
      })
      .disposed(by: disposeBag)
    
    self.storeDetailView.deleteRequestButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .store_delete_request_button_clicked, page: .store_edit_page)
      })
      .bind(to: self.viewModel.input.tapDeleteRequest)
      .disposed(by: disposeBag)
  }
  
  private func fetchMyLocation() {
    LocationManager.shared.getCurrentLocation()
      .asDriver(onErrorJustReturn: .init(latitude: 0, longitude: 0))
      .drive { [weak self] location in
        guard let self = self else { return }
        if self.myLocationFlag {
          self.moveToMyLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
          )
        } else {
          self.viewModel.input.currentLocation.onNext((location.coordinate.latitude, location.coordinate.longitude))
        }
      }
      .disposed(by: self.disposeBag)
  }
  
//  private func setupTableView() {
//    self.storeDataSource = RxTableViewSectionedReloadDataSource<StoreSection> { (dataSource, tableView, indexPath, item) in
//
//      switch StoreDetailSection(rawValue: indexPath.section)! {
//      case .review:
//        guard let cell = tableView.dequeueReusableCell(
//          withIdentifier: StoreDetailReviewCell.registerId,
//          for: indexPath
//        ) as? StoreDetailReviewCell else { return BaseTableViewCell() }
//
//        if indexPath.row == 0 {
//          cell.bind(review: nil)
//          #if DEBUG
//          cell.adBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//          #else
//          cell.adBannerView.adUnitID = "ca-app-pub-1527951560812478/3327283605"
//          #endif
//          cell.adBannerView.rootViewController = self
//          cell.adBannerView.delegate = self
//
//          let viewWidth = self.view.frame.size.width
//          cell.adBannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
//
//          if #available(iOS 14, *) {
//            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
//              cell.adBannerView.load(GADRequest())
//            })
//          } else {
//            cell.adBannerView.load(GADRequest())
//          }
//        } else {
//          let review = dataSource.sectionModels[StoreDetailSection.review.rawValue].items[indexPath.row]
//
//          cell.bind(review: review)
//
//          if let review = review,
//             UserDefaultsUtil().getUserId() == review.user.userId {
//            cell.moreButton.isHidden = UserDefaultsUtil().getUserId() != review.user.userId
//            cell.moreButton.rx.tap
//              .map { review }
//              .observeOn(MainScheduler.instance)
//              .bind(onNext: self.showMoreActionSheet(review:))
//              .disposed(by: cell.disposeBag)
//          }
//        }
//
//        return cell
//
//      default:
//        return BaseTableViewCell()
//      }
//    }
//  }
  
//  private func popupVC() {
//    self.navigationController?.popViewController(animated: true)
//  }
  
  private func passStore(store: Store) {
    self.delegate?.popup(store: store)
  }
  
  private func moveToMyLocation(latitude: Double, longitude: Double) {
//    guard let overViewCell = self.detailView.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OverviewCell else {
//      return
//    }
//
//    overViewCell.moveToPosition(latitude: latitude, longitude: longitude)
  }
  
  private func showMoreActionSheet(review: Review) {
    let alertController = UIAlertController(title: nil, message: "옵션", preferredStyle: .actionSheet)
    let modifyAction = UIAlertAction(
      title: "store_detail_modify_review".localized,
      style: .default
    ) { _ in
      self.viewModel.input.tapModifyReview.onNext(review)
    }
    let deleteAction = UIAlertAction(
      title: "store_detail_delete_review".localized,
      style: .destructive
    ) { _ in
      self.viewModel.input.deleteReview.onNext(review.reviewId)
    }
    let cancelAction = UIAlertAction(
      title: "store_detail_cancel".localized,
      style: .cancel
    ) { _ in }
    
    alertController.addAction(deleteAction)
    alertController.addAction(modifyAction)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  private func showPictureActionSheet() {
    let alert = UIAlertController(
      title: "store_detail_register_photo".localized,
      message: nil,
      preferredStyle: .actionSheet
    )
    let libraryAction = UIAlertAction(
      title: "store_detail_album".localized,
      style: .default
    ) { _ in
      if SPPermission.photoLibrary.isAuthorized {
//        self.showRegisterPhoto(storeId: self.storeId)
      } else {
        let controller = SPPermissions.native([.photoLibrary])
        
        controller.delegate = self
        controller.present(on: self)
      }
    }
    let cameraAction = UIAlertAction(
      title: "store_detail_camera".localized,
      style: .default
    ) { _ in
      if SPPermission.camera.isAuthorized {
        self.showCamera()
      } else {
        let controller = SPPermissions.native([.camera])
        
        controller.delegate = self
        controller.present(on: self)
      }
    }
    let cancelAction = UIAlertAction(
      title: "store_detail_cancel".localized,
      style: .cancel,
      handler: nil
    )
    
    alert.addAction(libraryAction)
    alert.addAction(cameraAction)
    alert.addAction(cancelAction)
    self.present(alert, animated: true)
  }
}

extension StoreDetailViewController: ReviewModalDelegate {
  
  func onReviewSuccess() {
    self.myLocationFlag = false
    self.fetchMyLocation()
    self.showRootDim(isShow: false)
  }
  
  func onTapClose() {
    self.showRootDim(isShow: false)
  }
}

extension StoreDetailViewController: DeleteModalDelegate {
  
  func onRequest() {
    self.showRootDim(isShow: false)
    self.navigationController?.popToRootViewController(animated: true)
  }
}

extension StoreDetailViewController: RegisterPhotoDelegate {
  func onSaveSuccess() {
    self.myLocationFlag = false
    self.fetchMyLocation()
  }
}

extension StoreDetailViewController: PhotoDetailDelegate {
  func onClose() {
    self.myLocationFlag = false
    self.fetchMyLocation()
  }
}

extension StoreDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
  ) {
    if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      self.viewModel.input.registerPhoto.onNext(photo)
    }

    picker.dismiss(animated: true, completion: nil) // picker를 닫아줌
  }
}

extension StoreDetailViewController: SPPermissionsDelegate {
  func didAllow(permission: SPPermission) {
    if permission == .camera {
      self.coordinator?.showCamera()
    } else if permission == .photoLibrary {
//      self.showRegisterPhoto(storeId: self.storeId)
    }
  }
  
  func deniedData(for permission: SPPermission) -> SPPermissionDeniedAlertData? {
    let data = SPPermissionDeniedAlertData()
    
    data.alertOpenSettingsDeniedPermissionTitle = "permission_denied_title".localized
    data.alertOpenSettingsDeniedPermissionDescription = "permission_denied_description".localized
    data.alertOpenSettingsDeniedPermissionButtonTitle = "permission_setting_button".localized
    data.alertOpenSettingsDeniedPermissionCancelTitle = "permission_setting_cancel".localized
    return data
  }
}
