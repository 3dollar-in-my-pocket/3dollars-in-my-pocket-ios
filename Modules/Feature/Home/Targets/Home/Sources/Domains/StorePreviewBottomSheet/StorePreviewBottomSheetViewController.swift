import UIKit
import Combine

import Common
import DesignSystem
import Log
import Model

import CombineCocoa
import SnapKit

final class StorePreviewBottomSheetViewController: UIViewController {
    private let titleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 20)
        label.textColor = Colors.gray100.color
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let badgeImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()

    private let metadataView = StorePreviewMetadataRowView()

    /// 우상단 버튼 행(찜 + 닫기). 서버 topActionBars 가 제거되어 클라이언트에서 고정 렌더한다.
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

    private let imagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 158, height: 158)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        return collectionView
    }()

    private let bodiesScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.bounces = false
        return scroll
    }()

    private let bodiesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()

    private let actionBarScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.bounces = false
        scroll.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return scroll
    }()

    private let actionBarStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        stack.distribution = .fill
        return stack
    }()

    private var imagesContainerHeight: Constraint?
    private var imageItems: [SDImage] = []
    /// "사진 추가" 셀 노출 여부. 사장님 가게는 사용자 사진 업로드를 지원하지 않아 false 로 둔다.
    private var canAddPhoto: Bool = false

    private var viewModel: StorePreviewBottomSheetViewModel
    private var cancellables = Set<AnyCancellable>()

    var onRequestPushStoreDetail: ((Int, StoreType) -> Void)?
    var onRequestPresentVisit: ((Int) -> Void)?
    var onRequestPresentReviewWrite: ((Int) -> Void)?
    var onRequestShare: ((_ storeId: Int, _ storeType: StoreType, _ storeName: String, _ latitude: Double, _ longitude: Double) -> Void)?
    var onRequestPresentNavigation: ((Double, Double, String) -> Void)?
    var onRequestOpenLink: ((SDLink) -> Void)?
    var onRequestAddPhoto: ((Int) -> Void)?
    var onRequestClose: (() -> Void)?
    /// 데이터(이미지/바디 유무)에 따라 컨텐츠 높이가 변할 때 호출. FloatingPanel anchor 갱신용.
    var onContentHeightChanged: ((CGFloat) -> Void)?

    init(viewModel: StorePreviewBottomSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindConstraints()
        bindBodyTapGesture()
        setupActions()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 노출 시점마다 조회해 가게 상세를 다녀온 뒤에도 최신 데이터로 UI 를 갱신한다.
        // 상세 push 중에는 패널이 isHidden 으로 가려질 뿐 부착 상태가 유지되어,
        // pop 으로 Home 이 다시 나타날 때 자식인 이 VC 의 viewWillAppear 도 함께 호출된다.
        viewModel.input.load.send(())
    }

    /// 미리보기 위에 모달로 띄운 방문 인증·리뷰 작성이 성공한 뒤 호출해 최신 데이터로 갱신한다.
    /// (모달 dismiss 는 이 VC 의 viewWillAppear 를 호출하지 않으므로 명시적으로 재조회한다.)
    func reload() {
        viewModel.input.load.send(())
    }

    func update(viewModel: StorePreviewBottomSheetViewModel) {
        cancellables.removeAll()
        self.viewModel = viewModel
        // 새 가게로 교체되면 찜 상태도 초기화한다. (preview 응답엔 찜 여부가 없어 기본 미저장으로 시작)
        setSaveButton(isFavorited: false)
        bind()
        // 이미 화면에 떠 있는 경우(연속 마커 탭)엔 viewWillAppear 가 다시 호출되지 않으므로 직접 로드한다.
        // detached 상태에서 재사용되는 경우엔 곧 addPanel → viewWillAppear 에서 로드되므로 중복 호출하지 않는다.
        if viewIfLoaded?.window != nil {
            viewModel.input.load.send(())
        }
    }

    private func setupViews() {
        // 상단 둥근 코너/그림자는 FloatingPanel SurfaceAppearance 가 처리한다.
        view.backgroundColor = Colors.systemWhite.color

        [titleStack, topButtonStack, metadataView, imagesCollectionView, bodiesScrollView, actionBarScrollView]
            .forEach { view.addSubview($0) }

        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(badgeImageView)

        topButtonStack.addArrangedSubview(saveButton)
        topButtonStack.addArrangedSubview(closeButton)

        imagesCollectionView.register([StorePreviewImageCell.self, StorePreviewAddPhotoCell.self])
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self

        bodiesScrollView.addSubview(bodiesStack)
        actionBarScrollView.addSubview(actionBarStack)
    }

    private func bindConstraints() {
        saveButton.snp.makeConstraints { $0.size.equalTo(32) }
        closeButton.snp.makeConstraints { $0.size.equalTo(32) }

        topButtonStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(32)
        }

        titleStack.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualTo(topButtonStack.snp.leading).offset(-4)
            $0.height.equalTo(28)
        }

        metadataView.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }

        actionBarScrollView.snp.makeConstraints {
            $0.top.equalTo(metadataView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(36)
        }

        actionBarStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        imagesCollectionView.snp.makeConstraints {
            $0.top.equalTo(actionBarScrollView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            self.imagesContainerHeight = $0.height.equalTo(0).constraint
        }

        bodiesScrollView.snp.makeConstraints {
            $0.top.equalTo(imagesCollectionView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            // FloatingPanel surface 의 .safeArea 기준 anchor 가 적용되므로 superview bottom 으로 안전하게 붙인다.
            $0.bottom.equalToSuperview().offset(-12)
            $0.height.equalTo(0).priority(.low)
        }

        bodiesStack.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
    }

    private func bindBodyTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapBodyArea))
        gesture.cancelsTouchesInView = false
        // 버튼 등 인터랙티브 요소 위 터치는 무시하도록 delegate 에서 걸러낸다.
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }

    @objc private func didTapBodyArea() {
        viewModel.input.didTapBody.send(())
    }

    private func bind() {
        viewModel.output.section
            .receive(on: DispatchQueue.main)
            .sink { [weak self] section in
                guard let self else { return }
                self.render(section: section)
                self.bindActionBars(section.actionBars)
            }
            .store(in: &cancellables)

        viewModel.output.isFavoriteOverride
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavorited in
                self?.setSaveButton(isFavorited: isFavorited)
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
                case .pushStoreDetail(let storeId, let storeType):
                    self.onRequestPushStoreDetail?(storeId, storeType)
                case .presentVisit(let storeId):
                    self.onRequestPresentVisit?(storeId)
                case .presentReviewWrite(let storeId):
                    self.onRequestPresentReviewWrite?(storeId)
                case .share(let storeId, let storeType, let storeName, let lat, let lng):
                    self.onRequestShare?(storeId, storeType, storeName, lat, lng)
                case .presentNavigation(let lat, let lng, let name):
                    self.onRequestPresentNavigation?(lat, lng, name)
                case .openLink(let link):
                    self.onRequestOpenLink?(link)
                case .presentUploadPhoto(let storeId):
                    self.onRequestAddPhoto?(storeId)
                case .close:
                    self.onRequestClose?()
                }
            }
            .store(in: &cancellables)
    }

    private func setupActions() {
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }

    @objc private func didTapSaveButton() {
        viewModel.input.didTapSave.send(())
    }

    @objc private func didTapCloseButton() {
        viewModel.input.didTapClose.send(())
    }

    private func render(section: StorePreviewSection) {
        if let title = section.header.title {
            titleLabel.setSDText(title)
        }
        configureBadge(section.header.badge)
        metadataView.configure(section.metadata)

        // 사장님 가게는 사용자 사진 업로드를 지원하지 않으므로 "사진 추가" 셀을 노출하지 않는다.
        canAddPhoto = isBossStore(section).isNot
        configureImages(section.images)
        configureBodies(section.bodies)

        onContentHeightChanged?(calculateContentHeight(for: section))
    }

    private func isBossStore(_ section: StorePreviewSection) -> Bool {
        guard let rawValue = section.additionalInfos?.storeType else { return false }
        return StoreType(value: rawValue) == .bossStore
    }

    /// `bindConstraints()` 에 적용된 상수와 동일하게 각 영역 높이/간격을 합산한다.
    /// 레이아웃 상수가 바뀌면 여기도 같이 갱신되어야 한다.
    private func calculateContentHeight(for section: StorePreviewSection) -> CGFloat {
        var height: CGFloat = 0

        // 상단 패딩 + 타이틀
        height += 16 + 28

        // 메타데이터 (primary/secondary 각 20pt, 둘 다 있을 때 내부 spacing 4pt)
        let hasPrimary = section.metadata.primary.isEmpty.isNot
        let hasSecondary = section.metadata.secondary.isEmpty.isNot
        if hasPrimary || hasSecondary {
            height += 4 // 타이틀과의 간격
            height += (hasPrimary ? 20 : 0) + (hasSecondary ? 20 : 0)
        }

        // 액션바
        height += 16 + 36

        // 이미지 (있을 때만 158pt + 12pt 간격)
        if section.images.isEmpty.isNot {
            height += 12 + 158
        }

        // 바디 (있을 때만 58pt + 8pt 간격)
        // imagesContainer 가 숨겨져도 8pt 간격은 항상 제약에 걸려 있어 동일하게 더한다.
        if section.bodies.isEmpty.isNot {
            height += 8 + 58
        }

        return height
    }

    private func configureBadge(_ badge: SDImage?) {
        guard let badge else {
            badgeImageView.isHidden = true
            badgeImageView.image = nil
            return
        }
        badgeImageView.isHidden = false
        badgeImageView.setSDImage(badge)
    }

    private func configureImages(_ images: [SDImage]) {
        imageItems = images

        // 이미지가 없으면 영역을 숨기고, 1개 이상이면 158pt 고정 셀 + 마지막 "사진 추가" 셀을 가로 스크롤로 노출한다.
        let hasImages = images.isEmpty.isNot
        imagesContainerHeight?.update(offset: hasImages ? 158 : 0)
        imagesCollectionView.isHidden = hasImages.isNot
        imagesCollectionView.reloadData()
        if hasImages {
            imagesCollectionView.setContentOffset(.zero, animated: false)
        }
    }

    private func configureBodies(_ bodies: [StorePreviewBody]) {
        bodiesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard bodies.isEmpty.isNot else {
            bodiesScrollView.isHidden = true
            return
        }
        bodiesScrollView.isHidden = false

        for body in bodies {
            let card = StorePreviewBodyCardView()
            card.configure(body: body)
            card.snp.makeConstraints {
                $0.width.equalTo(300)
                $0.height.equalTo(58)
            }
            bodiesStack.addArrangedSubview(card)
        }
    }

    private func bindActionBars(_ bars: [StorePreviewActionBar]) {
        actionBarStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, bar) in bars.enumerated() {
            let button = makeActionBarButton()
            button.setSDButton(bar.button)
            button.controlPublisher(for: .touchUpInside)
                .map { _ in index }
                .subscribe(viewModel.input.didTapActionBar)
                .store(in: &cancellables)
            actionBarStack.addArrangedSubview(button)
        }
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

    /// 찜 상태에 따라 저장 버튼 아이콘/색을 갱신한다. (StoreDetail 저장 버튼과 동일 규칙)
    private func setSaveButton(isFavorited: Bool) {
        let icon = isFavorited ? Icons.bookmarkSolid.image : Icons.bookmarkLine.image
        let color = isFavorited ? Colors.mainRed.color : Colors.gray100.color
        saveButton.setImage(
            icon.resizeImage(scaledTo: 20).withTintColor(color),
            for: .normal
        )
    }

    private func makeActionBarButton() -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)

        // 이미지와 타이틀 사이 4pt 간격을 만들기 위한 표준 트릭(semanticContentAttribute 가 .forceRightToLeft 이면 자동 반전).
        let spacing: CGFloat = 4
        let halfSpacing = spacing / 2
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12 + halfSpacing, bottom: 8, right: 12 + halfSpacing)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: halfSpacing, bottom: 0, right: -halfSpacing)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -halfSpacing, bottom: 0, right: halfSpacing)

        button.snp.makeConstraints { $0.height.greaterThanOrEqualTo(36) }
        return button
    }
}

