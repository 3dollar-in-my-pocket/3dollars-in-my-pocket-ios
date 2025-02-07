import UIKit
import MapKit

import DesignSystem
import Then
import Common
import Log
import Model

final class BossStoreDetailViewController: BaseViewController {
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private let backButton = UIButton().then {
        $0.setImage(Icons.arrowLeft.image.withTintColor(Colors.gray100.color), for: .normal)
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
        $0.delegate = self
    }

    private lazy var dataSource = BossStoreDetailDataSource(collectionView: collectionView, containerVC: self, viewModel: viewModel)

    private let bottomStickyView = BottomStickyView()

    private let closedStoreButton = UIButton().then {
        $0.setTitle("지금은 준비중이에요! 🧑‍🍳", for: .normal)
        $0.titleLabel?.font = Fonts.semiBold.font(size: 14)
        $0.setTitleColor(Colors.systemWhite.color, for: .normal)
        $0.backgroundColor = Colors.gray100.color
        $0.contentEdgeInsets = .init(top: 10, left: 16, bottom: 10, right: 16)
        $0.layer.cornerRadius = 20
        $0.isUserInteractionEnabled = false
    }

    private let viewModel: BossStoreDetailViewModel

    public static func instance(storeId: String) -> BossStoreDetailViewController {
        return BossStoreDetailViewController(storeId: storeId)
    }

    public init(storeId: String) {
        self.viewModel = BossStoreDetailViewModel(storeId: storeId)

        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        viewModel.input.firstLoad.send()
    }

    private func setupUI() {
        view.backgroundColor = Colors.systemWhite.color

        view.addSubViews([
            backButton,
            collectionView,
            bottomStickyView,
            closedStoreButton
        ])

        backButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }

        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalTo(backButton.snp.bottom).offset(16)
            $0.right.equalToSuperview()
            $0.bottom.equalTo(bottomStickyView.snp.top)
        }

        bottomStickyView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(BottomStickyView.Layout.height)
        }

        closedStoreButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(bottomStickyView.snp.top).offset(-8)
        }

        bottomStickyView.visitButton.setTitle("리뷰 남기기", for: .normal)
    }

    override func bindEvent() {
        super.bindEvent()

        // Input
        backButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)

        bottomStickyView.saveButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapSave)
            .store(in: &cancellables)

        bottomStickyView.visitButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapReviewWriteButton)
            .store(in: &cancellables)

        // Output
        viewModel.output.showLoading
            .removeDuplicates()
            .main
            .sink { LoadingManager.shared.showLoading(isShow: $0) }
            .store(in: &cancellables)

        viewModel.output.toast
            .main
            .sink { ToastManager.shared.show(message: $0) }
            .store(in: &cancellables)

        viewModel.output.dataSource
            .main
            .withUnretained(self)
            .sink { owner, sections in
                owner.dataSource.reloadData(sections)
            }
            .store(in: &cancellables)
        
        viewModel.output.isHiddenClosedStoreButton
            .main
            .assign(to: \.isHidden, on: closedStoreButton)
            .store(in: &cancellables)

        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .openUrl(let url):
                    UIApplication.shared.open(url)
                case .presentMapDetail(let viewModel):
                    owner.presentMapDetail(viewModel)
                case .presentNavigation:
                    owner.presentNavigationModal()
                case .presentFeedback(let viewModel):
                    let viewController = BossStoreFeedbackViewController(viewModel)
                    owner.present(viewController, animated: true)
                case .pushPostList(let viewModel):
                    let viewController = BossStorePostListViewController(viewModel: viewModel)
                    owner.navigationController?.pushViewController(viewController, animated: true)
                case .presentBossPhotoDetail(let viewModel):
                    owner.presentBossStorePhoto(viewModel: viewModel)
                case .navigateAppleMap(let location):
                    owner.navigateAppleMap(location: location)
                case .showErrorAlert(let error):
                    owner.showErrorAlert(error: error)
                case .presentReviewWrite(let viewModel):
                    let viewController = ReviewWriteViewController(viewModel: viewModel)
                    owner.navigationController?.pushViewController(viewController, animated: true)
                case .presentReportBottomSheetReview(let viewModel):
                    let viewController = ReportReviewBottomSheetViewController.instance(viewModel: viewModel)
                    owner.presentPanModal(viewController)
                case .pushReviewList(let viewModel):
                    let viewController = ReviewListViewControlelr.instance(viewModel: viewModel)
                    owner.navigationController?.pushViewController(viewController, animated: true)
                case .pushFeedbackList(let data):
                    let viewController = BossStoreFeedbackListViewController.instance(data)
                    owner.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            .store(in: &cancellables)

        viewModel.output.isFavorited
            .main
            .withUnretained(self)
            .sink { owner, isSaved in
                owner.bottomStickyView.setSaved(isSaved)
            }
            .store(in: &cancellables)

        viewModel.output.updateHeight
            .main
            .withUnretained(self)
            .sink { owner, _ in
                owner.collectionView.collectionViewLayout.invalidateLayout()
            }
            .store(in: &cancellables)
        
        viewModel.output.error
            .main
            .withUnretained(self)
            .sink { (owner: BossStoreDetailViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset.bottom = 32
        return layout
    }

    private func presentNavigationModal() {
        let alertController = UIAlertController(
            title: Strings.NavigationBottomSheet.title,
            message: Strings.NavigationBottomSheet.message,
            preferredStyle: .actionSheet
        )
        let naverAction = UIAlertAction(
            title: Strings.NavigationBottomSheet.Action.naverMap,
            style: .default
        ) { [weak self] _ in
            self?.viewModel.input.didTapNavigationAction.send(.naver)
        }
        let kakaoAction = UIAlertAction(
            title: Strings.NavigationBottomSheet.Action.kakaoMap,
            style: .default
        ) { [weak self] _ in
            self?.viewModel.input.didTapNavigationAction.send(.kakao)
        }
        let appleAction = UIAlertAction(
            title: Strings.NavigationBottomSheet.Action.appleMap,
            style: .default
        ) { [weak self] _ in
            self?.viewModel.input.didTapNavigationAction.send(.apple)
        }
        let cancelAction = UIAlertAction(title: Strings.NavigationBottomSheet.Action.cancel, style: .cancel)

        alertController.addAction(naverAction)
        alertController.addAction(kakaoAction)
        alertController.addAction(appleAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    private func presentMapDetail(_ viewModel: MapDetailViewModel) {
        let viewController = MapDetailViewController(viewModel: viewModel)

        present(viewController, animated: true)
    }
    
    private func navigateAppleMap(location: LocationResponse) {
        let latitude: CLLocationDegrees = location.latitude
        let longitude: CLLocationDegrees = location.longitude
        let destinationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: destinationCoordinate)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = "목적지"
        
        let options = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,  // 운전 모드
            MKLaunchOptionsShowsTrafficKey: true  // 교통 상황 표시
        ] as [String : Any]
        
        mapItem.openInMaps(launchOptions: options)
    }
}

