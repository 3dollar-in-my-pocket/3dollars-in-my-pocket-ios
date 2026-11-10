import UIKit
import CoreLocation
import MapKit

import Common
import DesignSystem
import Model
import StoreInterface
import WriteInterface

import SnapKit

/// Store v2 SDUI 응답을 순서대로 전용 셀에 렌더링하는, Home에 임베드 가능한 상세 컨테이너.
/// 셀 등록·매핑은 공용 `StoreSectionsView` 가 맡고, 이 VC 는 상세 전용 동작(탭·하단 바·라우팅)만 다룬다.
public final class StoreSectionsViewController: BaseViewController {
    /// Home 바텀시트의 상단 chrome이 상세 컨텐츠 스크롤에 맞춰 fade-in 하는 데 사용한다.
    public var onScrollOffsetChanged: ((CGFloat) -> Void)?
    /// 전체 화면 컨테이너가 상단 네비게이션 타이틀과 공유 정보를 구성하는 데 사용한다.
    public var onStoreInformationChanged: ((SDText?, CLLocationCoordinate2D?) -> Void)?
    public var onSectionsLoaded: (() -> Void)?
    public var onFavoriteChanged: ((Bool) -> Void)?
    public var onRequestClose: (() -> Void)?

    private let viewModel: StoreSectionsViewModel
    private let sectionsView = StoreSectionsView(style: .detail)
    private let bottomActionBarView = StoreBottomActionBarView()
    private var storeIdDebugView: StoreIdDebugView?
    private var isBottomActionBarVisible = false
    private var previewItemIndex: Int?
    private var placeholderPreview: StoreScreenPreviewSection?
    private let loadsOnViewDidLoad: Bool
    private var hasRequestedLoad = false
    private var hasLoadedSections = false
    private var isDisplayed = false
    private var tabItemIndex: Int?
    private var tabTargetItemIndexes: [Int?] = []

    private var collectionView: UICollectionView {
        sectionsView.collectionView
    }

