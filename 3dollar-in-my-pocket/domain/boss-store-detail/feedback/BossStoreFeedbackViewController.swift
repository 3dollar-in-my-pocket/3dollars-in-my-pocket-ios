import UIKit

import Base
import ReactorKit

final class BossStoreFeedbackViewController:
    Base.BaseViewController, View, BossStoreFeedbackCoordinator {
    private let bossStoreFeedbackView = BossStoreFeedbackView()
    private let bossStoreFeedbackReactor: BossStoreFeedbackReactor
    private weak var coordinator: BossStoreFeedbackCoordinator?
    
    static func instacne(storeId: String) -> BossStoreFeedbackViewController {
        return BossStoreFeedbackViewController(storeId: storeId)
    }
    
    init(storeId: String) {
        self.bossStoreFeedbackReactor = BossStoreFeedbackReactor(
            bossStoreId: storeId,
            feedbackService: FeedbackService(),
            globalState: GlobalState.shared,
            metaContext: MetaContext.shared
        )
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
        
        self.reactor = self.bossStoreFeedbackReactor
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
        
        self.bossStoreFeedbackReactor.popPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.presenter.navigationController?
                    .popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.bossStoreFeedbackReactor.showLoadingPublisher
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.bossStoreFeedbackReactor.showErrorAlertPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self]  error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: BossStoreFeedbackReactor) {
        // Bind Action
        self.bossStoreFeedbackView.feedbackTableView.rx.itemSelected
            .map { Reactor.Action.selectFeedback(index: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.bossStoreFeedbackView.feedbackTableView.rx.itemDeselected
            .map { Reactor.Action.deselectFeedback(index: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.bossStoreFeedbackView.sendFeedbackButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapSendFeedback }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.feedbackTypes }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.bossStoreFeedbackView.feedbackTableView.rx.items(
                cellIdentifier: BossStoreFeedbackTableViewCell.registerId,
                cellType: BossStoreFeedbackTableViewCell.self
            )) { _, feedbackType, cell in
                cell.bind(feedbackType: feedbackType)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isEnableSendFeedbackButton }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(self.bossStoreFeedbackView.rx.isEnableSendFeedbackButton)
            .disposed(by: self.disposeBag)
    }
}
