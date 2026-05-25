import UIKit
import Combine

import Common
import DesignSystem
import Model

import NMapsMap
import Then
import PanModal
import Log
import Kingfisher
import Feed
import CombineCocoa
import FloatingPanel

public final class HomeViewController: BaseViewController {
    public override var screenName: ScreenName {
        return viewModel.output.screenName
    }

    public var currentAddress: String {
        viewModel.currentAddress
    }

    public var focusedPosition: CLLocation? {
        viewModel.focusedPosition
    }

    private lazy var homeView = HomeView(homeFilterSelectable: viewModel)
    private let viewModel = HomeViewModel()
    private var markers: [NMFMarker?] = []
    private var bottomSheetViewController: HomeListViewController?
    private var bottomSheetController: FloatingPanelController?
    private var storePreviewBottomSheet: StorePreviewBottomSheetViewController?
    private var storePreviewBottomSheetController: FloatingPanelController?

    private var isFirstLoad = true
    fileprivate let transition = SearchTransition()

    public init() {
        super.init(nibName: nil, bundle: nil)

        tabBarItem = UITabBarItem(
            title: nil,
            image: DesignSystemAsset.Icons.homeSolid.image,
            tag: TabBarTag.home.rawValue
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public static func instance() -> UINavigationController {
        let viewController = HomeViewController()

        return UINavigationController(rootViewController: viewController).then {
            $0.isNavigationBarHidden = true
            $0.interactivePopGestureRecognizer?.delegate = nil
        }
    }

    public override func loadView() {
        view = homeView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        homeView.mapView.addCameraDelegate(delegate: self)
        homeView.startFeedButtonAnimation()
        installBottomSheet()
        viewModel.input.viewDidLoad.send(())
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isFirstLoad {
            isFirstLoad = false

            let distance = homeView.mapView
                .contentBounds
                .boundsLatLngs[0]
                .distance(to: homeView.mapView.contentBounds.boundsLatLngs[1])

            viewModel.input.onMapLoad.send(distance / 3)
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 미리보기 패널은 tabBarController 에 부착되어 다른 탭에서도 살아있다.
        // Home 이 다시 노출되면 패널을 다시 보이게 한다.
        storePreviewBottomSheetController?.view.isHidden = false
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 다른 탭/모달/푸시로 가려질 때 미리보기 패널이 위에 떠 있지 않도록 가린다.
        storePreviewBottomSheetController?.view.isHidden = true
    }

    public override func sendPageView() {
        super.sendPageView()

        if isFirstLoad.isNot {
            LogManager.shared.sendEvent(event: CustomEvent(screen: screenName, name: .homeReopen))
        }
    }

    private func setupNavigation() {
        navigationController?.isNavigationBarHidden = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    public override func bindViewModelInput() {
        homeView.addressButton.tap
            .mapVoid
            .subscribe(viewModel.input.onTapSearchAddress)
            .store(in: &cancellables)

        homeView.researchButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapResearch)
            .store(in: &cancellables)

        homeView.currentLocationButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapCurrentLocation)
            .store(in: &cancellables)

        homeView.researchButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapResearch)
            .store(in: &cancellables)

        homeView.mapView.locationOverlay.touchHandler = { [weak self] _ in
            self?.viewModel.input.onTapCurrentMarker.send(())
            return true
        }

        homeView.homeFilterCollectionView.onLoadFilter = { [weak self] in
            self?.viewModel.input.onLoadFilter.send(())
        }

        homeView.feedButton
            .tapPublisher
            .mapVoid
            .subscribe(viewModel.input.didTapFeedButton)
            .store(in: &cancellables)
    }

    public override func bindViewModelOutput() {
        viewModel.output.address
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, address in
                owner.homeView.addressButton.bind(address: address)
            }
            .store(in: &cancellables)

        viewModel.output.isHiddenResearchButton
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, isHidden in
                owner.homeView.setHiddenResearchButton(isHidden: isHidden)
            }
            .store(in: &cancellables)

