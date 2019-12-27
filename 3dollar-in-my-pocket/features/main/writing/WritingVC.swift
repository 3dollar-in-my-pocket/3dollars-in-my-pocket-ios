import UIKit


class WritingVC: BaseVC {
    
    private lazy var writingView = WritingView(frame: self.view.frame)
    
    
    static func instance() -> WritingVC {
        return WritingVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = writingView
    }
    
    override func bindViewModel() {
        
    }
}
