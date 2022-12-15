// swiftlint:disable cyclomatic_complexity

import UIKit
import AppTrackingTransparency
import AdSupport

import ReactorKit
import Kingfisher
import RxSwift
import RxDataSources
import GoogleMobileAds
import NMapsMap
import SPPermissions

final class StoreDetailViewController:
    BaseViewController,
    ReactorKit.View,
    StoreDetailCoordinator
{
    private let storeDetailView = StoreDetailView()
    private let storeDetailReactor: StoreDetailReactor
    private weak var coordinator: StoreDetailCoordinator?
    private lazy var imagePicker = UIImagePickerController().then {
        $0.delegate = self
    }
    private var storeDetailCollectionViewDataSource
    : RxCollectionViewSectionedReloadDataSource<StoreDetailSectionModel>!
    
    init(storeId: Int) {
        self.storeDetailReactor = StoreDetailReactor(
            storeId: storeId,
            userDefaults: UserDefaultsUtil(),
            locationManager: LocationManager.shared,
            storeService: StoreService(),
            reviewService: ReviewService(),
            bookmarkService: BookmarkService(),
            gaManager: GAManager.shared,
            globalState: GlobalState.shared
        )
        super.init(nibName: nil, bundle: nil)
        self.setupDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func instance(storeId: Int) -> StoreDetailViewController {
        return StoreDetailViewController(storeId: storeId).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    override func loadView() {
        self.view = self.storeDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = self.storeDetailReactor
        self.coordinator = self
        self.storeDetailReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.storeDetailView.backButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.presenter.navigationController?
                    .popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.storeDetailReactor.presentDeleteModalPublisher
            .asDriver(onErrorJustReturn: -1)
            .drive { [weak self] storeId in
                self?.coordinator?.showDeleteModal(storeId: storeId)
            }
            .disposed(by: self.eventDisposeBag)
        
        self.storeDetailReactor.shareToKakaoPublisher
            .asDriver(onErrorJustReturn: Store())
            .drive(onNext: { [weak self] store in
                self?.coordinator?.shareToKakao(store: store)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.storeDetailReactor.presentVisitHistoriesPublisher
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] visitHistories in
                self?.coordinator?.showVisitHistories(visitHistories: visitHistories)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.storeDetailReactor.pushModifyPublisher
            .asDriver(onErrorJustReturn: Store())
            .drive(onNext: { [weak self] store in
                self?.coordinator?.goToModify(store: store)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.storeDetailReactor.presentPhotoDetailPublisher
            .asDriver(onErrorJustReturn: (0, 0, []))
            .drive(onNext: { [weak self] storeId, index, photos in
                self?.coordinator?.showPhotoDetail(storeId: storeId, index: index, photos: photos)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.storeDetailReactor.presentAddPhotoActionSheetPublisher
            .asDriver(onErrorJustReturn: 0)
            .drive { [weak self] storeId in
                self?.coordinator?.showPictureActionSheet(storeId: storeId)
            }
            .disposed(by: self.eventDisposeBag)
        
        self.storeDetailReactor.presentPhotoListPublisher
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] storeId in
                self?.coordinator?.goToPhotoList(storeId: storeId)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.storeDetailReactor.presentReviewModalPublisher
            .asDriver(onErrorJustReturn: (0, nil))
            .drive(onNext: { [weak self] storeId, review in
                self?.coordinator?.showReviewModal(storeId: storeId, review: review)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.storeDetailReactor.presentVisitPublisher
            .asDriver(onErrorJustReturn: Store())
            .drive(onNext: { [weak self] store in
                self?.coordinator?.showVisit(store: store)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.storeDetailReactor.showLoadingPublisher
            .asDriver(onErrorJustReturn: true)
            .drive { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            }
            .disposed(by: self.eventDisposeBag)
        
        self.storeDetailReactor.showErrorAlertPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive { [weak self] error in
                if let baseError = error as? BaseError,
                   case .errorContainer(let responseContainer) = baseError,
                   responseContainer.resultCode == "NF002" {
                    self?.coordinator?.showNotFoundError(message: responseContainer.message)
                } else {
                    self?.coordinator?.showErrorAlert(error: error)
                }
            }
            .disposed(by: self.eventDisposeBag)
        
        self.storeDetailReactor.showToastPublisher
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] message in
                guard let self = self else { return }
                
                self.coordinator?.showToast(
                    message: message,
                    baseView: self.storeDetailView.bottomBar
                )
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: StoreDetailReactor) {
        // Bind Action
        self.storeDetailView.bottomBar.rx.tapBookmark
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapBookmark }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.storeDetailView.bottomBar.rx.tapVisit
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapVisit }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.storeDetailView.collectionView.rx.itemSelected
            .filter { StreetFoodStoreDetailSection(sectionIndex: $0.section) == .photos }
            .map { Reactor.Action.tapPhoto(row: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        // Bind State
        reactor.state
            .map { $0.store }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: Store())
            .drive(self.storeDetailView.rx.store)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.store.isBookmarked }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(self.storeDetailView.bottomBar.rx.isBookmarked)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { [
                StoreDetailSectionModel(overView: $0.store),
                StoreDetailSectionModel(visitOverview: $0.store.visitHistory),
                StoreDetailSectionModel(info: $0.store),
                StoreDetailSectionModel(menu: $0.store),
                StoreDetailSectionModel(photo: $0.store),
                StoreDetailSectionModel(review: $0.store, userId: $0.userId)
            ] }
            .asDriver(onErrorJustReturn: [])
            .drive(self.storeDetailView.collectionView.rx.items(
                dataSource: self.storeDetailCollectionViewDataSource
            ))
            .disposed(by: self.disposeBag)
    }
    
    private func setupDataSource() {
        self.storeDetailCollectionViewDataSource
        = RxCollectionViewSectionedReloadDataSource<StoreDetailSectionModel>(
            configureCell: { _, collectionView, indexPath, item in
                switch item {
                case .overView(let store):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StoreOverviewCollectionViewCell.registerId,
                        for: indexPath
                    ) as? StoreOverviewCollectionViewCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(store: store)
                    cell.currentLocationButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapCurrentLocation }
                        .bind(to: self.storeDetailReactor.action)
                        .disposed(by: cell.disposeBag)
                    cell.bookmarkButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapBookmark }
                        .bind(to: self.storeDetailReactor.action)
                        .disposed(by: cell.disposeBag)
                    cell.shareButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapShare }
                        .bind(to: self.storeDetailReactor.action)
                        .disposed(by: cell.disposeBag)
                    cell.deleteRequestButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapDeleteRequest }
                        .bind(to: self.storeDetailReactor.action)
                        .disposed(by: cell.disposeBag)
                    
                    self.storeDetailReactor.moveCameraPublisher
                        .asDriver(onErrorJustReturn: CLLocation())
                        .drive(onNext: { [weak cell] location in
                            cell?.moveToPosition(
                                latitude: location.coordinate.latitude,
                                longitude: location.coordinate.longitude)
                        })
                        .disposed(by: cell.disposeBag)
                    
                    return cell
                    
                case .visitHistory(let visitOverview):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StoreVisitHistoryCollectionViewCell.registerId,
                        for: indexPath
                    ) as? StoreVisitHistoryCollectionViewCell else {
                        return BaseCollectionViewCell()
                    }
                    
                    cell.bind(visitOverview: visitOverview)
                    cell.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapVisitHistory }
                        .bind(to: self.storeDetailReactor.action)
                        .disposed(by: cell.disposeBag)
                    return cell
                    
                case .info(let store):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StoreInfoCollectionViewCell.registerId,
                        for: indexPath
                    ) as? StoreInfoCollectionViewCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(store: store)
                    return cell
                    
                case .menu(let store):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StoreMenuCollectionViewCell.registerId,
                        for: indexPath
                    ) as? StoreMenuCollectionViewCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(store: store)
                    return cell
                    
                case .photo(let store):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StorePhotoCollectionViewCell.registerId,
                        for: indexPath
                    ) as? StorePhotoCollectionViewCell else { return BaseCollectionViewCell() }
                    
                    if store.images.isEmpty {
                        cell.bind(image: nil, isLast: false, count: store.images.count)
                    } else {
                        let image = store.images[indexPath.row]
                        
                        cell.bind(
                            image: image,
                            isLast: indexPath.row == 3,
                            count: store.images.count
                        )
                    }
                    
                    return cell
                    
                case .advertisement:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StoreAdCollectionViewCell.registerId,
                        for: indexPath
                    ) as? StoreAdCollectionViewCell else { return BaseCollectionViewCell() }
                    
                    cell.adBannerView.rootViewController = self
                    return cell
                    
                case .reivew(let review, let userId):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StoreReviewCollectionViewCell.registerId,
                        for: indexPath
                    ) as? StoreReviewCollectionViewCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(review: review, userId: userId)
                    cell.moreButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .asDriver(onErrorJustReturn: ())
                        .drive(onNext: { [weak self] in
                            self?.coordinator?.showMoreActionSheet(
                                review: review,
                                onTapModify: {
                                    self?.storeDetailReactor.action.onNext(
                                        .tapEditReview(row: indexPath.row - 1)
                                    )
                                },
                                onTapDelete: {
                                    self?.storeDetailReactor.action.onNext(
                                        .deleteReview(row: indexPath.row - 1)
                                    )
                                }
                            )
                        }).disposed(by: cell.disposeBag)
                    return cell
                }
            })
        
        self.storeDetailCollectionViewDataSource.configureSupplementaryView
        = { datasource, collectionView, kind, indexPath -> UICollectionReusableView in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: StoreDetailHeaderView.registerId,
                    for: indexPath
                ) as? StoreDetailHeaderView else { return UICollectionReusableView() }
                
                switch StreetFoodStoreDetailSection(sectionIndex: indexPath.section) {
                case .info:
                    if case .overView(let store) = datasource.sectionModels.first?.items.first,
                       let updatedAt = store.updatedAt {
                        let rightText = DateUtils.toUpdatedAtFormat(dateString: updatedAt)
                        
                        headerView.bind(
                            type: StoreDetailHeaderType.info,
                            rightText: rightText
                        )
                    }
                    headerView.rightButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapEditStore }
                        .bind(to: self.storeDetailReactor.action)
                        .disposed(by: headerView.disposeBag)

                case .photos:
                    if case .overView(let store) = datasource.sectionModels.first?.items.first {
                        let photoCount = store.images.count
                        
                        headerView.bind(
                            type: StoreDetailHeaderType.photo,
                            rightText: "\(photoCount)개"
                        )
                    }
                    headerView.rightButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapAddPhoto }
                        .bind(to: self.storeDetailReactor.action)
                        .disposed(by: headerView.disposeBag)

                case .reviewAndadvertisement:
                    if case .overView(let store) = datasource.sectionModels.first?.items.first {
                        let reviewCount = store.reviews.count
                        
                        headerView.bind(
                            type: StoreDetailHeaderType.review,
                            rightText: "\(reviewCount)개"
                        )
                    }
                    headerView.rightButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapWriteReview }
                        .bind(to: self.storeDetailReactor.action)
                        .disposed(by: headerView.disposeBag)

                default:
                    break
                }

                return headerView
                
            default:
                return UICollectionReusableView()
            }
        }
    }
}

extension StoreDetailViewController: DeleteModalDelegate {
    func onRequest() {
        self.coordinator?.presenter.navigationController?.popViewController(animated: true)
    }
}

extension StoreDetailViewController: UIImagePickerControllerDelegate,
                                     UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.storeDetailReactor.action.onNext(.registerPhoto(photo))
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension StoreDetailViewController: SPPermissionsDelegate {
    func didAllow(permission: SPPermission) {
        if permission == .camera {
            self.coordinator?.showCamera()
        } else if permission == .photoLibrary {
            self.storeDetailReactor.action.onNext(.tapAddPhoto)
        }
    }
    
    func deniedData(for permission: SPPermission) -> SPPermissionDeniedAlertData? {
        let data = SPPermissionDeniedAlertData()
        
        data.alertOpenSettingsDeniedPermissionTitle = "permission_denied_title".localized
        data.alertOpenSettingsDeniedPermissionDescription
        = "permission_denied_description".localized
        data.alertOpenSettingsDeniedPermissionButtonTitle = "permission_setting_button".localized
        data.alertOpenSettingsDeniedPermissionCancelTitle = "permission_setting_cancel".localized
        return data
    }
}
// swiftlint:enable cyclomatic_complexity
