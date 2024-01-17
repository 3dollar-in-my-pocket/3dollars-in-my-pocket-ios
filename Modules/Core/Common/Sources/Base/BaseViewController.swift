import UIKit
import Combine

import Model
import Log
import DependencyInjection
import AppInterface

open class BaseViewController: UIViewController {
    open var cancellables = Set<AnyCancellable>()
    open var screenName: ScreenName {
        return .empty
    }
    
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
    
    private func sendPageView() {
        if screenName != .empty {
            LogManager.shared.sendPageView(screen: screenName, type: Self.self)
        }
    }
}
