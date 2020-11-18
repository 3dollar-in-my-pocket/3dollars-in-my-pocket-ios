import UIKit
import RxSwift
import RxCocoa

class BaseVC: UIViewController {
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    func bindViewModel() { }
}