        viewModel.output.cameraPosition
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, location in
                owner.homeView.moveCamera(location: location)
            }
            .store(in: &cancellables)

        viewModel.output.advertisementMarker
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, advertisement: AdvertisementResponse) in
                owner.homeView.setAdvertisementMarker(advertisement)
            }
            .store(in: &cancellables)

        viewModel.output.bottomSheetCards
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, cards: [any HomeListCardComponent]) in
                owner.bottomSheetViewController?.updateCards(cards)
            }
            .store(in: &cancellables)

        viewModel.output.markerCards
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, cards: [HomeListBasicCardResponse]) in
                owner.updateMarkers(cards: cards)
            }
            .store(in: &cancellables)

        viewModel.output.scrollBottomSheetToIndex
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, index: Int) in
                owner.bottomSheetViewController?.scrollToCard(at: index)
            }
            .store(in: &cancellables)

        viewModel.output.showLoading
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { _, isShow in
                LoadingManager.shared.showLoading(isShow: isShow)
            }
            .store(in: &cancellables)

        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner: HomeViewController, route) in
                switch route {
                case .presentCategoryFilter(let viewModel):
                    let categoryFilterViewController = CategoryFilterViewController(viewModel: viewModel)
                    owner.presentPanModal(categoryFilterViewController)

                case .presentVisit(let store):
                    let storeId = Int(store.storeId) ?? 0
                    owner.presentVisit(storeId: storeId)

                case .presentPolicy:
                    owner.presentPolicy()

                case .presentMarkerAdvertisement:
                    owner.presentMarkerPopup()

                case .presentStorePreview(let storeId, let latitude, let longitude):
                    owner.presentStorePreview(storeId: storeId, latitude: latitude, longitude: longitude)

                case .dismissStorePreview:
                    owner.dismissStorePreview()

                case .presentSearchAddress(let viewModel):
                    owner.presentSearchAddress(viewModel)

                case .presentAccountInfo(let viewModel):
                    owner.presentAccountInfo(viewModel: viewModel)
                case .showErrorAlert(let error):
                    if error is LocationError {
                        owner.showDenyAlert()
                    } else {
                        owner.showErrorAlert(error: error)
                    }

                case .deepLink(let link):
                    Environment.appModuleInterface.deepLinkHandler.handleLinkResponse(link)
                case .presentFeedList(let viewModel):
                    owner.presentFeedList(viewModel: viewModel)
                }
            }
            .store(in: &cancellables)

        viewModel.output.isShowFilterTooltip
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, isShow: Bool) in
                owner.homeView.showFilterTooltiop(isShow: isShow)
            }
            .store(in: &cancellables)
    }

    // MARK: Bottom Sheet
    private func installBottomSheet() {
        guard bottomSheetController == nil else { return }
        let bottomSheetVM = HomeListViewModel()
        let viewController = HomeListViewController(viewModel: bottomSheetVM)

        // 바텀시트 → 홈 ViewModel 단방향 릴레이.
        bottomSheetVM.output.didTapCardAt
            .subscribe(viewModel.input.bottomSheetDidTapCard)
            .store(in: &cancellables)
        bottomSheetVM.output.willLoadMore
            .subscribe(viewModel.input.bottomSheetWillLoadMore)
            .store(in: &cancellables)

        let fpc = FloatingPanelController()
        fpc.layout = HomeListLayout()
        fpc.delegate = self
        fpc.set(contentViewController: viewController)
        fpc.track(scrollView: viewController.trackingScrollView)
        fpc.isRemovalInteractionEnabled = false

        // surface 디자인 (둥근 상단 / 흰 배경 / 그림자) 은 FloatingPanel 이 처리.
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 16
        appearance.backgroundColor = Colors.systemWhite.color
        fpc.surfaceView.appearance = appearance
        fpc.surfaceView.grabberHandle.isHidden = true

        // 시트 외부 영역(지도) 의 터치를 가로채지 않도록 backdrop 을 비활성화.
        // FloatingPanelPassThroughView 가 surface 외 영역의 hit 을 부모(지도) 로 전달.
        fpc.backdropView.isUserInteractionEnabled = false
        fpc.backdropView.backgroundColor = .clear

        fpc.addPanel(toParent: self)
        bringTopChromeToFront()

        bottomSheetViewController = viewController
        bottomSheetController = fpc
    }

    /// 상단 배경/주소/필터 chrome 을 HomeList 패널 위로 끌어올린다.
    /// panel surface 의 상단 그림자가 주소/필터 영역에 비쳐 화면이 분리돼 보이는 것을 막기 위함이다.
    /// addPanel(toParent:) 은 패널 뷰를 homeView 서브뷰 스택 최상단에 삽입하므로,
    /// 패널을 (재)부착할 때마다 호출해 chrome 이 항상 패널보다 높은 z-order 를 유지하도록 한다.
    /// (배경이 먼저, 버튼이 나중에 와야 버튼이 배경 위에 보인다)
    private func bringTopChromeToFront() {
        homeView.bringSubviewToFront(homeView.topBackgroundView)
        homeView.bringSubviewToFront(homeView.addressButton)
        homeView.bringSubviewToFront(homeView.homeFilterCollectionView)
    }

    // MARK: Markers
    private func updateMarkers(cards: [HomeListBasicCardResponse]) {
        // 기존 마커 모두 제거 후 재생성. 카드 수가 많지 않고 갱신 빈도가 낮아 단순 재구성으로 충분.
        clearMarker()
        for (index, card) in cards.enumerated() {
            guard let cardMarker = card.marker else { continue }
            let nmfMarker = NMFMarker()
            nmfMarker.position = NMGLatLng(
                lat: cardMarker.location.latitude,
                lng: cardMarker.location.longitude
            )
            nmfMarker.iconImage = NMFOverlayImage(name: "")
            nmfMarker.touchHandler = { [weak self] _ in
                self?.viewModel.input.onTapMarker.send(index)
                return true
            }
            nmfMarker.mapView = homeView.mapView
            markers.append(nmfMarker)

            // 비동기로 unfocused 칩 이미지 렌더 후 마커에 반영.
            applyMarkerIcon(chip: cardMarker.unfocused, to: nmfMarker)
        }
    }

    private func applyMarkerIcon(chip: SDChip, to marker: NMFMarker) {
        marker.captionText = chip.text?.text ?? ""
        marker.captionColor = chip.text.flatMap { UIColor(hex: $0.fontColor) } ?? Colors.gray100.color
        marker.captionTextSize = 12
        marker.captionAligns = [NMFAlignType.bottom]

        guard let sdImage = chip.image, let url = URL(string: sdImage.url) else { return }
        ImageDownloader.default.downloadImage(with: url) { [weak marker] result in
            guard let marker, case .success(let value) = result else { return }
            DispatchQueue.main.async {
                marker.iconImage = NMFOverlayImage(image: value.image)
                marker.width = sdImage.style.width
                marker.height = sdImage.style.height
            }
        }
    }

    private func clearMarker() {
        for marker in self.markers {
            marker?.mapView = nil
        }
        markers.removeAll()
    }

    // MARK: Routing helpers
    private func showDenyAlert() {
        AlertUtils.showWithAction(
            viewController: self,
            title: HomeStrings.locationDenyTitle,
            message: HomeStrings.locationDenyDescription
        ) {
        }
    }

    private func goToAppSetting() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }

    private func pushStoreDetail(storeId: Int) {
        let viewController = Environment.storeInterface.getStoreDetailViewController(storeId: storeId)

        tabBarController?.navigationController?.pushViewController(viewController, animated: true)
    }

    private func pushBossStoreDetail(storeId: String) {
        let viewController = Environment.storeInterface.getBossStoreDetailViewController(storeId: storeId, shouldPushReviewList: false)

        tabBarController?.navigationController?.pushViewController(viewController, animated: true)
    }

    private func presentVisit(storeId: Int) {
        let viewController = Environment.storeInterface.getVisitViewController(storeId: storeId) { [weak self] in
            // 방문 인증 성공 시 미리보기 시트를 최신 데이터로 갱신한다. (없으면 nil-safe 하게 무시)
            self?.storePreviewBottomSheet?.reload()
        }

        tabBarController?.present(viewController, animated: true)
    }

    private func presentSearchAddress(_ viewModel: SearchAddressViewModel) {
        let viewController = SearchAddressViewController(viewModel: viewModel)

        tabBarController?.present(viewController, animated: true, completion: nil)
    }

    private func presentMarkerPopup() {
        let viewController = MarkerPopupViewController()

        tabBarController?.present(viewController, animated: true)
    }

    private func presentPolicy() {
        let viewController = Environment.membershipInterface.createPolicyViewController()

        tabBarController?.present(viewController, animated: true)
    }

    private func presentAccountInfo(viewModel: BaseViewModel) {
        guard let viewController = Environment.membershipInterface.createAccountInfoViewController(viewModel: viewModel) else { return }

        tabBarController?.present(viewController, animated: true)
    }

    private func presentFeedList(viewModel: FeedListViewModel) {
        let viewController = FeedListViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .overCurrentContext
        navigationController.isNavigationBarHidden = true

        tabBarController?.present(navigationController, animated: true)
    }
}