extension BossStoreDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let containerWidth = UIScreen.main.bounds.width
        let width = containerWidth - 40

        switch dataSource.itemIdentifier(for: indexPath) {
        case .overview:
            return CGSize(width: width, height: StoreDetailOverviewCell.Layout.height)
        case .info(let viewModel):
            return CGSize(width: width, height: BossStoreInfoCell.Layout.calculateHeight(width: width, info: viewModel.output.info))
        case .menuList(let viewModel):
            return CGSize(width: width, height: BossStoreMenuListCell.Layout.height(viewModel: viewModel))
        case .emptyMenu:
            return CGSize(width: width, height: BossStoreEmptyMenuCell.Layout.height)
        case .workday:
            return CGSize(width: width, height: BossStoreWorkdayCell.Layout.height)
        case .post(let viewModel):
            return CGSize(width: width, height: BossStorePostCell.Layout.calculateHeight(viewModel: viewModel, width: width))
        case .reviewRating:
            return CGSize(width: width, height: StoreDetailRatingCell.Layout.height)
        case .reviewEmpty:
            return CGSize(width: width, height: StoreDetailReviewEmptyCell.Layout.height)
        case .reviewMore:
            return CGSize(width: width, height: StoreDetailReviewMoreCell.Layout.height)
        case .review(let viewModel):
            return BossStoreDetailReviewCell.Layout.size(width: containerWidth, viewModel: viewModel)
        case .reviewFeedbackSummary(let viewModel):
            return CGSize(width: width, height: BossStoreDetailReviewFeedbackSummaryCell.Layout.height(viewModel))
        case .filteredReview:
            return CGSize(width: width, height: 76)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch dataSource.sectionIdentifier(section: section)?.type {
        case .review: return CGSize(width: collectionView.frame.width, height: 40)
        default: return .zero
        }
    }
}

// MARK: Route
extension BossStoreDetailViewController {
    private func presentBossStorePhoto(viewModel: BossStorePhotoViewModel) {
        let viewController = BossStorePhotoViewController(viewModel: viewModel)
        
        present(viewController, animated: true)
    }
}
