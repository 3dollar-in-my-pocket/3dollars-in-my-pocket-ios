import UIKit
import Combine
import SnapKit

import Common
import DesignSystem
import Model
import Log

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
    
    private let descriptionLabel = DescriptionLabel()
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
    
    override var screenName: ScreenName {
        return .editStore
    }
    
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
                self?.descriptionLabel.bind(count: count)
            }
            .store(in: &cancellables)
        
        viewModel.output.menuCount
            .main
            .sink { [weak self] menuCount in
                self?.storeMenuSection.bind(menuCount: menuCount)
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
        case .editStoreInfo(let viewModel):
            pushEditStoreInfo(viewModel: viewModel)
        case .editMenu(let viewModel):
            pushEditMenu(viewModel: viewModel)
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
    
    private func pushEditStoreInfo(viewModel: EditStoreInfoViewModel) {
        let viewController = EditStoreInfoViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushEditMenu(viewModel: WriteDetailMenuViewModel) {
        let viewController = WriteDetailMenuViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension EditStoreViewController {
    private class DescriptionLabel: BaseView {
        private let containerStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = .center
            return stackView
        }()
        
        private let leftImageView: UIImageView = {
            let imageView = UIImageView(image: Icons.check.image.withRenderingMode(.alwaysTemplate))
            imageView.tintColor = Colors.mainGreen.color
            return imageView
        }()
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = Fonts.regular.font(size: 14)
            label.textAlignment = .center
            return label
        }()
        
        private let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 4
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layer.masksToBounds = true
            stackView.alignment = .center
            return stackView
        }()
        
        override func setup() {
            super.setup()
            addSubview(containerStackView)
            
            let leftSpacer = UIView()
            let rightSpacer = UIView()
            
            containerStackView.addArrangedSubview(leftSpacer)
            containerStackView.addArrangedSubview(stackView)
            containerStackView.addArrangedSubview(rightSpacer)
            
            containerStackView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            leftSpacer.snp.makeConstraints {
                $0.width.equalTo(rightSpacer)
            }
        }
        
        func bind(count: Int?) {
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            if let count, count > 0 {
                stackView.backgroundColor = Colors.green100.color
                stackView.addArrangedSubview(leftImageView)
                leftImageView.snp.makeConstraints {
                    $0.size.equalTo(16)
                }
                stackView.addArrangedSubview(titleLabel)
                stackView.layoutMargins = .init(top: 6, left: 12, bottom: 6, right: 16)
                stackView.layer.cornerRadius = 14
                titleLabel.text = "\(count)개의 수정된 정보가 있어요"
                titleLabel.textColor = Colors.mainGreen.color
                snp.updateConstraints {
                    $0.height.equalTo(28)
                }
            } else {
                stackView.backgroundColor = .clear
                stackView.addArrangedSubview(titleLabel)
                stackView.layoutMargins = .zero
                stackView.layer.cornerRadius = 0
                titleLabel.text = "작은 제보로 가게 정보 완성에 힘을 보태요"
                titleLabel.textColor = Colors.gray70.color
                snp.updateConstraints {
                    $0.height.equalTo(20)
                }
            }
        }
    }
}
