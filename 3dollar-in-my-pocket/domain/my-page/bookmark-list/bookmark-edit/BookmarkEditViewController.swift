import UIKit

import RxSwift

final class BookmarkEditViewController: BaseViewController, BookmarkEditCoordinator {
    private let bookmarkEditView = BookmarkEditView()
    private weak var coordinator: BookmarkEditCoordinator?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance(bookamrkFolder: BookmarkFolder) -> BookmarkEditViewController {
        return BookmarkEditViewController(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = self.bookmarkEditView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
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
}
