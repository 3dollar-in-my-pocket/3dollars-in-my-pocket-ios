import UIKit

final class MyVisitHistoryViewController: BaseVC, MyVisitHistoryCoordinator {
    private var coordinator: MyVisitHistoryCoordinator?
    private let myVisitHistoryView = MyVisitHistoryView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance() -> MyVisitHistoryViewController {
        return MyVisitHistoryViewController(nibName: nil, bundle: nil).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    override func loadView() {
        self.view = self.myVisitHistoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
    }
    
    override func bindEvent() {
        self.myVisitHistoryView.backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.popup()
            })
            .disposed(by: self.disposeBag)
    }
}
