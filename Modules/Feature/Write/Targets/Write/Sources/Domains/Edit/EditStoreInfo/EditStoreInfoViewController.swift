import UIKit
import Combine

import Common
import DesignSystem
import Model
import SnapKit

final class EditStoreInfoViewController: BaseViewController {
    private let scrollView = UIScrollView()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let nameTextField = NameTextField()
    private let storeTypeField = StoreTypeField()
    private let paymentMethodView = PaymentMethodSectionView()
    private let appearanceDayView = AppearanceDaysSectionView()
    private let openingHoursView = OpeningHoursSectionView()
    
    private let saveButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("수정하기", attributes: AttributeContainer([
            .font: Fonts.bold.font(size: 16),
            .foregroundColor: Colors.systemWhite.color
        ]))
        let button = UIButton(configuration: config)
        button.backgroundColor = Colors.mainPink.color
        return button
    }()
    
    private let buttonBackground: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.mainPink.color
        return view
    }()
    
    private let viewModel: EditStoreInfoViewModel
    private var currentInset: CGFloat = .zero
    private let tapBackground = UITapGestureRecognizer()
    
    init(viewModel: EditStoreInfoViewModel) {
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
    
    private func setupUI() {
        view.backgroundColor = Colors.systemWhite.color
        view.addSubViews([
            scrollView,
            saveButton,
            buttonBackground
        ])
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(storeTypeField, previousSpace: 28)
        stackView.addArrangedSubview(paymentMethodView, previousSpace: 28)
        stackView.addArrangedSubview(appearanceDayView, previousSpace: 28)
        stackView.addArrangedSubview(openingHoursView, previousSpace: 28)
        
        scrollView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(saveButton.snp.top)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.equalTo(UIUtils.windowBounds.width)
        }

        nameTextField.snp.makeConstraints {
            $0.height.equalTo(76)
        }
        
        storeTypeField.snp.makeConstraints {
            $0.height.equalTo(64)
        }
        
        buttonBackground.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        nameTextField.setDelegate(self)
    }
    
    private func setupNavigationBar() {
        title = "가게 정보 수정"
    }
    
    private func bind() {
        scrollView.addGestureRecognizer(tapBackground)
        
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
        
        paymentMethodView.selectedPaymentMethods
            .subscribe(viewModel.input.selectPaymentMethod)
            .store(in: &cancellables)
        
        appearanceDayView.selectedDayChanged
            .subscribe(viewModel.input.selectAppearanceDay)
            .store(in: &cancellables)
        
        openingHoursView.startTimeChanged
            .subscribe(viewModel.input.selectStartTime)
            .store(in: &cancellables)
        
        openingHoursView.endTimeChanged
            .subscribe(viewModel.input.selectEndTime)
            .store(in: &cancellables)
        
        saveButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapSave)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.store
            .main
            .sink { [weak self] store in
                self?.bind(store: store)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .sink { [weak self] route in
                self?.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func bind(store: UserStoreResponse) {
        nameTextField.setName(store.name)
        storeTypeField.selectStoreType(store.salesTypeV2?.type ?? .road)
        paymentMethodView.selectPaymentMethods(store.paymentMethods)
        appearanceDayView.selectDays(store.appearanceDays)
        openingHoursView.setStartTime(store.openingHours?.startTime?.toDate(format: "HH:mm"))
        openingHoursView.setEndTime(store.openingHours?.endTime?.toDate(format: "HH:mm"))
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
}

// MARK: Route
extension EditStoreInfoViewController {
    private func handleRoute(_ route: EditStoreInfoViewModel.Route) {
        switch route {
        case .pop:
            navigationController?.popViewController(animated: true)
        case .showToast(let message):
            ToastManager.shared.show(message: message)
        }
    }
}

extension EditStoreInfoViewController: UITextFieldDelegate {
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
