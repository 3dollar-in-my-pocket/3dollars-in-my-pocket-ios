import UIKit
import Combine

import Common
import DesignSystem
import Model
import Log

final class WriteDetailMenuViewController: BaseViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = Colors.systemWhite.color
        return scrollView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.layoutMargins = .init(top: 0, left: 0, bottom: 48, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        return stackView
    }()

    private let titleLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 20, bottomInset: 16, leftInset: 20, rightInset: 20)
        label.font = Fonts.bold.font(size: 24)
        label.textColor = Colors.gray100.color

        let string = Strings.WriteDetailMenu.title
        let range = (string as NSString).range(of: Strings.WriteDetailMenu.titleSmallRange)
        let attributedString = NSMutableAttributedString(string: string)

        attributedString.addAttribute(.font, value: Fonts.bold.font(size: 16), range: range)
        attributedString.addAttribute(.foregroundColor, value: Colors.gray50.color, range: range)
        label.attributedText = attributedString
        label.textAlignment = .left
        label.backgroundColor = Colors.systemWhite.color
        return label
    }()

    private let imageMenuButtonContainerView = UIView()

    private let imageMenuButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(Strings.WriteDetailMenu.imageMenuButton, attributes: AttributeContainer([
            .font: Fonts.semiBold.font(size: 14),
            .foregroundColor: Colors.gray70.color
        ]))
        config.image = Assets.iconImageAdd.image.resizeImage(scaledTo: 20)
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.cornerStyle = .fixed
        config.background.cornerRadius = 12
        config.background.backgroundColor = Colors.gray0.color
        config.background.strokeWidth = 1
        config.background.strokeColor = Colors.gray20.color
        return UIButton(configuration: config)
    }()

    private let contentView = MenuFormContentView(showsFilterButton: true)

    private let skipButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(Strings.WriteDetailMenu.skip, attributes: AttributeContainer([
            .font: Fonts.medium.font(size: 16),
            .foregroundColor: Colors.gray70.color
        ]))
        config.image = Icons.arrowRight.image
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(Colors.gray70.color)
            .resizeImage(scaledTo: 16)
        config.imagePadding = 4

        let button = UIButton(configuration: config)
        return button
    }()

    private let nextButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(Strings.WriteDetailMenu.next, attributes: AttributeContainer([
            .font: Fonts.semiBold.font(size: 16),
            .foregroundColor: Colors.systemWhite.color
        ]))
        config.background.cornerRadius = 0
        let button = UIButton(configuration: config)
        button.backgroundColor = Colors.mainPink.color
        return button
    }()

    private let buttonBackground: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.mainPink.color
        return view
    }()

    private let viewModel: WriteDetailMenuViewModel
    private let photoPicker = MenuPhotoPicker()
    private var gradientLayer: CAGradientLayer?
    private var currentInset: CGFloat = .zero
    private let tapBackground = UITapGestureRecognizer()

    override var screenName: ScreenName {
        return viewModel.output.screenName
    }

    init(viewModel: WriteDetailMenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addKeyboardObservers()
        bind()
        viewModel.input.viewDidLoad.send(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradientToSkipButton()
        updateStickyTab()
    }

    private func setupUI() {
        view.backgroundColor = Colors.systemWhite.color
        view.addSubViews([
            scrollView,
            skipButton,
            nextButton,
            buttonBackground
        ])
        scrollView.addSubview(stackView)
        scrollView.delegate = self
        contentView.attachStickyTab(to: view)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(imageMenuButtonContainerView)
        stackView.addArrangedSubview(contentView, previousSpace: 16)

        imageMenuButtonContainerView.addSubview(imageMenuButton)
        imageMenuButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }

        scrollView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIUtils.windowBounds.width)
        }

        skipButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top)
            $0.height.equalTo(48)
        }

        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }

        buttonBackground.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    private func setupNavigationBar() {
        guard let navigationController = navigationController as? WriteNavigationController else { return }
        navigationController.isNavigationBarHidden = false
        if viewModel.output.afterCreatedStore {
            title = Strings.WriteDetailMenu.Navigation.Title.afterCreated
            navigationController.setProgressHidden(true)
            navigationItem.rightBarButtonItem = nil
        } else {
            title = Strings.WriteDetailMenu.Navigation.Title.normal
            navigationController.updateProgress(0.75)
            navigationController.setProgressHidden(false)

            let closeImage = DesignSystemAsset.Icons.close.image
                .resizeImage(scaledTo: 24)
                .withRenderingMode(.alwaysTemplate)
                .withTintColor(.white)
            let closeButtonItem = UIBarButtonItem(
                image: closeImage,
                style: .plain,
                target: self,
                action: #selector(didTapClose)
            )
            closeButtonItem.tintColor = Colors.gray100.color
            navigationItem.setAutoInsetRightBarButtonItem(closeButtonItem)
        }
    }

    private func bind() {
        scrollView.addGestureRecognizer(tapBackground)
        tapBackground.cancelsTouchesInView = false
        tapBackground.tapPublisher
            .sink { [weak self] _ in
                self?.view.endEditing(true)
            }
            .store(in: &cancellables)

        bindAfterCreateStore(viewModel.output.afterCreatedStore)

        imageMenuButton.tapPublisher
            .throttleClick()
            .sink { [weak self] in
                self?.presentMenuPhotoPicker()
            }
            .store(in: &cancellables)

        contentView.categoryView.addMenuButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapAddMenu)
            .store(in: &cancellables)

        contentView.tabView.onSelectCategory = { [weak self] index in
            self?.viewModel.input.selectCategory.send(index)
        }

        contentView.tabView.onTapFilter = { [weak self] in
            self?.viewModel.input.didTapEditCategory.send(())
        }

        skipButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapSkip)
            .store(in: &cancellables)

        nextButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapNext)
            .store(in: &cancellables)

        Publishers.CombineLatest(viewModel.output.categories, viewModel.output.selectedCategoryIndex)
            .main
            .sink { [weak self] (categories, index) in
                self?.contentView.bind(categories: categories, selectedIndex: index)
            }
            .store(in: &cancellables)

        viewModel.output.menus
            .main
            .sink { [weak self] viewModels in
                self?.contentView.reloadMenus(viewModels)
                self?.view.layoutIfNeeded()
                self?.updateStickyTab()
            }
            .store(in: &cancellables)

        viewModel.output.addMenus
            .main
            .sink { [weak self] viewModel in
                self?.contentView.appendMenuView(viewModel)
                self?.scrollToBottom()
            }
            .store(in: &cancellables)

        viewModel.output.toast
            .main
            .sink { message in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)

        viewModel.output.route
            .main
            .sink { [weak self] route in
                self?.handleRoute(route)
            }
            .store(in: &cancellables)
    }

    private func bindAfterCreateStore(_ afterCreateStore: Bool) {
        let string = afterCreateStore ? Strings.WriteDetailMenu.finish : Strings.WriteDetailMenu.next
        nextButton.configuration?.attributedTitle = AttributedString(string, attributes: AttributeContainer([
            .font: Fonts.semiBold.font(size: 16),
            .foregroundColor: Colors.systemWhite.color
        ]))
        skipButton.isHidden = afterCreateStore
    }

    private func presentMenuPhotoPicker() {
        view.endEditing(true)
        photoPicker.present(from: self) { [weak self] image in
            self?.viewModel.input.didSelectMenuImage.send(image)
        }
    }

    private func applyGradientToSkipButton() {
        guard gradientLayer.isNil else { return }
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            Colors.systemWhite.color.withAlphaComponent(0.0).cgColor,
            Colors.systemWhite.color.withAlphaComponent(1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = skipButton.bounds

        skipButton.layer.insertSublayer(gradientLayer, at: 0)
        self.gradientLayer = gradientLayer
    }

    private func updateStickyTab() {
        contentView.updateStickyTabFrame(in: view, stickyTopY: scrollView.frame.minY)
    }

    private func scrollToBottom() {
        view.layoutIfNeeded()
        let inset = scrollView.adjustedContentInset
        let bottomOffsetY = scrollView.contentSize.height - scrollView.bounds.height + inset.bottom
        scrollView.setContentOffset(CGPoint(x: 0, y: max(-inset.top, bottomOffsetY)), animated: true)
    }

    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard currentInset == .zero else { return }
        let keyboardHeight = UIUtils.mapNotificationToKeyboardHeight(notification: notification)
        let inset = keyboardHeight > 0 ? (keyboardHeight - view.safeAreaInsets.bottom) : 0
        currentInset = inset
        scrollView.contentInset.bottom += inset
    }

    @objc private func keyboardWillHide(_ sender: Notification) {
        scrollView.contentInset.bottom -= currentInset
        currentInset = .zero
    }

    @objc private func didTapClose() {
        presentDismissModal()
    }
}

// MARK: - Route
extension WriteDetailMenuViewController {
    private func handleRoute(_ route: WriteDetailMenuViewModel.Route) {
        switch route {
        case .presentCategoryBottomSheet(let viewModel):
            presentCategoryBottomSheet(viewModel: viewModel)
        case .pushMenuExtractionLoading(let viewModel):
            pushMenuExtractionLoading(viewModel: viewModel)
        case .popToSelf:
            navigationController?.popToViewController(self, animated: true)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        case .pop:
            navigationController?.popViewController(animated: true)
        }
    }

    private func presentDismissModal() {
        let viewController = WriteCloseViewController { [weak self] in
            self?.dismiss(animated: true)
        }
        present(viewController, animated: true)
    }

    private func presentCategoryBottomSheet(viewModel: WriteDetailCategoryBottomSheetViewModel) {
        let viewController = WriteDetailCategoryBottomSheetViewController(viewModel: viewModel)
        presentPanModal(viewController)
    }

    private func pushMenuExtractionLoading(viewModel: MenuExtractionLoadingViewModel) {
        let viewController = MenuExtractionLoadingViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension WriteDetailMenuViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateStickyTab()
    }
}
