import UIKit

import RxSwift

final class BookmarkListViewController:
    BaseViewController, BookmarkListCoordinator {
    private let bookmarkListView = BookmarkListView()
    private weak var coordinator: BookmarkListCoordinator?
    
    static func instance() -> BookmarkListViewController {
        return BookmarkListViewController(nibName: nil, bundle: nil).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    override func loadView() {
        self.view = self.bookmarkListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
    }
    
    override func bindEvent() {
        self.bookmarkListView.backButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.presenter.navigationController?
                    .popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
    }
}
