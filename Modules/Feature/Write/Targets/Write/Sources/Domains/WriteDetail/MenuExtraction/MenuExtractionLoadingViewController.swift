import UIKit

import Common
import DesignSystem
import Model

final class MenuExtractionLoadingViewController: BaseViewController {
    private let loadingView = LoadingView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MenuExtractionLoading.title
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray70.color
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MenuExtractionLoading.description
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray70.color
        label.textAlignment = .center
        return label
    }()

    private let viewModel: MenuExtractionLoadingViewModel

    init(viewModel: MenuExtractionLoadingViewModel) {
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
        viewModel.input.viewDidLoad.send(())
    }

    override func addBackButtonIfNeeded() { }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        loadingView.startLoading()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadingView.stopLoading()
    }

    private func setupUI() {
        view.backgroundColor = Colors.gray0.color
        view.addSubViews([
            loadingView,
            titleLabel,
            descriptionLabel
        ])

        loadingView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-60)
            $0.size.equalTo(150)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(loadingView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }

    private func setupNavigationBar() {
        title = viewModel.output.afterCreatedStore
            ? Strings.WriteDetailMenu.Navigation.Title.afterCreated
            : Strings.WriteDetailMenu.Navigation.Title.normal
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

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
        viewModel.output.route
            .main
            .sink { [weak self] route in
                self?.handleRoute(route)
            }
            .store(in: &cancellables)
    }

    @objc private func didTapClose() {
        viewModel.input.didTapClose.send(())
    }
}

// MARK: Route
extension MenuExtractionLoadingViewController {
    private func handleRoute(_ route: MenuExtractionLoadingViewModel.Route) {
        switch route {
        case .replaceWithResult(let viewModel):
            replaceWithResult(viewModel: viewModel)
        case .showErrorAlert(let error):
            showExtractionErrorAlert(error: error)
        case .close:
            close()
        }
    }

    private func replaceWithResult(viewModel: MenuExtractionResultViewModel) {
        guard let navigationController else { return }
        let viewController = MenuExtractionResultViewController(viewModel: viewModel)
        var viewControllers = navigationController.viewControllers
        viewControllers.removeAll { $0 === self }
        viewControllers.append(viewController)
        navigationController.setViewControllers(viewControllers, animated: true)
    }

    private func showExtractionErrorAlert(error: Error) {
        if case .errorContainer(let container) = error as? NetworkError, container.resultCode == "UA000" {
            showErrorAlert(error: error)
            return
        }

        AlertUtils.showWithAction(viewController: self, message: errorMessage(error)) { [weak self] in
            self?.close()
        }
    }

    private func errorMessage(_ error: Error) -> String {
        switch error as? NetworkError {
        case .message(let message):
            return message
        case .errorContainer(let container):
            return container.message ?? error.localizedDescription
        default:
            return error.localizedDescription
        }
    }

    private func close() {
        navigationController?.popViewController(animated: true)
    }
}
