import UIKit
import Combine

open class BaseViewController: UIViewController {
    open var cancellables = Set<AnyCancellable>()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        bindViewModelInput()
        bindViewModelOutput()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func bindViewModelInput() { }
    
    open func bindViewModelOutput() { }
}
