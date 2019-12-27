import UIKit

class MyPageVC: BaseVC {
    
    private lazy var myPageView = MyPageView(frame: self.view.frame)
    
    
    static func instance() -> MyPageVC {
        return MyPageVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = myPageView
    }
    
    override func bindViewModel() {
        
    }
}
