import UIKit

import RxSwift
import ReactorKit

protocol DeleteModalDelegate: AnyObject {
    func onRequest()
}

final class DeleteModalViewController: BaseViewController, View, DeleteModalCoordinator {
    weak var deleagete: DeleteModalDelegate?
    private weak var coordinator: DeleteModalCoordinator?
    private let deleteModalView = DeleteModalView()
    private let deleteModalReactor: DeleteModalReactor
    
    init(storeId: Int) {
        self.deleteModalReactor = DeleteModalReactor(storeId: storeId, storeService: StoreService())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func instance(storeId: Int) -> DeleteModalViewController {
        return DeleteModalViewController(storeId: storeId).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func loadView() {
        self.view = self.deleteModalView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = self.presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        self.reactor = self.deleteModalReactor
        self.coordinator = self
    }
    
    override func bindEvent() {
        self.deleteModalView.closeButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.deleteModalView.tapBackground.rx.event
            .map { _ in () }
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.deleteModalReactor.dismissPublisher
            .asDriver(onErrorJustReturn: ())
            .drive { [weak self] _ in
                self?.coordinator?.dismissOnRequest()
            }
            .disposed(by: self.eventDisposeBag)
        
        self.deleteModalReactor.showLoadingPublisher
            .asDriver(onErrorJustReturn: false)
            .drive { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            }
            .disposed(by: self.eventDisposeBag)
        
        self.deleteModalReactor.showErrorAlertPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            }
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: DeleteModalReactor) {
        // Bind Action
        self.deleteModalView.deleteMenuStackView.notExistedButton.rx.tap
            .map { Reactor.Action.tapReason(.NOSTORE) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.deleteModalView.deleteMenuStackView.wrongContentButton.rx.tap
            .map { Reactor.Action.tapReason(DeleteReason.WRONGCONTENT) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.deleteModalView.deleteMenuStackView.overlapButton.rx.tap
            .map { Reactor.Action.tapReason(DeleteReason.OVERLAPSTORE) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.deleteModalView.deleteButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapDelete }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.deleteReason != nil }
            .asDriver(onErrorJustReturn: false)
            .drive(self.deleteModalView.deleteButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .compactMap { $0.deleteReason }
            .asDriver(onErrorJustReturn: .NOSTORE)
            .drive(self.deleteModalView.deleteMenuStackView.rx.selectReason)
            .disposed(by: self.disposeBag)
    }
}