extension HomeViewController: NMFMapViewCameraDelegate {
    public func mapView(
        _ mapView: NMFMapView,
        cameraWillChangeByReason reason: Int,
        animated: Bool
    ) {
        if reason == NMFMapChangedByGesture {
            let mapLocation = CLLocation(
                latitude: mapView.cameraPosition.target.lat,
                longitude: mapView.cameraPosition.target.lng
            )
            let distance = mapView
                .contentBounds
                .boundsLatLngs[0]
                .distance(to: mapView.contentBounds.boundsLatLngs[1])

            viewModel.input.changeMaxDistance.send(distance / 3)
            viewModel.input.changeMapLocation.send(mapLocation)
        }
    }

    public func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        if reason == NMFMapChangedByGesture {
            let mapLocation = CLLocation(
                latitude: mapView.cameraPosition.target.lat,
                longitude: mapView.cameraPosition.target.lng
            )
            let distance = mapView
                .contentBounds
                .boundsLatLngs[0]
                .distance(to: mapView.contentBounds.boundsLatLngs[1])

            viewModel.input.changeMaxDistance.send(distance / 3)
            viewModel.input.changeMapLocation.send(mapLocation)
        }
    }
}

// MARK: FloatingPanelControllerDelegate
extension HomeViewController: FloatingPanelControllerDelegate {
    public func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        // .tip → .full 사이 surface y 좌표로 진행도를 계산해 상단 배경 alpha 를 보간한다.
        let tipY = fpc.surfaceLocation(for: .tip).y
        let fullY = fpc.surfaceLocation(for: .full).y
        let range = tipY - fullY
        guard range > 0 else { return }

