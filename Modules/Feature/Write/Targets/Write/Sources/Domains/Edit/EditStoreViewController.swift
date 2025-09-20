import UIKit
import Combine
import SnapKit

import Common
import DesignSystem
import Model

final class EditStoreViewController: BaseViewController {
    private let viewModel: EditStoreViewModel
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "제보할 정보를\n선택해 주세요"
        label.numberOfLines = 2
        label.textColor = Colors.gray100.color
        label.font = Fonts.bold.font(size: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "작은 제보로 가게 정보 완성에 힘을 보탬니다"
        label.textColor = Colors.gray70.color
        label.font = Fonts.regular.font(size: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let storeAddressSection = EditStoreAddressView()
    private let storeInfoSection = EditStoreInfoView()
    private let storeMenuSection = EditStoreMenuView()
    
    private let editButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("수정 완료", attributes: .init([
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
    
    init(viewModel: EditStoreViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.systemWhite.color
        setupNavigationBar()

        view.addSubViews([
            stackView,
            editButton,
            buttonBackground
        ])
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel, previousSpace: 8)
        stackView.addArrangedSubview(storeAddressSection, previousSpace: 24)
        stackView.addArrangedSubview(storeInfoSection, previousSpace: 8)
        stackView.addArrangedSubview(storeMenuSection, previousSpace: 8)
        
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        editButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        buttonBackground.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(editButton.snp.bottom)
        }
    }
    
    private func bind() {
        storeAddressSection.tapGesture.tapPublisher
            .throttleClick()
            .mapVoid
            .subscribe(viewModel.input.didTapAddress)
            .store(in: &cancellables)
        
        storeInfoSection.tapGesture.tapPublisher
            .throttleClick()
            .mapVoid
            .subscribe(viewModel.input.didTapStoreInfo)
            .store(in: &cancellables)
        
        storeMenuSection.tapGesture.tapPublisher
            .throttleClick()
            .mapVoid
            .subscribe(viewModel.input.didTapMenu)
            .store(in: &cancellables)
        
        editButton.tapPublisher
            .throttleClick()
            .mapVoid
            .subscribe(viewModel.input.didTapEdit)
            .store(in: &cancellables)
        
        viewModel.output.store
            .main
            .sink { [weak self] store in
                self?.bindStore(store)
                
            }.store(in: &cancellables)
        
        viewModel.output.changedCount
            .main
            .sink { [weak self] count in
                
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .sink { [weak self] route in
                self?.handleRoute(route)
            }
            .store(in: &cancellables)
        
        viewModel.output.isLoading
            .main
            .sink { isLoading in
                LoadingManager.shared.showLoading(isShow: isLoading)
            }
            .store(in: &cancellables)
    }
    
    private func setupNavigationBar() {
        title = "가게 정보 수정"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: Colors.gray100.color,
            .font: Fonts.medium.font(size: 16)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let closeButton = UIBarButtonItem(
            image: DesignSystemAsset.Icons.close.image.resizeImage(scaledTo: 24).withRenderingMode(.alwaysTemplate),
            style: .plain,
            target: self,
            action: #selector(didTapClose)
        )
        closeButton.tintColor = Colors.gray100.color
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func bindStore(_ store: UserStoreResponse) {
        storeAddressSection.bind(address: store.address.fullAddress)
        storeInfoSection.bind(store: store)
        storeMenuSection.bind(menuCount: store.menusV3.count)
    }
    
    @objc private func didTapClose() {
        let dismissViewController = EditDismissModalViewController()
        dismissViewController.onClose = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        present(dismissViewController, animated: true)
    }
}

// MARK: - Route
extension EditStoreViewController {
    private func handleRoute(_ route: EditStoreViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss(animated: true)
        case .pushEditAddress(let viewModel):
            pushEditAddress(viewModel: viewModel)
        case .editStoreInfo:
            // TODO: 메뉴 수정 화면 이동
            break
        case .editMenu:
            // TODO: 운영시간 수정 화면 이동
            break
        case .pop:
            navigationController?.popViewController(animated: true)
        case .toast(let message):
            ToastManager.shared.show(message: message)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
    
    private func pushEditAddress(viewModel: WriteAddressViewModel) {
        let viewController = WriteAddressViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
