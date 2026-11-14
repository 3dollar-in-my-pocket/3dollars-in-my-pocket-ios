import UIKit
import Combine

import Common
import DesignSystem
import Log
import Model
import StoreInterface

import SnapKit

/// 가게 미리보기(tip)와 가게 상세 임베드(full)를 한 패널에서 전환하는 시트.
/// tip 은 가게 상세와 같은 섹션 셀을 등록한 공용 섹션 뷰(`StorePreviewSectionsViewProtocol`)로 서버 섹션을 순서대로 그린다.
final class StorePreviewBottomSheetViewController: BaseViewController {
    private enum Layout {
        static let grabberAreaHeight: CGFloat = 12
        static let contentTop: CGFloat = grabberAreaHeight + 16
        static let horizontalMargin: CGFloat = 20
    }

    private lazy var sectionsView = Environment.storeInterface.createStorePreviewSectionsView(rootViewController: self)

    /// 로딩 중(스켈레톤)에만 보이는 우상단 찜·닫기. 로드 후에는 미리보기 셀이 같은 버튼을 그린다.
    private let topButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()

    private let saveButton = StorePreviewBottomSheetViewController.makeIconButton(
        icon: Icons.bookmarkLine.image
    )

    private let closeButton = StorePreviewBottomSheetViewController.makeIconButton(
        icon: Icons.close.image
    )

