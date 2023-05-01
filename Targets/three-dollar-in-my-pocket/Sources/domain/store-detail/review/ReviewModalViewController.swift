import UIKit

import RxSwift
import ReactorKit

final class ReviewModalViewController: BaseViewController, View, ReviewModalCoordinator {
    private let reviewModalView = ReviewModalView()
    private let reviewModalReactor: ReviewModalReactor
    private weak var coordinator: ReviewModalCoordinator?
  
    init(storeId: Int, review: Review?) {
        self.reviewModalReactor = ReviewModalReactor(
            storeId: storeId,
            review: review,
            reviewService: ReviewService(),
            globalState: GlobalState.shared
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func instance(storeId: Int, review: Review? = nil) -> ReviewModalViewController {
        return ReviewModalViewController(storeId: storeId, review: review).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func loadView() {
        self.view = self.reviewModalView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = self.reviewModalReactor
        self.coordinator = self
        if let parentView = self.presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
    }
    
    override func bindEvent() {
        self.reviewModalView.closeButton.rx.tap
            .asDriver()
            .throttle(.milliseconds(300))
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.reviewModalView.rx.tapBackground
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.reviewModalReactor.showLoadingPublisher
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.reviewModalReactor.showErrorAlertPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: ReviewModalReactor) {
        // Bind Action
        self.reviewModalView.ratingInputView.rx.rating
            .map { Reactor.Action.onTapRating(rating: $0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.reviewModalView.reviewTextView.rx.text.orEmpty
            .map { Reactor.Action.inputReview($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.reviewModalView.registerButton.rx.tap
          .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
          .map { Reactor.Action.tapRegisterButton }
          .bind(to: reactor.action)
          .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.pulse(\.$dismiss)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.review }
            .asDriver(onErrorJustReturn: Review())
            .distinctUntilChanged()
            .drive(self.reviewModalView.rx.review)
            .disposed(by: self.disposeBag)
    }
}