    init(
        viewModel: StoreSectionsViewModel,
        placeholderPreview: StoreScreenPreviewSection? = nil,
        loadsOnViewDidLoad: Bool = true
    ) {
        self.viewModel = viewModel
        self.placeholderPreview = placeholderPreview
        self.loadsOnViewDidLoad = loadsOnViewDidLoad
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(storeId: Int, latitude: Double, longitude: Double) {
        self.init(viewModel: StoreSectionsViewModel(config: .init(
            storeId: storeId,
            latitude: latitude,
            longitude: longitude
        )))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public var sectionsScrollView: UIScrollView {
        collectionView
    }

    public override func loadView() {
        let containerView = UIView()
        containerView.addSubViews([sectionsView, bottomActionBarView])
        sectionsView.snp.makeConstraints { $0.edges.equalToSuperview() }
        bottomActionBarView.snp.makeConstraints { $0.leading.trailing.bottom.equalToSuperview() }
        view = containerView
        setupStoreIdDebugViewIfNeeded(in: containerView)
    }

    private func setupStoreIdDebugViewIfNeeded(in containerView: UIView) {
        guard AppEnvironment.isDebugToolAvailable,
              Preference.shared.isShowStoreIdDebugView else { return }

        let debugView = StoreIdDebugView()
        debugView.bind(storeId: viewModel.storeId)
        debugView.onCopy = { storeId in
            UIPasteboard.general.string = storeId
            ToastManager.shared.show(message: "가게 ID \(storeId) 복사됨")
        }
        containerView.addSubview(debugView)
        debugView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalTo(bottomActionBarView.snp.top).offset(-8)
        }
        storeIdDebugView = debugView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        bottomActionBarView.alpha = 0
        bottomActionBarView.isHidden = true
        bottomActionBarView.onAction = { [weak self] in
            self?.viewModel.input.didSelectAction.send($0)
        }
        bindSectionsView()
        if loadsOnViewDidLoad {
            markSectionsDisplayed()
            loadSectionsIfNeeded()
        } else {
            applyPlaceholder()
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewBottomInset()
    }

    private func bindSectionsView() {
        sectionsView.rootViewController = self
        sectionsView.onAction = { [weak self] in
            self?.viewModel.input.didSelectAction.send($0)
        }
        sectionsView.onTapImageGallery = { [weak self] images, index in
            self?.viewModel.input.didTapImageGallery.send((images: images, index: index))
        }
        sectionsView.onClickAd = { [weak self] in
            self?.viewModel.input.didClickAd.send($0)
        }
        sectionsView.onTapThreadPostLink = { [weak self] url, clickLog in
            self?.viewModel.input.didTapThreadPostLink.send((url: url, clickLog: clickLog))
        }
        sectionsView.onImpression = { [weak self] in
            self?.viewModel.sendImpressionLog($0)
        }
        sectionsView.onScroll = { [weak self] scrollView in
            self?.onScrollOffsetChanged?(scrollView.contentOffset.y)
            self?.updateSelectedTabIfNeeded(scrollView)
            self?.updateBottomActionBarVisibility()
            self?.updateCollectionViewBottomInset()
        }
    }

    public func loadSectionsIfNeeded() {
        guard hasRequestedLoad.isNot else { return }
        reloadSections()
    }

    public func reloadSections() {
        hasRequestedLoad = true
        viewModel.input.load.send(())
    }

    public func updatePlaceholderPreview(_ preview: StoreScreenPreviewSection) {
        placeholderPreview = preview
        guard hasLoadedSections.isNot, isViewLoaded else { return }
        applyPlaceholder()
    }

    public func toggleFavorite() {
        viewModel.input.didTapFavorite.send(())
    }

    public func markSectionsDisplayed() {
        guard isDisplayed.isNot else { return }
        isDisplayed = true
        viewModel.input.didDisplay.send(())
        sectionsView.setDisplayed()
    }

    private func applyPlaceholder() {
        var sections: [any StoreSectionComponent] = []
        if let placeholderPreview {
            sections.append(placeholderPreview)
        }
        sections.append(StoreSkeletonSection())
        apply(sections, isPlaceholder: true)
    }

    public override func bindViewModelInput() { }

    public override func bindViewModelOutput() {
        viewModel.output.sections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                self?.apply(sections)
            }
            .store(in: &cancellables)

        viewModel.output.toast
            .receive(on: DispatchQueue.main)
            .sink { ToastManager.shared.show(message: $0) }
            .store(in: &cancellables)

        viewModel.output.isFavorited
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onFavoriteChanged?($0) }
            .store(in: &cancellables)

        viewModel.output.error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.showErrorAlert(error: $0) }
            .store(in: &cancellables)

        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.handle(route: $0) }
            .store(in: &cancellables)
    }

    private func apply(_ sections: [any StoreSectionComponent], isPlaceholder: Bool = false) {
        let title = sections
            .compactMap { ($0 as? StoreScreenPreviewSection)?.header.title }
            .first
        let location = sections
            .compactMap { ($0 as? StoreEditSection)?.map?.location }
            .first
            .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        onStoreInformationChanged?(title, location)

        updateTabTargets(sections)
        updateBottomActionBar(sections)
        sectionsView.apply(sections)
        updateBottomActionBarVisibility()
        if isPlaceholder.isNot {
            hasLoadedSections = true
            onSectionsLoaded?()
        }
    }

    private func updateBottomActionBar(_ sections: [any StoreSectionComponent]) {
        previewItemIndex = sections.firstIndex { $0 is StoreScreenPreviewSection }
        let actionBars = previewItemIndex
            .flatMap { sections[$0] as? StoreScreenPreviewSection }?
            .actionBars ?? []
        bottomActionBarView.bind(actionBars)
        bottomActionBarView.isHidden = actionBars.isEmpty
        view.setNeedsLayout()
    }

    private func updateCollectionViewBottomInset() {
        let coveringHeight = bottomActionBarView.isHidden ? 0 : bottomActionBarView.coveringHeight
        let appliedAdjustment = collectionView.adjustedContentInset.bottom - collectionView.contentInset.bottom
        let inset = StoreBottomActionBarView.Layout.bottomContentInset(
            coveringHeight: coveringHeight,
            appliedAdjustment: appliedAdjustment
        )

        guard abs(collectionView.contentInset.bottom - inset) > 0.5 else { return }
        collectionView.contentInset.bottom = inset
    }

    private func updateBottomActionBarVisibility() {
        guard bottomActionBarView.isHidden.isNot, let previewItemIndex else { return }
        let indexPath = IndexPath(item: previewItemIndex, section: 0)
        let visibleTop = collectionView.contentOffset.y + collectionView.adjustedContentInset.top
        let shouldShow: Bool
        if let cell = collectionView.cellForItem(at: indexPath) as? StoreScreenPreviewCell,
           let actionBarFrame = cell.actionBarFrame(in: collectionView) {
            shouldShow = actionBarFrame.minY < visibleTop
        } else if let attributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) {
            shouldShow = attributes.frame.maxY <= visibleTop
        } else {
            shouldShow = false
        }
        setBottomActionBarVisible(shouldShow)
    }

    private func setBottomActionBarVisible(_ isVisible: Bool) {
        guard isBottomActionBarVisible != isVisible else { return }
        isBottomActionBarVisible = isVisible
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.bottomActionBarView.alpha = isVisible ? 1 : 0
        }
    }

    private func updateTabTargets(_ sections: [any StoreSectionComponent]) {
        guard let tabIndex = sections.firstIndex(where: { $0 is StoreTabSection }),
              let tabSection = sections[tabIndex] as? StoreTabSection else {
            tabItemIndex = nil
            tabTargetItemIndexes = []
            return
        }
        tabItemIndex = tabIndex
        tabTargetItemIndexes = tabSection.tabs.map { tab in
            guard let link = tab.button.link?.link,
                  let fragment = URL(string: link)?.fragment else { return nil }
            return StoreSectionFragment.sectionIndex(for: fragment, in: sections)
        }
    }

    private func updateSelectedTabIfNeeded(_ scrollView: UIScrollView) {
        guard scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating,
              let tabItemIndex, tabTargetItemIndexes.isEmpty.isNot else { return }

        let topInset = scrollView.adjustedContentInset.top
        let tabBarBottomY = scrollView.contentOffset.y + topInset + StoreTabCell.Layout.height
        let maxOffsetY = scrollView.contentSize.height + scrollView.adjustedContentInset.bottom - scrollView.bounds.height
        let isAtBottom = scrollView.contentOffset.y >= maxOffsetY - 1

        var newIndex = 0
        for (tabIndex, itemIndex) in tabTargetItemIndexes.enumerated() {
            guard let itemIndex,
                  let attributes = collectionView.collectionViewLayout.layoutAttributesForItem(
                    at: IndexPath(item: itemIndex, section: 0)
                  ) else { continue }
            if attributes.frame.minY <= tabBarBottomY + 1 {
                newIndex = tabIndex
            }
        }
        if isAtBottom, let lastIndex = tabTargetItemIndexes.lastIndex(where: { $0 != nil }) {
            newIndex = lastIndex
        }

        guard newIndex != sectionsView.selectedTabIndex else { return }
        sectionsView.selectedTabIndex = newIndex
        let tabCell = collectionView.cellForItem(at: IndexPath(item: tabItemIndex, section: 0)) as? StoreTabCell
        tabCell?.setSelectedIndex(newIndex)
    }
}

