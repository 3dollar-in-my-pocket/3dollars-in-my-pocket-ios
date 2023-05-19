import UIKit

import RxSwift

class BaseViewController: UIViewController {
    var disposeBag = DisposeBag()
    var eventDisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindEvent()
    }
    
    /// Reactor를 거치지 않고 바로 바인딩 되는 단순 이벤트를 정의합니다.
    func bindEvent() { }
}