        let progress = (tipY - fpc.surfaceLocation.y) / range
        homeView.updateTopBackground(progress: progress)
    }

    public func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        // 끌어당기는 애니메이션 종료 시점에 진행도가 0/1 로 정확히 안착하도록 보정.
        switch fpc.state {
        case .full:
            homeView.updateTopBackground(progress: 1)
        case .tip:
            homeView.updateTopBackground(progress: 0)
        default:
            break
        }
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.maskView.frame = homeView.addressButton.frame

        return transition
    }

    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.maskOriginalFrame = homeView.addressButton.frame

        return transition
    }
}

// MARK: - Store Preview Bottom Sheet
extension HomeViewController {
    /// 마커 탭으로 미리보기 시트를 띄운다.
    /// - 이미 부착된 상태라면 ViewModel 만 갈아끼워 새 가게 정보로 갱신.
    /// - 처음이거나 닫힌 상태라면 HomeList 패널을 제거하고 StorePreview 패널을 self 에 부착.
    ///
    /// FloatingPanel.addPanel(toParent:) 가 UITabBarController 를 parent 로 허용하지 않고
    /// UIKit 의 view-controller hierarchy 정합성 검사가 layout/window-attach 단계에서도
    /// 재실행되기 때문에, fpc.view 를 tabBarController.view subtree 로 옮길 방법은 사실상 없다.
    /// 대신 StorePreview 가 노출되는 동안 탭바를 숨겨 시각적으로 패널이 탭바 위에 떠 있는 효과를 낸다
    /// (UIKit 의 hidesBottomBarWhenPushed 와 동일한 패턴).
    private func presentStorePreview(storeId: Int, latitude: Double, longitude: Double) {
        let config = StorePreviewBottomSheetViewModel.Config(
            storeId: storeId,
            latitude: latitude,
            longitude: longitude
        )
        let newViewModel = StorePreviewBottomSheetViewModel(config: config)

        // 부착된 상태(연속 마커 탭) 라면 VM 만 교체하고 종료.
        if let existing = storePreviewBottomSheet,
           storePreviewBottomSheetController?.parent != nil {
            existing.update(viewModel: newViewModel)
            return
        }

        let viewController = storePreviewBottomSheet ?? makeStorePreviewViewController(viewModel: newViewModel)
        if storePreviewBottomSheet != nil {
            // 이전에 닫혀 detached 된 VC 를 재사용하는 경우 VM 만 교체.
            viewController.update(viewModel: newViewModel)
        }
        let fpc = storePreviewBottomSheetController ?? makeStorePreviewPanelController(content: viewController)

        storePreviewBottomSheet = viewController
        storePreviewBottomSheetController = fpc

        // 순서가 중요: HomeList 패널 제거 → 탭바 숨김(.tip anchor 의 safeArea 계산이 새 값으로 굳음)
        // → StorePreview 패널 mount. 거꾸로 하면 패널이 부착된 뒤 safeArea 가 바뀌면서 미끄러져 보인다.
        bottomSheetController?.removePanelFromParent(animated: true)
        tabBarController?.tabBar.isHidden = true
        fpc.addPanel(toParent: self, animated: true)
        fpc.view.isHidden = false
    }