// MARK: Route
private extension StoreSectionsViewController {
    func handle(route: StoreSectionsViewModel.Route) {
        switch route {
        case .presentWriteReview(let viewModel):
            presentPanModal(ReviewBottomSheetViewController.instance(viewModel: viewModel))
        case .presentMapDetail(let viewModel):
            present(MapDetailViewController(viewModel: viewModel), animated: true)
        case .presentUploadPhoto(let viewModel):
            present(UploadPhotoViewController.instance(viewModel: viewModel), animated: true)
        case .presentPhotoDetail(let viewModel):
            present(PhotoDetailViewController(viewModel: viewModel), animated: true)
        case .pushReviewList(let viewModel):
            navigationController?.pushViewController(ReviewListViewControlelr.instance(viewModel: viewModel), animated: true)
        case .pushStoreDetail(let storeId):
            let location = Preference.shared.userCurrentLocation.coordinate
            let viewController = StoreDetailFullScreenViewController(
                storeId: storeId,
                latitude: location.latitude,
                longitude: location.longitude
            )
            navigationController?.pushViewController(viewController, animated: true)
        case .presentCouponList:
            present(CouponTabViewController(viewModel: CouponTabViewModel()), animated: true)
        case .presentStoreReport(let viewModel):
            presentPanModal(ReportBottomSheetViewController.instance(viewModel: viewModel))
        case .presentReviewReport(let viewModel):
            presentPanModal(ReportReviewBottomSheetViewController.instance(viewModel: viewModel))
        case .pushEditStore(let viewModel):
            let viewController = Environment.writeInterface.createEditStoreViewController(viewModel: viewModel)
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        case .scrollToSection(let sectionType):
            scrollToSection(sectionType)
        case .presentNavigationActionSheet:
            presentNavigationModal()
        case .navigateAppleMap(let location):
            navigateAppleMap(location: location)
        case .presentBossStorePhoto(let viewModel):
            present(BossStorePhotoViewController(viewModel: viewModel), animated: true)
        case .presentShareSheet(let url):
            let activityViewController = UIActivityViewController(
                activityItems: [url],
                applicationActivities: nil
            )
            activityViewController.popoverPresentationController?.sourceView = view
            present(activityViewController, animated: true)
        case .openURL(let url):
            UIApplication.shared.open(url)
        case .copyToPasteboard(let text):
            UIPasteboard.general.string = text
        case .presentDeleteReviewAlert(let reviewId):
            AlertUtils.showWithCancel(
                viewController: self,
                message: Strings.ReviewList.Alert.delete
            ) { [weak self] in
                self?.viewModel.input.didConfirmDeleteReview.send(reviewId)
            }
        case .presentUseCouponAlert(let issuedKey):
            let alertViewController = BossStoreCouponAlertViewController { [weak self] in
                self?.viewModel.input.didConfirmUseCoupon.send(issuedKey)
            }
            present(alertViewController, animated: true)
        case .closeWithDeletedStore(let message):
            AlertUtils.showWithAction(
                viewController: self,
                message: message
            ) { [weak self] in
                self?.onRequestClose?()
            }
        case .closeAfterReport(let message):
            ToastManager.shared.show(message: message)
            onRequestClose?()
        }
    }

