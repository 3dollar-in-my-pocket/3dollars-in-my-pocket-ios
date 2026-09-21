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
public final class StoreSectionsViewController: BaseViewController {
    /// Home 바텀시트의 상단 chrome이 상세 컨텐츠 스크롤에 맞춰 fade-in 하는 데 사용한다.
    public var onScrollOffsetChanged: ((CGFloat) -> Void)?
    /// 전체 화면 컨테이너가 상단 네비게이션 타이틀과 공유 정보를 구성하는 데 사용한다.
    public var onStoreInformationChanged: ((SDText?, CLLocationCoordinate2D?) -> Void)?
    public var onSectionsLoaded: (() -> Void)?
    public var onFavoriteChanged: ((Bool) -> Void)?
    /// 삭제된 가게처럼 상세를 유지할 수 없을 때 호스트(전체화면/홈 바텀시트)가 닫도록 요청한다.
    public var onRequestClose: (() -> Void)?

    private let viewModel: StoreSectionsViewModel
    private let collectionView: UICollectionView
    private let bottomActionBarView = StoreBottomActionBarView()
    /// 디버깅용 가게 ID 플로팅 뷰. 개발 환경 + 설정 토글이 켜졌을 때만 생성된다.
    private var storeIdDebugView: StoreIdDebugView?
    private var isBottomActionBarVisible = false
    private var previewItemIndex: Int?
    private var placeholderPreview: StoreScreenPreviewSection?
    private let loadsOnViewDidLoad: Bool
    private var hasRequestedLoad = false
    private var hasLoadedSections = false
    private var isDisplayed = false
    private var sectionsByIdentifier: [String: any StoreSectionComponent] = [:]
    private var displayedImpressionIdentifiers = Set<String>()
    private var expandedMenuIdentifiers = Set<String>()
    private var expandedPostCardIds = Set<String>()
    private var tabItemIndex: Int?
    private var tabTargetItemIndexes: [Int?] = []
    private var selectedTabIndex = 0
    private lazy var dataSource = makeDataSource()