    private func dismissStorePreview() {
        guard let fpc = storePreviewBottomSheetController, fpc.parent != nil else { return }
        // 패널이 완전히 내려간 뒤 탭바를 복원하고 HomeList 를 다시 띄운다.
        // 슬라이드 다운 도중 탭바가 먼저 나타나면 패널이 탭바를 가로지르는 어색한 프레임이 생긴다.
        fpc.removePanelFromParent(animated: true) { [weak self] in
            guard let self else { return }
            self.tabBarController?.tabBar.isHidden = false
            if self.bottomSheetController?.parent == nil, let homeListPanel = self.bottomSheetController {
                homeListPanel.addPanel(toParent: self, animated: true)
                // 재부착으로 패널이 다시 최상단에 삽입되므로 상단 chrome 을 패널 위로 끌어올린다.
                self.bringTopChromeToFront()
            }
        }
    }

    private func makeStorePreviewViewController(
        viewModel: StorePreviewBottomSheetViewModel
    ) -> StorePreviewBottomSheetViewController {
        let viewController = StorePreviewBottomSheetViewController(viewModel: viewModel)
        wireStorePreviewCallbacks(viewController)
        return viewController
    }

    private func makeStorePreviewPanelController(
        content: UIViewController
    ) -> FloatingPanelController {
        let fpc = FloatingPanelController()
        fpc.layout = StorePreviewLayout()
        fpc.set(contentViewController: content)
        fpc.isRemovalInteractionEnabled = false

        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 16
        appearance.backgroundColor = Colors.systemWhite.color
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = .black
        shadow.opacity = 0.2
        shadow.offset = .zero
        shadow.radius = 10
        appearance.shadows = [shadow]
        fpc.surfaceView.appearance = appearance
        fpc.surfaceView.grabberHandle.isHidden = true

        // 시트 외부(지도) 터치는 backdrop 가 가로채지 않도록 비활성화.
        fpc.backdropView.isUserInteractionEnabled = false
        fpc.backdropView.backgroundColor = .clear

        return fpc
    }