    private let detailContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
        view.isHidden = true
        return view
    }()

    /// full 상태에서만 표시되는 상단 chrome. 버튼은 즉시 보이고, 타이틀은 상세 스크롤에 맞춰 fade-in 된다.
    private let detailNavigationBar = UIView()

    private let detailNavigationTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 16)
        label.textColor = Colors.gray100.color
        label.textAlignment = .center
        label.alpha = 0
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let collapseButton = StorePreviewBottomSheetViewController.makeDetailNavigationButton(
        icon: Icons.arrowLeft.image
    )

    private let detailSaveButton = StorePreviewBottomSheetViewController.makeDetailNavigationButton(
        icon: Icons.bookmarkLine.image
    )

    private let detailCloseButton = StorePreviewBottomSheetViewController.makeDetailNavigationButton(
        icon: Icons.close.image
    )

    private var viewModel: StorePreviewBottomSheetViewModel
    private var detailViewController: UIViewController?
    private var previewSection: StoreScreenPreviewSection?
    private var isTrackingDetailScroll = false
    private var isPanelAtFull = false
    private var displayItemModalViews: [UIView] = []
    private let skeletonView = StorePreviewSkeletonView()
    private var isLoadingPreview = true

    var onRequestExpandPanel: (() -> Void)?
    var onRequestCollapsePanel: (() -> Void)?
    var onRequestTrackDetailScroll: ((UIScrollView) -> Void)?
    var onRequestPresentVisit: ((Int) -> Void)?
    var onRequestPresentReviewWrite: ((Int, String?) -> Void)?
    var onRequestShare: ((_ storeId: Int, _ storeName: String, _ latitude: Double, _ longitude: Double) -> Void)?
    var onRequestPresentNavigation: ((Double, Double, String) -> Void)?
    var onRequestOpenLink: ((SDLink) -> Void)?
    var onRequestAddPhoto: ((Int) -> Void)?
    var onRequestClose: (() -> Void)?
    var onMarkersLoaded: (([HomeListCardMarker]) -> Void)?
    /// 데이터(섹션 구성·셀 실측 높이)에 따라 컨텐츠 높이가 변할 때 호출. FloatingPanel anchor 갱신용.
    var onContentHeightChanged: ((_ height: CGFloat, _ isPeekingNextSection: Bool) -> Void)?

    init(viewModel: StorePreviewBottomSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindConstraints()
        setupActions()
        bindSectionsView()
        bind()
        updateLoadingState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 노출 시점마다 조회해 가게 상세를 다녀온 뒤에도 최신 데이터로 UI 를 갱신한다.
        // 상세 push 중에는 패널이 isHidden 으로 가려질 뿐 부착 상태가 유지되어,
        // pop 으로 Home 이 다시 나타날 때 자식인 이 VC 의 viewWillAppear 도 함께 호출된다.
        viewModel.input.load.send(())
        loadDetail()
    }

    /// 미리보기 위에 모달로 띄운 방문 인증·리뷰 작성이 성공한 뒤 호출해 최신 데이터로 갱신한다.
    /// (모달 dismiss 는 이 VC 의 viewWillAppear 를 호출하지 않으므로 명시적으로 재조회한다.)
    func reload() {
        viewModel.input.load.send(())
        loadDetail()
    }

    private func loadDetail() {
        if detailViewController == nil {
            embedStoreSectionsIfNeeded()
        } else {
            (detailViewController as? StoreDetailSectionsLoadable)?.reloadSections()
        }
    }

    func update(viewModel: StorePreviewBottomSheetViewModel) {
        cancellables.removeAll()
        self.viewModel = viewModel
        let wasShowingDetail = isPanelAtFull
        dismissDisplayItemModals()
        resetDetail()
        // 새 가게로 교체되면 찜 상태도 초기화한다. 실제 값은 preview 응답의 isSubscriber 로 다시 동기화된다.
        setSaveButton(isFavorited: false)
        bind()
        // 이미 화면에 떠 있는 경우(연속 마커 탭)엔 viewWillAppear 가 다시 호출되지 않으므로 직접 로드한다.
        // detached 상태에서 재사용되는 경우엔 곧 addPanel → viewWillAppear 에서 로드되므로 중복 호출하지 않는다.
        if viewIfLoaded?.window != nil {
            viewModel.input.load.send(())
            loadDetail()
        }
        if wasShowingDetail {
            didReachFullState()
        }
    }

    func clearContent() {
        previewSection = nil
        sectionsView.apply([])
        setSaveButton(isFavorited: false)
        isLoadingPreview = true
        updateLoadingState()
    }

    private func updateLoadingState() {
        let isShowingDetail = detailContainerView.isHidden.isNot
        skeletonView.isHidden = isLoadingPreview.isNot || isShowingDetail
        topButtonStack.isHidden = isLoadingPreview.isNot || isShowingDetail
        sectionsView.isHidden = isLoadingPreview || isShowingDetail
    }

    private func resetDetail() {
        if let detailViewController {
            detailViewController.willMove(toParent: nil)
            detailViewController.view.removeFromSuperview()
            detailViewController.removeFromParent()
            self.detailViewController = nil
        }
        previewSection = nil
        isTrackingDetailScroll = false
        detailNavigationTitleLabel.text = nil
        detailNavigationTitleLabel.alpha = 0
        detailContainerView.isHidden = true
        detailNavigationBar.alpha = 0
        updateLoadingState()
    }

    private func setupViews() {
        // 상단 둥근 코너/그림자는 FloatingPanel SurfaceAppearance 가 처리한다.
        view.backgroundColor = Colors.systemWhite.color

        [sectionsView, skeletonView, topButtonStack, detailContainerView, detailNavigationBar]
            .forEach { view.addSubview($0) }

        topButtonStack.addArrangedSubview(saveButton)
        topButtonStack.addArrangedSubview(closeButton)

        detailNavigationBar.backgroundColor = Colors.systemWhite.color
        detailNavigationBar.alpha = 0
        [collapseButton, detailNavigationTitleLabel, detailSaveButton, detailCloseButton].forEach {
            detailNavigationBar.addSubview($0)
        }
    }

    private func bindConstraints() {
        saveButton.snp.makeConstraints { $0.size.equalTo(32) }
        closeButton.snp.makeConstraints { $0.size.equalTo(32) }

        topButtonStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.contentTop)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
            $0.height.equalTo(32)
        }

        skeletonView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.contentTop)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.equalTo(topButtonStack.snp.leading).offset(-8)
            $0.height.equalTo(StorePreviewSkeletonView.Layout.height)
        }

        // 섹션 뷰의 상단 여백(16)은 레이아웃이 주므로 그래버 영역 바로 아래부터 붙인다.
        sectionsView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.grabberAreaHeight)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        // 상세는 네비 아래에서 시작한다. 네비와 겹치면 가게명이 가려지고,
        // 스크롤 시 상태바 영역(safe area 위)까지 컨텐츠가 비쳐 보인다.
        detailContainerView.snp.makeConstraints {
            $0.top.equalTo(detailNavigationBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        detailNavigationBar.snp.makeConstraints {
            // full anchor 는 superview 최상단까지 올라가므로 상태바 영역은 safe area 로 비워 둔다.
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(56)
        }

        collapseButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(32)
        }

        detailSaveButton.snp.makeConstraints {
            $0.trailing.equalTo(detailCloseButton.snp.leading).offset(-4)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(32)
        }

        detailCloseButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(detailNavigationBar)
            $0.size.equalTo(32)
        }

        detailNavigationTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(collapseButton.snp.trailing).offset(12)
            $0.trailing.equalTo(detailSaveButton.snp.leading).offset(-12)
            $0.centerY.equalToSuperview()
        }
    }

    /// 섹션 뷰 이벤트는 교체되는 ViewModel 이 아니라 현재 viewModel 로 보낸다(`update(viewModel:)` 재사용 대비).
    private func bindSectionsView() {
        sectionsView.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .tapActionBar(let index):
                self.viewModel.input.didTapActionBar.send(index)
            case .tapImage(let index):
                self.viewModel.input.didTapImage.send(index)
            case .tapAddPhoto:
                self.viewModel.input.didTapAddPhoto.send(())
            case .tapBody:
                self.viewModel.input.didTapBody.send(())
            case .tapSave:
                self.viewModel.input.didTapSave.send(())
            case .tapClose:
                self.viewModel.input.didTapClose.send(())
            case .clickAd(let clickLog):
                self.viewModel.input.didClickAd.send(clickLog)
            case .impression(let impressionLog):
                self.viewModel.input.didImpression.send(impressionLog)
            }
        }
        sectionsView.onContentHeightChanged = { [weak self] height in
            guard let self, height > 0 else { return }
            self.onContentHeightChanged?(Layout.grabberAreaHeight + height, self.sectionsView.isPeekingNextSection)
        }
    }

    private func bind() {
        viewModel.output.sections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                self?.render(sections: sections)
            }
            .store(in: &cancellables)

        viewModel.output.previewSection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] section in
                guard let self else { return }
                self.previewSection = section
                (self.detailViewController as? StoreDetailSectionsLoadable)?.updatePlaceholderPreview(section.placeholder)
            }
            .store(in: &cancellables)

        viewModel.output.markers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] markers in
                self?.onMarkersLoaded?(markers)
            }
            .store(in: &cancellables)

        viewModel.output.isFavoriteOverride
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavorited in
                self?.setSaveButton(isFavorited: isFavorited)
            }
            .store(in: &cancellables)

        viewModel.output.detailTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.detailNavigationTitleLabel.text = title
            }
            .store(in: &cancellables)

        viewModel.output.pageViewLog
            .receive(on: DispatchQueue.main)
            .sink { log in
                // 서버에서 내려준 screenName/extraParameters 를 그대로 GA 페이지뷰로 송신.
                let parameters: [String: Any] = log.extraParameters
                Environment.appModuleInterface.sendPageView(
                    screenName: log.screenName,
                    type: StorePreviewBottomSheetViewController.self,
                    parameters: parameters
                )
            }
            .store(in: &cancellables)

        viewModel.output.toast
            .receive(on: DispatchQueue.main)
            .sink { message in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)

        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                guard let self else { return }
                switch route {
                case .expandPanel:
                    self.beginExpandingToFull()
                    self.onRequestExpandPanel?()
                case .presentVisit(let storeId):
                    self.onRequestPresentVisit?(storeId)
                case .presentReviewWrite(let storeId, let storeName):
                    self.onRequestPresentReviewWrite?(storeId, storeName)
                case .share(let storeId, let storeName, let lat, let lng):
                    self.onRequestShare?(storeId, storeName, lat, lng)
                case .presentShareSheet(let url):
                    let activityViewController = UIActivityViewController(
                activityItems: [url],
                applicationActivities: nil
            )
                    activityViewController.popoverPresentationController?.sourceView = self.view
                    self.present(activityViewController, animated: true)
                case .presentNavigation(let lat, let lng, let name):
                    self.onRequestPresentNavigation?(lat, lng, name)
                case .openLink(let link):
                    self.onRequestOpenLink?(link)
                case .presentUploadPhoto(let storeId):
                    self.onRequestAddPhoto?(storeId)
                case .presentPhotoViewer(let imageUrls, let selectedIndex):
                    let viewController = Environment.storeInterface.getPhotoViewerViewController(
                        imageUrls: imageUrls,
                        selectedIndex: selectedIndex
                    )
                    self.present(viewController, animated: true)
                case .presentDisplayItemModal(let itemType, let trigger):
                    let modalView = Environment.storeInterface.presentStoreDisplayItemModal(
                        from: self,
                        storeId: self.viewModel.storeId,
                        itemType: itemType,
                        trigger: trigger,
                        onDisplayed: { [weak self] in
                            self?.viewModel.recordDisplayItemImpression(itemType: itemType)
                        }
                    )
                    if let modalView {
                        self.displayItemModalViews.append(modalView)
                    }
                case .close:
                    self.onRequestClose?()
                }
            }
            .store(in: &cancellables)
    }

    private func setupActions() {
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        detailCloseButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        collapseButton.addTarget(self, action: #selector(didTapCollapseButton), for: .touchUpInside)
        detailSaveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
    }

    @objc private func didTapSaveButton() {
        viewModel.input.didTapSave.send(())
    }

    @objc private func didTapCloseButton() {
        viewModel.input.didTapClose.send(())
    }

    @objc private func didTapCollapseButton() {
        onRequestCollapsePanel?()
    }

    func beginExpandingToFull() {
        guard detailContainerView.isHidden else { return }
        embedStoreSectionsIfNeeded()
        detailContainerView.isHidden = false
        updateLoadingState()
        showDetailNavigationBar()
        (detailViewController as? StoreDetailSectionsLoadable)?.markSectionsDisplayed()
    }

    func didReachFullState() {
        isPanelAtFull = true
        beginExpandingToFull()
        trackDetailScrollIfNeeded()
        viewModel.input.didEnterDetail.send(())
    }

    func dismissDisplayItemModals() {
        displayItemModalViews.forEach { $0.removeFromSuperview() }
        displayItemModalViews.removeAll()
    }

    func didReachTipState() {
        isPanelAtFull = false
        detailContainerView.isHidden = true
        detailNavigationBar.alpha = 0
        updateLoadingState()
    }

    private func showDetailNavigationBar() {
        guard detailNavigationBar.alpha < 1 else { return }
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.detailNavigationBar.alpha = 1
        }
    }

    private func trackDetailScrollIfNeeded() {
        guard isTrackingDetailScroll.isNot,
              let scrollView = (detailViewController as? StoreDetailSectionsLoadable)?.sectionsScrollView else { return }
        isTrackingDetailScroll = true
        onRequestTrackDetailScroll?(scrollView)
    }

    private func updateDetailNavigationTitle(for contentOffset: CGFloat) {
        // 상세 최상단의 preview 섹션이 nav 아래를 지나갈수록 가게명이 자연스럽게 드러난다.
        detailNavigationTitleLabel.alpha = min(max(contentOffset / 48, 0), 1)
    }

    private func embedStoreSectionsIfNeeded() {
        guard detailViewController == nil else { return }
        let storeId = viewModel.storeId
        let detailViewController = Environment.storeInterface.getStoreDetailSectionsViewController(
            storeId: storeId,
            latitude: viewModel.deviceLatitude,
            longitude: viewModel.deviceLongitude,
            placeholderPreview: previewSection?.placeholder,
            onScrollOffsetChanged: { [weak self] contentOffset in
                self?.updateDetailNavigationTitle(for: contentOffset)
            },
            onSectionsLoaded: { }
        )
        addChild(detailViewController)
        detailContainerView.addSubview(detailViewController.view)
        detailViewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        detailViewController.didMove(toParent: self)
        self.detailViewController = detailViewController
        (detailViewController as? StoreDetailSectionsLoadable)?.onRequestClose = { [weak self] in
            self?.viewModel.input.didTapClose.send(())
        }
        (detailViewController as? StoreDetailSectionsLoadable)?.loadSectionsIfNeeded()
    }

    private func render(sections: [any StoreSectionComponent]) {
        isLoadingPreview = false
        updateLoadingState()
        sectionsView.apply(sections)
    }

    /// 우상단 32pt 원형 아이콘 버튼(찜·닫기 공용). 배경 gray10, 아이콘 20pt·gray100.
    private static func makeIconButton(icon: UIImage) -> UIButton {
        let button = UIButton()
        button.backgroundColor = Colors.gray10.color
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.setImage(
            icon.resizeImage(scaledTo: 20).withTintColor(Colors.gray100.color),
            for: .normal
        )
        return button
    }

    /// full 상태의 고정 네비게이션은 전체 화면 상세와 동일하게 배경 없는 아이콘을 사용한다.
    private static func makeDetailNavigationButton(icon: UIImage) -> UIButton {
        let button = UIButton()
        button.setImage(
            icon.resizeImage(scaledTo: 20).withTintColor(Colors.gray100.color),
            for: .normal
        )
        return button
    }

    /// 찜 상태에 따라 저장 버튼 아이콘/색을 갱신한다. (StoreDetail 저장 버튼과 동일 규칙)
    private func setSaveButton(isFavorited: Bool) {
        let icon = isFavorited ? Icons.bookmarkSolid.image : Icons.bookmarkLine.image
        let color = isFavorited ? Colors.mainRed.color : Colors.gray100.color
        let image = icon.resizeImage(scaledTo: 20).withTintColor(color)
        saveButton.setImage(image, for: .normal)
        detailSaveButton.setImage(image, for: .normal)
        sectionsView.setFavorited(isFavorited)
    }
}