    init(
        viewModel: StoreSectionsViewModel,
        placeholderPreview: StoreScreenPreviewSection? = nil,
        loadsOnViewDidLoad: Bool = true
    ) {
        self.viewModel = viewModel
        self.placeholderPreview = placeholderPreview
        self.loadsOnViewDidLoad = loadsOnViewDidLoad
        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: Self.makeLayout()
        )
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
        containerView.addSubViews([collectionView, bottomActionBarView])
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        bottomActionBarView.snp.makeConstraints { $0.leading.trailing.bottom.equalToSuperview() }
        view = containerView
        setupStoreIdDebugViewIfNeeded(in: containerView)
    }

    /// 개발 환경에서 설정 토글이 켜져 있을 때만 가게 ID 플로팅 뷰를 붙인다.
    /// 프로덕션 빌드는 `isDebugToolAvailable` 이 false 라 뷰가 생성되지 않는다.
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
            // 하단 액션바(chip) 위에 떠 있도록 바 높이만큼 띄운다.
            $0.bottom.equalTo(containerView.safeAreaLayoutGuide)
                .offset(-(StoreBottomActionBarView.Layout.contentHeight + 8))
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
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.register([
            StoreCalloutCell.self,
            StoreScreenPreviewCell.self,
            StoreEditCell.self,
            StoreMarginCell.self,
            StoreRelatedStoresV2Cell.self,
            StoreAdmobCell.self,
            StoreTabCell.self,
            StoreCouponCell.self,
            StoreVisitCell.self,
            StorePostCell.self,
            StoreImageCell.self,
            StoreAppearanceDayCell.self,
            StoreInfoV1Cell.self,
            StoreInfoV2Cell.self,
            StoreCTACell.self,
            StoreReviewCell.self,
            StoreSkeletonCell.self
        ])
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
        let admobIdentifiers = dataSource.snapshot().itemIdentifiers.filter { sectionsByIdentifier[$0] is StoreAdmobSection }
        if admobIdentifiers.isEmpty.isNot {
            var snapshot = dataSource.snapshot()
            snapshot.reconfigureItems(admobIdentifiers)
            dataSource.apply(snapshot, animatingDifferences: false)
        }
        collectionView.indexPathsForVisibleItems.forEach { sendImpressionLogIfNeeded(at: $0) }
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

    private static func makeLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(120)
        ))
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(120)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        // 섹션 간 간격은 서버가 MARGIN 섹션으로 내려준다.
        // 네비게이션 바 높이는 호스트(바텀시트/전체화면)가 컨테이너 제약으로 확보한다.
        // 여기서는 네비 아래 여백만 준다.
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0)
        return StickySectionLayout(section: section)
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

        let identifiers = sections.enumerated().map { "\($0.offset)-\($0.element.type.rawValue)" }
        updateTabTargets(sections)
        updateBottomActionBar(sections)
        let previousSectionsByIdentifier = sectionsByIdentifier
        sectionsByIdentifier = Dictionary(uniqueKeysWithValues: zip(identifiers, sections))
        displayedImpressionIdentifiers.removeAll()
        expandedMenuIdentifiers.formIntersection(identifiers)
        let postCardIds = sections.compactMap { $0 as? StorePostSection }.flatMap { $0.cards.map(\.cardId) }
        expandedPostCardIds.formIntersection(postCardIds)

        if dataSource.snapshot().itemIdentifiers != identifiers {
            (collectionView.collectionViewLayout as? StickySectionLayout)?.clear()
        }

        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(identifiers)
        let changedIdentifiers = identifiers.filter { identifier in
            guard let previous = previousSectionsByIdentifier[identifier],
                  let current = sectionsByIdentifier[identifier] else { return false }
            return AnyHashable(previous) != AnyHashable(current)
        }
        if changedIdentifiers.isEmpty.isNot {
            snapshot.reconfigureItems(changedIdentifiers)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
        collectionView.layoutIfNeeded()
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

    /// 바텀 액션바에 컨텐츠가 가리지 않도록 컬렉션뷰 하단 inset 을 맞춘다.
    ///
    /// 홈 바텀시트 호스트에서는 FloatingPanel 이 레이아웃/safe area 갱신마다
    /// tracking scrollView 의 contentInset 을 자기 값으로 덮어쓰므로 한 번만 설정하면 유지되지 않는다.
    /// 레이아웃·스크롤 패스마다 다시 맞춰 두 호스트 모두에서 같은 결과가 되게 한다. (TH-1336)
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

        guard newIndex != selectedTabIndex else { return }
        selectedTabIndex = newIndex
        let tabCell = collectionView.cellForItem(at: IndexPath(item: tabItemIndex, section: 0)) as? StoreTabCell
        tabCell?.setSelectedIndex(newIndex)
    }

    private func expandMenu(identifier: String) {
        guard expandedMenuIdentifiers.insert(identifier).inserted else { return }
        reconfigure(identifier: identifier)
    }

    private func expandPost(identifier: String, cardId: String) {
        guard expandedPostCardIds.insert(cardId).inserted else { return }
        reconfigure(identifier: identifier)
    }

    private func reconfigure(identifier: String) {
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems([identifier])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, String> {
        UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView) { [weak self] collectionView, indexPath, identifier in
            guard let self,
                  let component = self.sectionsByIdentifier[identifier],
                  let cell = self.makeCell(for: component, identifier: identifier, indexPath: indexPath, in: collectionView) else {
                return nil
            }
            cell.contentView.backgroundColor = component.style.flatMap { UIColor(hex: $0.backgroundColor) } ?? Colors.systemWhite.color
            return cell
        }
    }

    private func makeCell(
        for component: any StoreSectionComponent,
        identifier: String,
        indexPath: IndexPath,
        in collectionView: UICollectionView
    ) -> UICollectionViewCell? {
        let actionHandler: (StoreSectionAction) -> Void = { [weak self] in
            self?.viewModel.input.didSelectAction.send($0)
        }

        switch component {
            case let section as StoreCalloutSection:
                let cell: StoreCalloutCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreScreenPreviewSection:
                let cell: StoreScreenPreviewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section)
                cell.onAction = actionHandler
                cell.onTapImage = { [weak self] images, index in
                    self?.viewModel.input.didTapImageGallery.send((images: images, index: index))
                }
                return cell
            case let section as StoreEditSection:
                let cell: StoreEditCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreMarginSection:
                let cell: StoreMarginCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); return cell
            case let section as StoreRelatedStoresSectionV2:
                let cell: StoreRelatedStoresV2Cell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreAdmobSection:
                let cell: StoreAdmobCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section, rootViewController: self, isDisplayed: self.isDisplayed); return cell
            case let section as StoreTabSection:
                let cell: StoreTabCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section, selectedIndex: self.selectedTabIndex)
                cell.onSelectTab = { [weak self] in self?.selectedTabIndex = $0 }
                cell.onAction = actionHandler
                return cell
            case let section as StoreCouponSection:
                let cell: StoreCouponCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreVisitSection:
                let cell: StoreVisitCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StorePostSection:
                let cell: StorePostCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section, expandedCardIds: self.expandedPostCardIds)
                cell.onAction = actionHandler
                cell.onToggleBodyExpansion = { [weak self] cardId in
                    self?.expandPost(identifier: identifier, cardId: cardId)
                }
                cell.onTapImage = { [weak self] images, index in
                    self?.viewModel.input.didTapImageGallery.send((images: images, index: index))
                }
                return cell
            case let section as StoreImageSection:
                let cell: StoreImageCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreAppearanceDaySection:
                let cell: StoreAppearanceDayCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreInfoV1Section:
                let cell: StoreInfoV1Cell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section, isMenuExpanded: self.expandedMenuIdentifiers.contains(identifier))
                cell.onAction = actionHandler
                cell.onToggleMenuExpansion = { [weak self] in self?.expandMenu(identifier: identifier) }
                return cell
            case let section as StoreInfoV2Section:
                let cell: StoreInfoV2Cell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section, isMenuExpanded: self.expandedMenuIdentifiers.contains(identifier))
                cell.onAction = actionHandler
                cell.onToggleMenuExpansion = { [weak self] in self?.expandMenu(identifier: identifier) }
                cell.onTapGalleryImage = { [weak self] images, index in
                    self?.viewModel.input.didTapImageGallery.send((images: images, index: index))
                }
                return cell
            case let section as StoreCTASection:
                let cell: StoreCTACell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreReviewSection:
                let cell: StoreReviewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section)
                cell.onAction = actionHandler
                cell.onTapImage = { [weak self] images, index in
                    self?.viewModel.input.didTapImageGallery.send((images: images, index: index))
                }
                return cell
            case is StoreSkeletonSection:
                let cell: StoreSkeletonCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                return cell
            default:
                return nil
        }
    }
}

