import UIKit

import Common

final class SigninViewController: Common.BaseViewController {
    private let signinView = SigninView()
    private let viewModel = SigninViewModel()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance() -> UINavigationController {
        let controller = SigninViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        
        navigationController.isNavigationBarHidden = true
        navigationController.interactivePopGestureRecognizer?.delegate = nil
        return navigationController
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.signinView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DeeplinkManager.shared.flushDelayedDeeplink()
    }
    
    override func bindViewModelInput() {
        signinView.kakaoButton
            .controlPublisher(for: .touchUpInside)
            .map { _ in .kakao }
            .subscribe(viewModel.input.onTapSignin)
            .store(in: &cancellables)
        
        signinView.appleButton
            .controlPublisher(for: .touchUpInside)
            .map { _ in .apple }
            .subscribe(viewModel.input.onTapSignin)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .pushNickname(let socialType, let accessToken):
                    let signinRequest = SigninRequest(socialType: socialType, token: accessToken)
                    let viewController = NicknameViewController.instance(
                        socialType: socialType,
                        accessToken: accessToken
                    )
                    
                    owner.navigationController?.pushViewController(viewController, animated: true)
                    
                default:
                    break
                }
                print("💜route: \(route)")
            }
            .store(in: &cancellables)
    }
    
    func bind(reactor: SigninReactor) {
//        // Bind State
//        reactor.pulse(\.$goToMain)
//            .compactMap { $0 }
//            .asDriver(onErrorJustReturn: ())
//            .drive(onNext: { [weak self] _ in
//                self?.coordinator?.goToMain()
//            })
//            .disposed(by: self.disposeBag)
//        
//        reactor.pulse(\.$pushNickname)
//            .compactMap { $0 }
//            .asDriver(onErrorJustReturn: SigninRequest(socialType: .unknown, token: ""))
//            .drive(onNext: { [weak self] signinRequest in
//                self?.coordinator?.pushNickname(signinRequest: signinRequest)
//            })
//            .disposed(by: self.disposeBag)
//        
//        reactor.pulse(\.$showErrorAlert)
//            .compactMap { $0 }
//            .asDriver(onErrorJustReturn: BaseError.unknown)
//            .drive(onNext: { [weak self] error in
//                self?.coordinator?.showErrorAlert(error: BaseError.unknown)
//            })
//            .disposed(by: self.disposeBag)
//        
//        reactor.pulse(\.$showLoading)
//            .compactMap { $0 }
//            .asDriver(onErrorJustReturn: false)
//            .drive(onNext: { [weak self] isShow in
//                self?.coordinator?.showLoading(isShow: isShow)
//            })
//            .disposed(by: self.disposeBag)
    }
    
    private func handleDeeplink(contents: DeepLinkContents) {
        let rootViewController = SceneDelegate.shared?.window?.rootViewController
        
        guard let targetViewController = contents.targetViewController,
              let transitionType = contents.transitionType else { return }
        
        switch transitionType {
        case .push:
            if let navigationController = rootViewController as? UINavigationController {
                navigationController.pushViewController(
                    targetViewController,
                    animated: true
                )
            } else {
                Log.error("UINavigationViewController가 없습니다.")
            }
            
        case .present:
            rootViewController?.present(targetViewController, animated: true)
        }
    }
}
