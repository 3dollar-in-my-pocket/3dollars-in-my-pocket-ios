import UIKit

import Common
import DesignSystem
import Model

final class SigninBottomSheetViewController: BaseViewController {
    private let signinBottomSheetView = SigninBottomSheetView()
    private let viewModel: SigninBottomSheetViewModel
    
    init(viewModel: SigninBottomSheetViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
    }
    
    convenience init() {
        self.init(viewModel: SigninBottomSheetViewModel())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = signinBottomSheetView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
    }
    
    override func bindEvent() {
        signinBottomSheetView.backgroundButton.controlPublisher(for: .touchUpInside)
            .merge(with: signinBottomSheetView.closeButton.controlPublisher(for: .touchUpInside))
            .main
            .sink { [weak self] _ in
                DimManager.shared.hideDim()
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        signinBottomSheetView.kakaoButton.controlPublisher(for: .touchUpInside)
            .main
            .map { _ in SocialType.kakao }
            .subscribe(viewModel.input.signinWithSocial)
            .store(in: &cancellables)
        
        signinBottomSheetView.appleButton.controlPublisher(for: .touchUpInside)
            .main
            .map { _ in SocialType.apple }
            .subscribe(viewModel.input.signinWithSocial)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.route
            .main
            .sink { [weak self] (route: SigninBottomSheetViewModel.Route) in
                self?.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: SigninBottomSheetViewModel.Route) {
        switch route {
        case .goToMain:
            DimManager.shared.hideDim()
            dismiss(animated: true) {
                Environment.appModuleInterface.goToMain()
            }
        case .pushNickname(let socialType, let accessToken):
            DimManager.shared.hideDim()
            dismiss(animated: true) { [weak self] in
                let viewController = NicknameViewController.instance(
                    socialType: socialType,
                    accessToken: accessToken
                )
                
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        case .showLoading(let isShow):
            LoadingManager.shared.showLoading(isShow: isShow)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
}
