import UIKit

final class MyMedalViewController: BaseVC, MyMedalCoordinator {
    private let myMedalView = MyMedalView()
    private weak var coordinator: MyMedalCoordinator?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance() -> MyMedalViewController {
        return MyMedalViewController(nibName: nil, bundle: nil).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    override func loadView() {
        self.view = self.myMedalView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
    }
    
    override func bindEvent() {
        self.myMedalView.backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.popup()
            })
            .disposed(by: self.disposeBag)
    }
}
