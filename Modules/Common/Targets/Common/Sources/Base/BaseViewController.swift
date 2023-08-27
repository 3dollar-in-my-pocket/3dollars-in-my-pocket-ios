import UIKit
import Combine

import Model

open class BaseViewController: UIViewController {
    open var cancellables = Set<AnyCancellable>()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        bindEvent()
        bindViewModelInput()
        bindViewModelOutput()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func bindEvent() { }
    
    open func bindViewModelInput() { }
    
    open func bindViewModelOutput() { }
    
    open func showErrorAlert(error: Error) {
        // TODO: unauthorized 에러 처리 필요
        if let networkError = error as? Model.NetworkError {
            switch networkError {
            case .message(let message):
                AlertUtils.showWithAction(
                    viewController: self,
                    message: message,
                    onTapOk: nil
                )
                
            case .errorContainer(let container):
                AlertUtils.showWithAction(
                    viewController: self,
                    message: container.message,
                    onTapOk: nil
                )
                
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
