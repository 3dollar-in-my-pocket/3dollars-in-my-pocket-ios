import UIKit

class BaseBottomSheetViewController: BaseViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        DimManager.shared.hideDim()
        dismiss(animated: true, completion: completion)
    }
}
