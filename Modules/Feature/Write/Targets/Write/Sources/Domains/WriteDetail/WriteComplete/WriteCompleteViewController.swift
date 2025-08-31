import UIKit
import Combine

import Common
import DesignSystem
import Model
import SnapKit

final class WriteCompleteViewController: BaseViewController {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 32, left: 20, bottom: 20, right: 20)
        return stackView
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = WriteAsset.iconClap.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.WriteComplete.title
        label.font = Fonts.bold.font(size: 24)
        label.textColor = Colors.gray100.color
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let overviewContainer: UIView = {
        let view = UIView()
        view.layer.borderColor = Colors.gray30.color.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let storeNameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.gray100.color
        label.textAlignment = .center
        return label
    }()
    
    private let storeCategoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.WriteComplete.description
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray80.color
        label.textAlignment = .center
        return label
    }()
    
    private let addStoreMenuButton = WriteCompleteAdditionalButton(
        icon: WriteAsset.iconForkKnife.image,
        title: Strings.WriteComplete.AddMenu.title,
        description: Strings.WriteComplete.AddMenu.description
    )
    
    private let addAdditionalInfoButton = WriteCompleteAdditionalButton(
        icon: WriteAsset.iconMegaphone.image,
        title: Strings.WriteComplete.AddInfo.title,
        description: Strings.WriteComplete.AddInfo.description
    )
    
    private let completeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(Strings.WriteComplete.finish, attributes: AttributeContainer([
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
    
    private let viewModel: WriteCompleteViewModel
    
    init(viewModel: WriteCompleteViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.systemWhite.color
        view.addSubViews([
            stackView,
            completeButton,
            buttonBackground
        ])
        
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(56)
        }
        
        // Icon container
        let iconContainer = UIView()
        iconContainer.addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(40)
        }
        iconContainer.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        stackView.addArrangedSubview(iconContainer)
        stackView.addArrangedSubview(titleLabel, previousSpace: 4)
        stackView.addArrangedSubview(overviewContainer, previousSpace: 12)
        
        overviewContainer.snp.makeConstraints {
            $0.height.equalTo(80)
        }
        
        overviewContainer.addSubViews([
            storeNameLabel,
            storeCategoryStackView
        ])
        
        storeNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        storeCategoryStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(20)
        }
        
        stackView.addArrangedSubview(descriptionLabel, previousSpace: 28)
        stackView.addArrangedSubview(addStoreMenuButton, previousSpace: 12)
        stackView.addArrangedSubview(addAdditionalInfoButton, previousSpace: 8)
        
        completeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        buttonBackground.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(completeButton.snp.bottom)
        }
    }
    
    private func bind() {
        // Input
        addStoreMenuButton.tapPublisher
            .eraseToAnyPublisher()
            .throttleClick()
            .subscribe(viewModel.input.didTapAddMenu)
            .store(in: &cancellables)
        
        addAdditionalInfoButton.tapPublisher
            .eraseToAnyPublisher()
            .throttleClick()
            .subscribe(viewModel.input.didTapAddAdditionalInfo)
            .store(in: &cancellables)
        
        completeButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapComplete)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.userStoreResponse
            .main
            .sink { [weak self] userStoreResponse in
                self?.updateStore(userStoreResponse)
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
        guard let navigationController = navigationController as? WriteNavigationController else { return }
        navigationController.setProgressHidden(true)
        navigationController.isNavigationBarHidden = true
    }
    
    private func updateStore(_ store: UserStoreResponse) {
        storeNameLabel.text = store.name
        updateStoreCategory(store.categories)
        
        let isValidMenus = store.menusV3.allSatisfy { $0.name.isNotEmpty } && store.menusV3.isNotEmpty
        addStoreMenuButton.bind(isChecked: isValidMenus)
        updateAddAdditionalInfoButton(store: store)
    }
    
    private func updateStoreCategory(_ categories: [StoreFoodCategoryResponse]) {
        storeCategoryStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for category in categories {
            let tagView = CategoryTagView(category: category)
            storeCategoryStackView.addArrangedSubview(tagView)
        }
    }
    
    private func updateAddAdditionalInfoButton(store: UserStoreResponse) {
        let isChecked = store.paymentMethods.isNotEmpty || store.appearanceDays.isNotEmpty || (store.openingHours?.isValid ?? false)
        addAdditionalInfoButton.bind(isChecked: isChecked)
    }
}

// MARK: Route
extension WriteCompleteViewController {
    private func handleRoute(_ route: WriteCompleteViewModel.Route) {
        switch route {
        case .pushWriteDetailMenu(let viewModel):
            pushWriteDetailMenu(viewModel)
        case .pushWriteDetailAdditionalInfo(let viewModel):
            pushWriteDetailAdditionalInfo(viewModel)
        case .tosat(let message):
            ToastManager.shared.show(message: message)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
    
    private func pushWriteDetailMenu(_ viewModel: WriteDetailMenuViewModel) {
        let viewController = WriteDetailMenuViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushWriteDetailAdditionalInfo(_ viewModel: WriteDetailAdditionalInfoViewModel) {
        let viewController = WriteDetailAdditionalInfoViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

private class CategoryTagView: UIStackView {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 10)
        label.textColor = Colors.mainPink.color
        return label
    }()
    
    init(category: StoreFoodCategoryResponse) {
        super.init(frame: .zero)
        
        setupUI()
        imageView.setImage(urlString: category.imageUrl)
        titleLabel.text = category.name
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.cornerRadius = 4
        layer.masksToBounds = true
        spacing = 2
        axis = .horizontal
        layoutMargins = .init(top: 2, left: 4, bottom: 2, right: 4)
        isLayoutMarginsRelativeArrangement = true
        backgroundColor = Colors.pink100.color
        addArrangedSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.size.equalTo(16)
        }
        
        addArrangedSubview(titleLabel)
    }
}
