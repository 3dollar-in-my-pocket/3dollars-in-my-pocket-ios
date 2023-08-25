import UIKit

import Combine
import Common
import DesignSystem

protocol PolicyViewControllerDelegate: AnyObject {
    func onDismiss()
}

final class PolicyViewController: Common.BaseViewController {
    private weak var delegate: PolicyViewControllerDelegate?
    private let policyView = PolicyView()
    private let viewModel = PolicyViewModel()
    
    static func instance(delegate: PolicyViewControllerDelegate? = nil) -> UINavigationController {
        let viewController = PolicyViewController(nibName: nil, bundle: nil)
        
        viewController.delegate = delegate
        return UINavigationController(rootViewController: viewController).then {
            $0.isNavigationBarHidden = true
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func loadView() {
        view = policyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = self.presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
    }
    
    override func bindEvent() {
        policyView.backgroundButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { owner, _ in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        policyView.policyButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { owner, _ in
                owner.pushPolicyPage()
            }
            .store(in: &cancellables)
        
        policyView.marketingButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { owner, _ in
                owner.pushMarketingPage()
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        policyView.allCheckButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapAllCheckButton)
            .store(in: &cancellables)
        
        policyView.policyCheckButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapPolicyCheckButton)
            .store(in: &cancellables)
        
        policyView.marketingCheckButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapMarketingCheckButton)
            .store(in: &cancellables)
        
        policyView.nextButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapNextButton)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.isCheckedAll
            .receive(on: DispatchQueue.main)
            .assign(to: \.isSelected, on: policyView.allCheckButton)
            .store(in: &cancellables)
        
        viewModel.output.isCheckedPolicy
            .receive(on: DispatchQueue.main)
            .assign(to: \.isSelected, on: policyView.policyCheckButton)
            .store(in: &cancellables)
        
        viewModel.output.isCheckedMarketing
            .receive(on: DispatchQueue.main)
            .assign(to: \.isSelected, on: policyView.marketingCheckButton)
            .store(in: &cancellables)
        
        viewModel.output.isEnableNextButton
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: policyView.nextButton)
            .store(in: &cancellables)
        
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .showErrorAlert(let error):
                    owner.showErrorAlert(error: error)
                    
                case .showLoading(let isShow):
                    DesignSystem.LoadingManager.shared.showLoading(isShow: isShow)
                    
                case .dismiss:
                    DimManager.shared.hideDim()
                    owner.dismiss(animated: true) {
                        owner.delegate?.onDismiss()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func pushPolicyPage() {
        let viewController = WebViewController.instance(webviewType: .policy)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushMarketingPage() {
        let viewController = WebViewController.instance(webviewType: .marketing)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
