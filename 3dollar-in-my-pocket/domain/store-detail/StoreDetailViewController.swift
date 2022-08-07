import UIKit
import Kingfisher
import RxSwift
import RxDataSources
import GoogleMobileAds
import NMapsMap
import AppTrackingTransparency
import AdSupport
import SPPermissions

final class StoreDetailViewController: BaseVC, StoreDetailCoordinator {
  private let storeDetailView = StoreDetailView()
  private let viewModel: StoreDetailViewModel
  private weak var coordinator: StoreDetailCoordinator?
  private var myLocationFlag = false
  private lazy var imagePicker = UIImagePickerController().then {
    $0.delegate = self
  }
  
  init(storeId: Int) {
    self.viewModel = StoreDetailViewModel(
      storeId: storeId,
      userDefaults: UserDefaultsUtil(),
      locationManager: LocationManager.shared,
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
    self.viewModel.input.fetch.onNext(())
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.viewModel.input.popup.onNext(())
  }
  
  override func bindEvent() {
    self.storeDetailView.backButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .back_button_clicked, page: .store_detail_page)
      })
      .bind(onNext: { [weak self] in
        self?.coordinator?.popup()
      })
      .disposed(by: self.disposeBag)
  }
  
  override func bindViewModelInput() {
    self.storeDetailView.storeOverview.currentLocationButton.rx.tap
      .bind(to: self.viewModel.input.fetch)
      .disposed(by: self.disposeBag)
    
    self.storeDetailView.deleteRequestButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .store_delete_request_button_clicked, page: .store_edit_page)
      })
      .bind(to: self.viewModel.input.tapDeleteRequest)
      .disposed(by: self.disposeBag)
    
    self.storeDetailView.rx.tapShareButton
      .bind(to: self.viewModel.input.tapShareButton)
      .disposed(by: self.disposeBag)
    
    self.storeDetailView.storeVisitHistoryView.rx.tap
        .bind(to: self.viewModel.input.tapVisitHistoryButton)
        .disposed(by: self.disposeBag)
    
    self.storeDetailView.rx.tapEditStore
      .bind(to: self.viewModel.input.tapEditStoreButton)
      .disposed(by: self.disposeBag)
    
    self.storeDetailView.rx.tapAddPhotoButton
      .bind(to: self.viewModel.input.tapAddPhotoButton)
      .disposed(by: self.disposeBag)
        
    self.storeDetailView.storePhotoCollectionView.photoCollectionView.rx.itemSelected
      .map { $0.row }
      .bind(to: self.viewModel.input.tapPhoto)
      .disposed(by: self.disposeBag)
    
    self.storeDetailView.rx.tapWriteReviewButton
      .bind(to: self.viewModel.input.tapWriteReview)
      .disposed(by: self.disposeBag)
    
    self.storeDetailView.visitButton.rx.tap
      .bind(to: self.viewModel.input.tapVisitButton)
      .disposed(by: self.disposeBag)
  }
  
  override func bindViewModelOutput() {
    self.viewModel.output.store
      .asDriver(onErrorJustReturn: Store())
      .drive(self.storeDetailView.rx.store)
      .disposed(by: self.disposeBag)
        
    self.viewModel.output.reviews
      .asDriver(onErrorJustReturn: [])
      .do(onNext: { [weak self] reviews in
        self?.storeDetailView.updateReviewTableViewHeight(reviews: reviews)
      })
      .drive(self.storeDetailView.storeReviewTableView.reviewTableView.rx.items(
        cellIdentifier: StoreDetailReviewCell.registerId,
        cellType: StoreDetailReviewCell.self
      )) { _, review, cell in
        cell.bind(review: review, userId: self.viewModel.userDefaults.getUserId())
        cell.moreButton.rx.tap
          .asDriver()
          .drive(onNext: { [weak self] in
            guard let review = review else { return }
            self?.coordinator?.showMoreActionSheet(
              review: review,
              onTapModify: {
                self?.viewModel.input.tapEditReview.onNext(review)
              },
              onTapDelete: {
                self?.viewModel.input.deleteReview.onNext(review.reviewId)
              }
            )
          })
          .disposed(by: cell.disposeBag)
        cell.adBannerView.rootViewController = self
      }
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.showDeleteModal
      .observeOn(MainScheduler.instance)
      .bind(onNext: { [weak self] storeId in
        self?.coordinator?.showDeleteModal(storeId: storeId)
      })
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.showVisitHistories
        .asDriver(onErrorJustReturn: [])
        .drive(onNext: { [weak self] visitHistories in
            self?.coordinator?.showVisitHistories(visitHistories: visitHistories)
        })
        .disposed(by: self.disposeBag)
    
    self.viewModel.output.goToModify
      .observeOn(MainScheduler.instance)
      .bind(onNext: { [weak self] store in
        self?.coordinator?.goToModify(store: store)
      })
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.showPhotoDetail
      .observeOn(MainScheduler.instance)
      .bind(onNext: { [weak self] (storeId, index, photos) in
        self?.coordinator?.showPhotoDetail(storeId: storeId, index: index, photos: photos)
      })
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.showAddPhotoActionSheet
      .asDriver(onErrorJustReturn: 0)
      .drive { [weak self] storeId in
        self?.coordinator?.showPictureActionSheet(storeId: storeId)
      }
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.goToPhotoList
      .observeOn(MainScheduler.instance)
      .bind(onNext: { [weak self] storeId in
        self?.coordinator?.goToPhotoList(storeId: storeId)
      })
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.showReviewModal
      .observeOn(MainScheduler.instance)
      .bind(onNext: { [weak self] (storeId, review) in
        self?.coordinator?.showReviewModal(storeId: storeId, review: review)
      })
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.popup
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.passStore(store:))
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.showVisit
      .asDriver(onErrorJustReturn: Store())
      .drive(onNext: { [weak self] store in
        self?.coordinator?.showVisit(store: store)
      })
      .disposed(by: self.disposeBag)
    
    self.viewModel.showLoading
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showRootLoading(isShow:))
      .disposed(by: self.disposeBag)
    
    self.viewModel.showErrorAlert
      .asDriver(onErrorJustReturn: BaseError.unknown)
      .drive { [weak self] error in
        self?.coordinator?.showErrorAlert(error: error)
      }
      .disposed(by: self.disposeBag)
  }
    
  private func passStore(store: Store) {
      GlobalState.shared.updateStore.onNext(store)
  }
}

extension StoreDetailViewController: ReviewModalDelegate {
  
  func onReviewSuccess() {
    self.myLocationFlag = false
    self.viewModel.input.fetch.onNext(())
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
    self.viewModel.input.fetch.onNext(())
  }
}

extension StoreDetailViewController: PhotoDetailDelegate {
  func onClose() {
    self.myLocationFlag = false
    self.viewModel.input.fetch.onNext(())
  }
}

extension StoreDetailViewController: UIImagePickerControllerDelegate,
                                     UINavigationControllerDelegate {
  
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
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
      self.coordinator?.showRegisterPhoto(storeId: self.viewModel.storeId)
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

extension StoreDetailViewController: VisitHistoryViewControllerDelegate {
    func onDismiss() {
        self.coordinator?.showRootDim(isShow: false)
    }
}
