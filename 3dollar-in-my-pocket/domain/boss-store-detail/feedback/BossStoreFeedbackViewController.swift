import UIKit

import Base
import RxSwift

final class BossStoreFeedbackViewController:
    Base.BaseViewController, BossStoreFeedbackCoordinator {
    private let bossStoreFeedbackView = BossStoreFeedbackView()
    private weak var coordinator: BossStoreFeedbackCoordinator?
    
    static func instacne(storeId: String) -> BossStoreFeedbackViewController {
        return BossStoreFeedbackViewController(storeId: storeId)
    }
    
    init(storeId: String) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.bossStoreFeedbackView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
    }
    
    override func bindEvent() {
        self.bossStoreFeedbackView.backButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.presenter.navigationController?
                    .popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
    }
}
