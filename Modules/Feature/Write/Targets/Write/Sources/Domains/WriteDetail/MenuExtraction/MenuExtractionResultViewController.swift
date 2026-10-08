import UIKit
import Combine

import Common
import DesignSystem
import Model

final class MenuExtractionResultViewController: BaseViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = Colors.systemWhite.color
        return scrollView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.layoutMargins = .init(top: 0, left: 0, bottom: 24, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        return stackView
    }()

    private let titleLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 20, bottomInset: 16, leftInset: 20, rightInset: 20)
        label.font = Fonts.bold.font(size: 24)
        label.textColor = Colors.gray100.color
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private let contentView = MenuFormContentView(showsFilterButton: false)

    private let bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
        return view
    }()

    private let bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray10.color
        return view
    }()

    private let registerButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(Strings.MenuExtractionResult.register, attributes: AttributeContainer([
            .font: Fonts.semiBold.font(size: 16),
            .foregroundColor: Colors.systemWhite.color
        ]))
        config.cornerStyle = .fixed
        config.background.cornerRadius = 12
        config.background.backgroundColor = Colors.mainPink.color
        return UIButton(configuration: config)
    }()

    private let viewModel: MenuExtractionResultViewModel
    private var currentInset: CGFloat = .zero
    private let tapBackground = UITapGestureRecognizer()

    init(viewModel: MenuExtractionResultViewModel) {
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
        updateStickyHeader()
    }

    private func setupUI() {
        view.backgroundColor = Colors.systemWhite.color
        titleLabel.text = Strings.MenuExtractionResult.titleFormat(viewModel.output.recognizedMenuCount)
        view.addSubViews([
            scrollView,
            bottomContainerView
        ])
        scrollView.addSubview(stackView)
        scrollView.delegate = self
        contentView.attachStickyHeader(to: view)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(contentView)
        bottomContainerView.addSubViews([
            bottomLineView,
            registerButton
        ])

        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomContainerView.snp.top)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIUtils.windowBounds.width)
        }

        bottomContainerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }

        bottomLineView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        registerButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
        }
    }

    private func setupNavigationBar() {
        if viewModel.output.afterCreatedStore {
            title = Strings.WriteDetailMenu.Navigation.Title.afterCreated
            navigationItem.rightBarButtonItem = nil
            return
        }

        title = Strings.WriteDetailMenu.Navigation.Title.normal
        let closeImage = DesignSystemAsset.Icons.close.image
            .resizeImage(scaledTo: 24)
            .withRenderingMode(.alwaysTemplate)
        let closeButtonItem = UIBarButtonItem(
            image: closeImage,
            style: .plain,
            target: self,
            action: #selector(didTapClose)
        )
        closeButtonItem.tintColor = Colors.gray100.color
        navigationItem.setAutoInsetRightBarButtonItem(closeButtonItem)
    }

    private func bind() {
        scrollView.addGestureRecognizer(tapBackground)
        tapBackground.cancelsTouchesInView = false
        tapBackground.tapPublisher
            .sink { [weak self] _ in
                self?.view.endEditing(true)
            }
            .store(in: &cancellables)

        contentView.tabView.onSelectCategory = { [weak self] index in
            self?.viewModel.input.selectCategory.send(index)
        }

        contentView.categoryView.addMenuButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapAddMenu)
            .store(in: &cancellables)

        registerButton.tapPublisher
            .throttleClick()
            .handleEvents(receiveOutput: { [weak self] in
                self?.view.endEditing(true)
            })
            .subscribe(viewModel.input.didTapRegister)
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
                self?.updateStickyHeader()
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
    }

    private func updateStickyHeader() {
        contentView.updateStickyHeaderFrame(in: view, stickyTopY: scrollView.frame.minY)
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
        let viewController = WriteCloseViewController { [weak self] in
            self?.dismiss(animated: true)
        }
        present(viewController, animated: true)
    }
}

extension MenuExtractionResultViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateStickyHeader()
    }
}
