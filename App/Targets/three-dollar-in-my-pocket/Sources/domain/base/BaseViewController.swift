import UIKit
import Combine

import RxSwift

class BaseViewController: UIViewController {
    var disposeBag = DisposeBag()
    var eventDisposeBag = DisposeBag()
    var cancellables = Set<AnyCancellable>()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        bindViewModelInput()
        bindViewModelOutput()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindEvent()
    }
    
    /// Reactor를 거치지 않고 바로 바인딩 되는 단순 이벤트를 정의합니다.
    func bindEvent() { }
    
    func bindViewModelInput() { }
    
    func bindViewModelOutput() { }
}
