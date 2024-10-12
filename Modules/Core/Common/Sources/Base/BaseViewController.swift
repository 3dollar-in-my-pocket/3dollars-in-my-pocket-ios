import UIKit
import Combine

import Model
import Log
import DependencyInjection
import AppInterface
import DesignSystem

open class BaseViewController: UIViewController {
    open var cancellables = Set<AnyCancellable>()
    open var screenName: ScreenName {
        return .empty
    }
    open var navigationBar: UINavigationBar?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        bindEvent()
        bindViewModelInput()
        bindViewModelOutput()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        sendPageView()
        addBackButtonIfNeeded()
    }
    
    open func bindEvent() { }
    
    open func bindViewModelInput() { }
    
    open func bindViewModelOutput() { }
    
    open func showErrorAlert(error: Error) {
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
    
    open func addNavigationBar() {
        let navigationWrapperView = UIView()
        navigationWrapperView.backgroundColor = .clear
        navigationWrapperView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(navigationWrapperView)
        navigationWrapperView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        navigationWrapperView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navigationWrapperView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        
        let navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.setItems([navigationItem], animated: false)
        
        navigationWrapperView.addSubview(navigationBar)
        navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        navigationWrapperView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: DesignSystemFontFamily.Pretendard.semiBold.font(size: 16)
        ]
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        self.navigationBar = navigationBar
    }
    
    open func addBackButtonIfNeeded() {
        if navigationController?.children.count ?? 0 > 1 {
            let backImage = DesignSystemAsset.Icons.arrowLeft.image
                .resizeImage(scaledTo: 24)
                .withRenderingMode(.alwaysTemplate)
                .withTintColor(.white)
            let backButtonItem = UIBarButtonItem(
                image: backImage,
                style: .plain,
                target: self,
                action: #selector(didTapBack)
            )
            navigationItem.setAutoInsetLeftBarButtonItem(backButtonItem)
        }
    }
    
    @objc open func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func sendPageView() {
        if screenName != .empty {
            LogManager.shared.sendPageView(screen: screenName, type: Self.self)
        }
    }
}
