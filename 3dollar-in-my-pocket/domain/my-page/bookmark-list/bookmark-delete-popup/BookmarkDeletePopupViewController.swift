import UIKit

import RxSwift

protocol BookmarkDeletePopupDelegate: AnyObject {
    func onTapDelete()
}

final class BookmarkDeletePopupViewController: BaseViewController, BookmarkDeletePopupCoordinator {
    weak var delegate: BookmarkDeletePopupDelegate?
    private let bookmarkDeletePopupView = BookmarkDeletePopupView()
    private weak var coordinator: BookmarkDeletePopupCoordinator?
    
    static func instance() -> BookmarkDeletePopupViewController {
        return BookmarkDeletePopupViewController(nibName: nil, bundle: nil).then {
            $0.modalPresentationStyle = .overCurrentContext
            $0.modalTransitionStyle = .crossDissolve
        }
    }
    
    override func loadView() {
        self.view = self.bookmarkDeletePopupView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = self.presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        self.coordinator = self
    }
    
    override func bindEvent() {
        self.bookmarkDeletePopupView.backgroundButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.bookmarkDeletePopupView.cancelButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.bookmarkDeletePopupView.deleteButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.delegate?.onTapDelete()
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
    }
}
