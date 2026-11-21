import UIKit

import Common
import DesignSystem
import Log

final class WriteDetailInfoViewController: BaseViewController {
    private let scrollView = UIScrollView()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
        
    private let header = Header(
        title: Strings.WriteDetailInfo.subTitle,
        descriptionText: Strings.WriteDetailInfo.description
    )
    
    private let nameTextField = NameTextField()
    
    private let storeTypeField = StoreTypeField()
    
    private let addressField = AddressField()
    
    private let nextButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(Strings.WriteDetailInfo.next, attributes: AttributeContainer([
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
    
    private let viewModel: WriteDetailInfoViewModel
    private var currentInset: CGFloat = .zero
    private let tapBackground = UITapGestureRecognizer()
    
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    init(viewModel: WriteDetailInfoViewModel) {
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
        bind()
        addKeyboardObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let navigationController = navigationController as? WriteNavigationController else { return }
        navigationController.setProgressHidden(true)
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.systemWhite.color
        view.addSubViews([
            scrollView,
            nextButton,
            buttonBackground
        ])
        scrollView.addSubViews([header, stackView])
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(storeTypeField, previousSpace: 20)
        stackView.addArrangedSubview(addressField, previousSpace: 20)
        
        scrollView.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(nextButton.snp.top)
        }
        
        header.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(header.snp.bottom)
            $0.trailing.equalToSuperview()
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        nameTextField.snp.makeConstraints {
            $0.height.equalTo(71)
        }
        
        storeTypeField.snp.makeConstraints {
            $0.height.equalTo(64)
        }
        
        addressField.snp.makeConstraints {
            $0.height.equalTo(72)
        }
        
        buttonBackground.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        nameTextField.setDelegate(self)
    }
    
    private func setupNavigationBar() {
        title = Strings.WriteDetailInfo.title
        guard let navigationController = navigationController as? WriteNavigationController else { return }
        navigationController.updateProgress(step: 1)
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
    
    private func bind() {
        scrollView.addGestureRecognizer(tapBackground)
        addressField.setAddress(viewModel.output.address)
        
        tapBackground.tapPublisher
            .sink { [weak self] _ in
                self?.view.endEditing(true)
            }
            .store(in: &cancellables)
        
        // Input
        nameTextField.textPublisher
            .subscribe(viewModel.input.storeName)
            .store(in: &cancellables)
        
        storeTypeField.tapPublisher
            .subscribe(viewModel.input.selectStoreType)
            .store(in: &cancellables)
        
        addressField.tapChangePublisher
            .subscribe(viewModel.input.didTapChangeAddress)
            .store(in: &cancellables)
        
        nextButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapNext)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.storeName
            .main
            .sink { [weak self] name in
                self?.nameTextField.setName(name)
            }
            .store(in: &cancellables)
        
        viewModel.output.storeTypes
            .main
            .sink { [weak self] storeType in
                self?.storeTypeField.selectStoreType(storeType)
            }
            .store(in: &cancellables)
        
        viewModel.output.setErrorState
            .main
            .sink { [weak self] _ in
                self?.nameTextField.setState(.error)
            }.store(in: &cancellables)
        
        viewModel.output.route
            .main
            .sink { [weak self] route in
                self?.handleRoute(route)
            }
            .store(in: &cancellables)
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
        scrollView.contentInset.bottom += currentInset
    }

    @objc private func keyboardWillHide(_ sender: Notification) {
        scrollView.contentInset.bottom -= currentInset
        currentInset = .zero
    }
    
    @objc private func didTapClose() {
        presentDismissModal()
    }
}

// MARK: Route
extension WriteDetailInfoViewController {
    private func handleRoute(_ route: WriteDetailInfoViewModel.Route) {
        switch route {
        case .pop:
            navigationController?.popViewController(animated: true)
        case .showErrorAelrt(let error):
            showErrorAlert(error: error)
        case .showToast(let message):
            ToastManager.shared.show(message: message)
        }
    }
    
    private func presentDismissModal() {
        let viewController = WriteCloseViewController { [weak self] in
            self?.dismiss(animated: true)
        }
        present(viewController, animated: true)
    }
}

extension WriteDetailInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameTextField.setState(.focused)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameTextField.setState(.done)
        viewModel.input.storeName.send(textField.text ?? "")
    }
}
