import UIKit
import Combine

import DesignSystem
import Model
import Common
import DependencyInjection
import AppInterface

final class WriteNavigationController: UINavigationController {
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.trackTintColor = Colors.gray30.color
        progressView.tintColor = Colors.mainPink.color
        return progressView
    }()
    
    private let viewModel: WriteNavigationViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(rootViewController: UIViewController, viewModel: WriteNavigationViewModel) {
        self.viewModel = viewModel
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupUI()
        bind()
    }
    
    private func setupUI() {
        navigationBar.addSubview(progressView)
        
        progressView.snp.makeConstraints {
            $0.leading.equalTo(navigationBar)
            $0.trailing.equalTo(navigationBar)
            $0.bottom.equalTo(navigationBar)
            $0.height.equalTo(2)
        }
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: Colors.gray100.color,
            .font: DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        ]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func bind() {
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
    
    func updateProgress(_ progress: Float) {
        progressView.setProgress(progress, animated: true)
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}

// MARK: Route
extension WriteNavigationController {
    private func handleRoute(_ route: WriteNavigationViewModel.Route) {
        switch route {
        case .pushWriteDetailInfo(let viewModel):
            pushWriteDetailInfo(viewModel)
        case .pushWriteDetailCategory(let viewModel):
            pushWriteDetailCategory(viewModel)
        case .pushWriteDetailMenu(let viewModel):
            pushWriteDetailMenu(viewModel)
        case .pushWriteDetailAdditionalInfo(let viewModel):
            pushWriteDetailAdditionalInfo(viewModel)
        case .pushWriteComplete(let viewModel):
            pushWriteComplete(viewModel)
        case .toast(let message):
            ToastManager.shared.show(message: message)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
    
    private func pushWriteDetailInfo(_ viewModel: WriteDetailInfoViewModel) {
        let viewController = WriteDetailInfoViewController(viewModel: viewModel)
        pushViewController(viewController, animated: true)
    }
    
    private func pushWriteDetailCategory(_ viewModel: WriteDetailCategoryViewModel) {
        let viewController = WriteDetailCategoryViewController(viewModel: viewModel)
        pushViewController(viewController, animated: true)
    }
    
    private func pushWriteDetailMenu(_ viewModel: WriteDetailMenuViewModel) {
        let viewController = WriteDetailMenuViewController(viewModel: viewModel)
        pushViewController(viewController, animated: true)
    }
    
    private func pushWriteDetailAdditionalInfo(_ viewModel: WriteDetailAdditionalInfoViewModel) {
        let viewController = WriteDetailAdditionalInfoViewController(viewModel: viewModel)
        pushViewController(viewController, animated: true)
    }
    
    private func pushWriteComplete(_ viewModel: WriteCompleteViewModel) {
        let viewController = WriteCompleteViewController(viewModel: viewModel)
        pushViewController(viewController, animated: true)
    }
    
    private func showErrorAlert(error: Error) {
        if let networkError = error as? Model.NetworkError {
            switch networkError {
            case .message(let message):
                AlertUtils.showWithAction(
                    viewController: self,
                    message: message,
                    onTapOk: nil
                )
                
            case .errorContainer(let container):
                if container.resultCode == "UA000" {
                    AlertUtils.showWithAction(
                        viewController: self,
                        message: "세션이 만료되었습니다.\n다시 로그인해주세요.") {
                            guard let appModuleInterface = DIContainer.shared.container.resolve(AppModuleInterface.self) else { return }
                            
                            appModuleInterface.onClearSession()
                        }
                } else {
                    AlertUtils.showWithAction(
                        viewController: self,
                        message: container.message ?? "",
                        onTapOk: nil
                    )
                }
                
            default:
                AlertUtils.showWithAction(
                    viewController: self,
                    message: error.localizedDescription,
                    onTapOk: nil
                )
            }
        } else {
            AlertUtils.showWithAction(
                viewController: self,
                message: error.localizedDescription,
                onTapOk: nil
            )
        }
    }
    
}