extension StoreSectionsViewController: UICollectionViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onScrollOffsetChanged?(scrollView.contentOffset.y)
        updateSelectedTabIfNeeded(scrollView)
        updateBottomActionBarVisibility()
        // FloatingPanel 이 레이아웃 패스 이후에 inset 을 덮어쓰는 경우가 있어 스크롤 중에도 보정한다.
        updateCollectionViewBottomInset()
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (collectionView.collectionViewLayout as? StickySectionLayout)?.registerIfNeeded(cell: cell, indexPath: indexPath)
        sendImpressionLogIfNeeded(at: indexPath)
    }

    private func sendImpressionLogIfNeeded(at indexPath: IndexPath) {
        guard isDisplayed,
              let identifier = dataSource.itemIdentifier(for: indexPath),
              displayedImpressionIdentifiers.insert(identifier).inserted,
              let component = sectionsByIdentifier[identifier] else { return }

        switch component {
        case let section as StoreRelatedStoresSectionV2:
            viewModel.sendImpressionLog(section.impressionLog)
        case let section as StoreAdmobSection:
            viewModel.sendImpressionLog(section.cards.first?.impressionLog)
        default:
            break
        }
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
        let identifiers = dataSource.snapshot().itemIdentifiers
        guard let index = identifiers.firstIndex(where: { sectionsByIdentifier[$0]?.type == sectionType }) else { return }
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