    private func wireStorePreviewCallbacks(_ viewController: StorePreviewBottomSheetViewController) {
        viewController.onRequestPushStoreDetail = { [weak self] storeId in
            // 미리보기 패널은 닫지 않고 유지한다. 상세 push 중에는 Home 의
            // viewWillDisappear 가 패널을 가렸다가, pop 으로 돌아오면 다시 보여준다.
            self?.pushStoreDetail(storeId: storeId)
        }
        viewController.onRequestPresentVisit = { [weak self] storeId in
            self?.presentVisit(storeId: storeId)
        }
        viewController.onRequestPresentReviewWrite = { [weak self] storeId in
            self?.presentStorePreviewReviewWrite(storeId: storeId)
        }
        viewController.onRequestShare = { storeId, storeType, storeName, latitude, longitude in
            // 가게 상세 "공유하기"와 동일한 카카오 공유. 미리보기엔 overview 가 없어 이름/좌표만 받는 오버로드를 사용한다.
            // storeType 은 서버 extraParams 값(일반/사장님 가게)을 그대로 전달한다.
            Environment.appModuleInterface.shareKakao(
                storeId: storeId,
                storeType: storeType,
                storeName: storeName,
                latitude: latitude,
                longitude: longitude
            )
        }
        viewController.onRequestPresentNavigation = { [weak self] latitude, longitude, storeName in
            // 가게 상세 "길 안내"와 동일한 지도앱 선택 액션시트.
            self?.presentStorePreviewNavigation(latitude: latitude, longitude: longitude, storeName: storeName)
        }
        viewController.onRequestOpenLink = { link in
            // 방문 인증 등 서버가 내려준 딥링크/링크를 공용 핸들러로 위임한다. (예: /visit → 방문 인증 화면)
            Environment.appModuleInterface.deepLinkHandler.handleLinkResponse(link)
        }
        viewController.onRequestClose = { [weak self] in
            self?.dismissStorePreview()
        }
        viewController.onContentHeightChanged = { [weak self] height in
            self?.updateStorePreviewPanelHeight(height)
        }
    }

    private func updateStorePreviewPanelHeight(_ height: CGFloat) {
        guard let fpc = storePreviewBottomSheetController else { return }
        fpc.layout = StorePreviewLayout(visibleHeight: height)
        fpc.invalidateLayout()
    }

    /// 가게 상세 "리뷰쓰기"와 동일한 리뷰 작성 바텀시트(PanModal)를 띄운다.
    private func presentStorePreviewReviewWrite(storeId: Int) {
        let reviewViewController = Environment.storeInterface.getReviewBottomSheetViewController(storeId: storeId) { [weak self] in
            // 리뷰 작성 성공 시 미리보기 시트를 최신 데이터로 갱신한다.
            self?.storePreviewBottomSheet?.reload()
        }

        if let panModalViewController = reviewViewController as? (UIViewController & PanModalPresentable) {
            presentPanModal(panModalViewController)
        } else {
            present(reviewViewController, animated: true)
        }
    }

    /// 가게 상세 "길 안내"와 동일하게 지도앱(네이버/카카오/애플) 선택 액션시트를 띄우고 외부 앱으로 길찾기를 연다.
    private func presentStorePreviewNavigation(latitude: Double, longitude: Double, storeName: String) {
        let encodedName = storeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let bundleId = Bundle.main.bundleIdentifier ?? ""

        let alertController = UIAlertController(
            title: "길 안내 앱 선택",
            message: "지도앱이 설치되어있지 않은 경우 정상적으로 실행되지 않습니다.",
            preferredStyle: .actionSheet
        )
        alertController.addAction(UIAlertAction(title: "네이버 지도", style: .default) { _ in
            let urlString = "nmap://place?lat=\(latitude)&lng=\(longitude)&name=\(encodedName)&zoom=20&appname=\(bundleId)"
            guard let url = URL(string: urlString) else { return }
            UIApplication.shared.open(url)
        })
        alertController.addAction(UIAlertAction(title: "카카오 지도", style: .default) { _ in
            guard let url = URL(string: "kakaomap://look?p=\(latitude),\(longitude)") else { return }
            UIApplication.shared.open(url)
        })
        alertController.addAction(UIAlertAction(title: "애플 지도", style: .default) { _ in
            guard let url = URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=d") else { return }
            UIApplication.shared.open(url)
        })
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))

        present(alertController, animated: true)
    }
}
