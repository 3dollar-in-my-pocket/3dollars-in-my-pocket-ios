import UIKit

import ReactorKit

protocol PolicyViewControllerDelegate: AnyObject {
    func onDismiss()
}

final class PolicyViewController: BaseViewController, View, PolicyCoordinator {
    private let policyView = PolicyView()
    private let policyReactor = PolicyReactor(
        userService: UserService(),
        analyticsManager: GA.shared
    )
    private weak var coordinator: PolicyCoordinator?
    private weak var delegate: PolicyViewControllerDelegate?
    
    static func instance(delegate: PolicyViewControllerDelegate? = nil) -> UINavigationController {
        let viewController = PolicyViewController(nibName: nil, bundle: nil)
        
        viewController.delegate = delegate
        return UINavigationController(rootViewController: viewController).then {
            $0.isNavigationBarHidden = true
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func loadView() {
        self.view = self.policyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = self.presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        self.coordinator = self
        self.reactor = self.policyReactor
    }
    
    override func bindEvent() {
        self.policyView.backgroundButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.policyView.policyButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.pushPolicyPage()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.policyView.marketingButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.pushMarketingPage()
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: PolicyReactor) {
        // Bind Action
        self.policyView.allCheckButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapAllCheckButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.policyView.policyCheckButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapPolicyCheck }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.policyView.marketingCheckButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapMarketingCheck }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.policyView.nextButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapNext }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.isCheckedAll }
            .asDriver(onErrorJustReturn: false)
            .drive(self.policyView.allCheckButton.rx.isSelected)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isCheckedPolicy }
            .asDriver(onErrorJustReturn: false)
            .drive(self.policyView.policyCheckButton.rx.isSelected)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isCheckedMarketing }
            .asDriver(onErrorJustReturn: false)
            .drive(self.policyView.marketingCheckButton.rx.isSelected)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isEnableNextButton }
            .asDriver(onErrorJustReturn: false)
            .drive(self.policyView.nextButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        // Bind Pulse
        reactor.pulse(\.$showErrorAlert)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$isShowLoading)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$dismiss)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss(completion: {
                    self?.delegate?.onDismiss()
                })
            })
            .disposed(by: self.disposeBag)
    }
}
