import UIKit

import Base
import ReactorKit

final class PolicyViewController: BaseViewController, View, PolicyCoordinator {
    private let policyView = PolicyView()
    private let policyReactor = PolicyReactor(deviceService: DeviceService())
    private weak var coordinator: PolicyCoordinator?
    
    static func instance() -> PolicyViewController {
        return PolicyViewController(nibName: nil, bundle: nil).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func loadView() {
        self.view = self.policyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.reactor = self.policyReactor
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
        
        reactor.pulse(\.$pushPolicy)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.pushPolicyPage()
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$pushMarketing)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.pushMarketingPage()
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$isShowLoading)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$dismissAndGoHome)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismissAndGoHome()
            })
            .disposed(by: self.disposeBag)
    }
}
