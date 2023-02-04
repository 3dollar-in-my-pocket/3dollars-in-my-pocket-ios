import UIKit

import RxSwift

final class BookmarkSigninDialogViewController: BaseViewController, BookmarkSigninDialogCoordinator {
    private let bookmarkSigninDialogView = BookmarkSigninDialogView()
    private weak var coordinator: BookmarkSigninDialogCoordinator?
    
    static func instance() -> BookmarkSigninDialogViewController {
        return BookmarkSigninDialogViewController(nibName: nil, bundle: nil).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func loadView() {
        self.view = self.bookmarkSigninDialogView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = self.presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        self.coordinator = self
    }
    
    override func bindEvent() {
        self.bookmarkSigninDialogView.rx.tapBackground
            .asDriver()
            .throttle(.milliseconds(300))
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.bookmarkSigninDialogView.closeButton.rx.tap
            .asDriver()
            .throttle(.milliseconds(300))
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
    }
}