    func presentNavigationModal() {
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

    func navigateAppleMap(location: LocationResponse) {
        let destinationCoordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let placemark = MKPlacemark(coordinate: destinationCoordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "목적지"

        let options: [String: Any] = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
            MKLaunchOptionsShowsTrafficKey: true
        ]
        mapItem.openInMaps(launchOptions: options)
    }

    func scrollToSection(_ sectionType: StoreSectionType) {
        guard let index = sectionsView.itemIndex(where: { $0.type == sectionType }) else { return }
        let indexPath = IndexPath(item: index, section: 0)

        for _ in 0..<2 {
            guard let attributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) else { return }

            let topInset = collectionView.adjustedContentInset.top
            let minY = -topInset
            let maxY = max(
                collectionView.contentSize.height + collectionView.adjustedContentInset.bottom - collectionView.bounds.height,
                minY
            )
            let targetY = attributes.frame.minY - topInset - StoreTabCell.Layout.height
            let offsetY = min(max(targetY, minY), maxY)
            collectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
            collectionView.layoutIfNeeded()
        }
    }
}

// MARK: StoreDetailSectionsLoadable
extension StoreSectionsViewController: StoreDetailSectionsLoadable { }

// MARK: StoreSectionScrollable
extension StoreSectionsViewController: StoreSectionScrollable {
    public var scrollableStoreId: Int {
        viewModel.storeId
    }

    public func scrollToSection(fragment: String) {
        viewModel.input.scrollToSectionFragment.send(fragment)
    }
}
