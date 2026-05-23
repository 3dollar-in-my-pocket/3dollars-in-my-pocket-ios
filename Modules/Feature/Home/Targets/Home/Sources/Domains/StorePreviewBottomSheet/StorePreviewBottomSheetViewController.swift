import UIKit
import Combine

import Common
import DesignSystem
import Log
import Model

import CombineCocoa
import Kingfisher
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

    private let topActionBarStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()

    private let imagesContainer = UIView()

    private let imagesScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.bounces = false
        return scroll
    }()

    private let imageRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        stack.distribution = .fill
        return stack
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
    private var imageRowTrailingFill: Constraint?

    private var viewModel: StorePreviewBottomSheetViewModel
    private var cancellables = Set<AnyCancellable>()

    private let topActionBarsRelay = PassthroughSubject<Int, Never>()
    private let actionBarsRelay = PassthroughSubject<Int, Never>()
    private let bodyTapRelay = PassthroughSubject<Void, Never>()

    var onRequestPushStoreDetail: ((Int) -> Void)?
    var onRequestPresentVisit: ((Int) -> Void)?
    var onRequestPresentNavigation: ((Double, Double, String) -> Void)?
    var onRequestClose: (() -> Void)?

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
        bind()
        viewModel.input.load.send(())
    }

    func update(viewModel: StorePreviewBottomSheetViewModel) {
        cancellables.removeAll()
        self.viewModel = viewModel
        bindBodyTapGesture()
        bind()
        viewModel.input.load.send(())
    }

    private func setupViews() {
        // 상단 둥근 코너/그림자는 FloatingPanel SurfaceAppearance 가 처리한다.
        view.backgroundColor = Colors.systemWhite.color

        [titleStack, topActionBarStack, metadataView, imagesContainer, bodiesScrollView, actionBarScrollView]
            .forEach { view.addSubview($0) }

        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(badgeImageView)

        imagesContainer.addSubview(imagesScrollView)
        imagesScrollView.addSubview(imageRow)
        bodiesScrollView.addSubview(bodiesStack)
        actionBarScrollView.addSubview(actionBarStack)
    }

    private func bindConstraints() {
        topActionBarStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(32)
        }

        titleStack.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualTo(topActionBarStack.snp.leading).offset(-4)
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

        imagesContainer.snp.makeConstraints {
            $0.top.equalTo(actionBarScrollView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            self.imagesContainerHeight = $0.height.equalTo(0).constraint
        }

        imagesScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        imageRow.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.height.equalToSuperview()
            self.imageRowTrailingFill = $0.trailing.equalToSuperview().constraint
        }
        imageRowTrailingFill?.deactivate()

        bodiesScrollView.snp.makeConstraints {
            $0.top.equalTo(imagesContainer.snp.bottom).offset(8)
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
        view.addGestureRecognizer(gesture)
    }

    @objc private func didTapBodyArea() {
        bodyTapRelay.send(())
    }

    private func bind() {
        viewModel.output.section
            .receive(on: DispatchQueue.main)
            .sink { [weak self] section in
                guard let self else { return }
                self.render(section: section)
                self.bindTopActionBars(section.topActionBars)
                self.bindActionBars(section.actionBars)
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
                case .pushStoreDetail(let storeId):
                    self.onRequestPushStoreDetail?(storeId)
                case .presentVisit(let storeId):
                    self.onRequestPresentVisit?(storeId)
                case .presentNavigation(let lat, let lng, let name):
                    self.onRequestPresentNavigation?(lat, lng, name)
                case .close:
                    self.onRequestClose?()
                }
            }
            .store(in: &cancellables)

        topActionBarsRelay
            .subscribe(viewModel.input.didTapTopActionBar)
            .store(in: &cancellables)
        actionBarsRelay
            .subscribe(viewModel.input.didTapActionBar)
            .store(in: &cancellables)
        bodyTapRelay
            .subscribe(viewModel.input.didTapBody)
            .store(in: &cancellables)
    }

    private func render(section: StorePreviewSection) {
        if let title = section.header.title {
            titleLabel.setSDText(title)
        }
        configureBadge(section.header.badge)
        metadataView.configure(section.metadata)

        configureImages(section.images)
        configureBodies(section.bodies)
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
        imageRow.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard images.isEmpty.isNot else {
            imagesContainerHeight?.update(offset: 0)
            imagesContainer.isHidden = true
            imageRowTrailingFill?.deactivate()
            return
        }

        imagesContainerHeight?.update(offset: 158)
        imagesContainer.isHidden = false

        switch images.count {
        case 1:
            imageRow.distribution = .fill
            let imageView = makeImageView()
            imageRow.addArrangedSubview(imageView)
            imageView.snp.makeConstraints { $0.height.equalTo(158) }
            loadImage(imageView, url: images[0].url)
            imageRowTrailingFill?.activate()
        case 2:
            imageRow.distribution = .fillEqually
            for image in images {
                let imageView = makeImageView()
                imageRow.addArrangedSubview(imageView)
                imageView.snp.makeConstraints { $0.height.equalTo(158) }
                loadImage(imageView, url: image.url)
            }
            imageRowTrailingFill?.activate()
        default:
            imageRow.distribution = .fill
            for image in images {
                let imageView = makeImageView()
                imageRow.addArrangedSubview(imageView)
                imageView.snp.makeConstraints { $0.size.equalTo(158) }
                loadImage(imageView, url: image.url)
            }
            imageRowTrailingFill?.deactivate()
        }
    }

    private func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor(hex: "D9D9D9")
        return view
    }

    private func loadImage(_ imageView: UIImageView, url: String) {
        guard let url = URL(string: url) else { return }
        imageView.kf.setImage(with: url)
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

    private func bindTopActionBars(_ bars: [StorePreviewActionBar]) {
        topActionBarStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, bar) in bars.enumerated() {
            let button = makeTopIconButton()
            button.setSDButton(bar.button)
            button.controlPublisher(for: .touchUpInside)
                .map { _ in index }
                .subscribe(topActionBarsRelay)
                .store(in: &cancellables)
            topActionBarStack.addArrangedSubview(button)
        }
    }

    private func bindActionBars(_ bars: [StorePreviewActionBar]) {
        actionBarStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, bar) in bars.enumerated() {
            let button = makeActionBarButton()
            button.setSDButton(bar.button)
            button.controlPublisher(for: .touchUpInside)
                .map { _ in index }
                .subscribe(actionBarsRelay)
                .store(in: &cancellables)
            actionBarStack.addArrangedSubview(button)
        }
    }

    private func makeTopIconButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = Colors.gray10.color
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.snp.makeConstraints { $0.size.equalTo(32) }
        return button
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
