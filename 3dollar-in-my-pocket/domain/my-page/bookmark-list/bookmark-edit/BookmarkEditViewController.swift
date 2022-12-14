import UIKit

import ReactorKit
import RxSwift

final class BookmarkEditViewController: BaseViewController, View, BookmarkEditCoordinator {
    private let bookmarkEditView = BookmarkEditView()
    private let bookmarkEditReactor: BookmarkEditReactor
    private weak var coordinator: BookmarkEditCoordinator?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance(bookmarkFolder: BookmarkFolder) -> BookmarkEditViewController {
        return BookmarkEditViewController(bookmarkFolder: bookmarkFolder)
    }
    
    init(bookmarkFolder: BookmarkFolder) {
        self.bookmarkEditReactor = BookmarkEditReactor(
            bookmarkFolder: bookmarkFolder,
            bookmarkService: BookmarkService(),
            globalState: GlobalState.shared
        )
        super.init(nibName: nil, bundle: nil)
        self.bookmarkEditView.bind(bookmakrFolder: bookmarkFolder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.bookmarkEditView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.reactor = self.bookmarkEditReactor
    }
    
    override func bindEvent() {
        self.bookmarkEditView.backButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.presenter.navigationController?
                    .popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: BookmarkEditReactor) {
        // Bind Action
        self.bookmarkEditView.titleTextView.rx.text.orEmpty
            .map { Reactor.Action.didEndEditTitle($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.bookmarkEditView.descriptionTextView.rx.text.orEmpty
            .map { Reactor.Action.didEndEditDescription($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.bookmarkEditView.saveButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapSave }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.pulse(\.$pop)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.presenter.navigationController?
                    .popViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$showLading)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$showErrorAlert)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.disposeBag)
    }
}
