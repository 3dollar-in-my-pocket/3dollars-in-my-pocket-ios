import UIKit

class HomeVC: BaseVC {
    
    private lazy var homeView = HomeView(frame: self.view.frame)
    
    
    static func instance() -> HomeVC {
        return HomeVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = homeView
    }
    
    override func bindViewModel() {
        
    }
}
