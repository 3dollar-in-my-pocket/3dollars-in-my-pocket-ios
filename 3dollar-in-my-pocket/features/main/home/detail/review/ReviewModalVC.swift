import UIKit

protocol ReviewModalDelegate: class {
    func onTapRegister()
}

class ReviewModalVC: BaseVC {
    
    weak var deleaget: ReviewModalDelegate?
    
    private lazy var reviewModalView = ReviewModalView(frame: self.view.frame).then {
        $0.delegate = self
    }
    
    static func instance() -> ReviewModalVC {
        return ReviewModalVC(nibName: nil, bundle: nil).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func viewDidLoad() {
        view = reviewModalView
    }
    
    override func bindViewModel() {

    }
}

extension ReviewModalVC: ReviewModalViewDelegate {
    func onTapRegister() {
        self.deleaget?.onTapRegister()
    }
}
