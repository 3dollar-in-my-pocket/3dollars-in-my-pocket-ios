import UIKit
import Combine

import Common
import DesignSystem
import Model

final class SigninAnonymousViewController: BaseViewController {
    private let signinAnonymousView = SigninAnonymousView()
    private let viewModel = SigninAnonymousViewModel()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance() -> SigninAnonymousViewController {
        return SigninAnonymousViewController(nibName: nil, bundle: nil).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func loadView() {
        self.view = signinAnonymousView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bindEvent() {
        signinAnonymousView.closeButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink(receiveValue: { owner, _ in
                owner.dismiss(animated: true)
            })
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        signinAnonymousView.kakaoButton
            .controlPublisher(for: .touchUpInside)
            .map { _ in SocialType.kakao }
            .subscribe(viewModel.input.onTapSignin)
            .store(in: &cancellables)
        
        signinAnonymousView.appleButton
            .controlPublisher(for: .touchUpInside)
            .map { _ in SocialType.apple }
            .subscribe(viewModel.input.onTapSignin)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .dismiss:
                    owner.dismiss(animated: true)
                    
                case .showAlreadyExist(let signinRequest):
                    owner.showAlreadyExist(signinRequest: signinRequest)
                    
                case .showErrorAlert(let error):
                    fatalError("AlertUtils 구현 필요")
//                    owner.showErrorAlert(error: error)
                    
                case .showLoading(let isShow):
                    DesignSystem.LoadingManager.shared.showLoading(isShow: isShow)
                }
            }
            .store(in: &cancellables)
    }
    
    private func showAlreadyExist(signinRequest: SigninRequest) {
        fatalError("AlertUtils 구현 필요")
//        AlertUtils.showWithCancel(
//            viewController: self,
//            message: Strings.signinWithExistedAccount
//        ) { [weak self] in
//            self?.viewModel.input.signin.send(signinRequest)
//        }
    }
}