// MARK: UIGestureRecognizerDelegate
extension StorePreviewBottomSheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        // 액션바 버튼 등 UIControl, 그리고 이미지 컬렉션뷰(셀 탭을 직접 처리) 위의 터치는
        // body 탭(가게 상세 이동)으로 처리하지 않는다.
        var hitView = touch.view
        while let current = hitView {
            if current is UIControl { return false }
            if current === imagesCollectionView { return false }
            hitView = current.superview
        }
        return true
    }
}

// MARK: UICollectionViewDataSource & Delegate
extension StorePreviewBottomSheetViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard imageItems.isEmpty.isNot else { return 0 }
        // 이미지가 1개 이상이고 사진 추가가 가능한 가게(일반 가게)일 때만 마지막에 "사진 추가" 셀(+1)을 노출한다.
        return imageItems.count + (canAddPhoto ? 1 : 0)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if let image = imageItems[safe: indexPath.item] {
            let cell: StorePreviewImageCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(image)
            return cell
        }

        let cell: StorePreviewAddPhotoCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if imageItems[safe: indexPath.item] != nil {
            // 이미지 탭은 가게 상세로 이동(기존 body 탭과 동일 동작).
            viewModel.input.didTapBody.send(())
        } else {
            // 마지막 "사진 추가" 셀 탭.
            viewModel.input.didTapAddPhoto.send(())
        }
    }
}
