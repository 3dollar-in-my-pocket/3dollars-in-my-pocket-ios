import UIKit

import Combine
import Common
import DesignSystem
import AppInterface
import DependencyInjection

protocol PolicyViewControllerDelegate: AnyObject {
    func onDismiss()
}

final class PolicyViewController: Common.BaseViewController {
    private weak var delegate: PolicyViewControllerDelegate?
    private let policyView = PolicyView()
    private let viewModel = PolicyViewModel()
    private let appInterface: AppModuleInterface?
    
    static func instance(delegate: PolicyViewControllerDelegate? = nil) -> UINavigationController {
        let viewController = PolicyViewController()
        
        viewController.delegate = delegate
        return UINavigationController(rootViewController: viewController).then {
            $0.isNavigationBarHidden = true
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    init() {
        self.appInterface = DIContainer.shared.container.resolve(AppModuleInterface.self)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                    LoadingManager.shared.showLoading(isShow: isShow)
                    
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
        guard let viewController = appInterface?.createWebViewController(webviewType: .policy) else { return }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushMarketingPage() {
        guard let viewController = appInterface?.createWebViewController(webviewType: .marketing) else { return }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
