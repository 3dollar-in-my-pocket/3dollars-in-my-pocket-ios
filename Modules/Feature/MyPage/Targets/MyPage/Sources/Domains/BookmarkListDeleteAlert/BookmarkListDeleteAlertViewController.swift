import UIKit

import Common
import DesignSystem

final class BookmarkListDeleteAlertViewController: BaseViewController {
    let didTapDelete: (() -> Void)
    private let bookmarkListDeleteAlertView = BookmarkListDeleteAlertView()
    
    init(didTapDelete: @escaping () -> Void) {
        self.didTapDelete = didTapDelete
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = bookmarkListDeleteAlertView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
    }
    
    override func bindEvent() {
        bookmarkListDeleteAlertView.cancelButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { (owner: BookmarkListDeleteAlertViewController, _) in
                owner.dismiss()
            }
            .store(in: &cancellables)
        
        bookmarkListDeleteAlertView.deleteButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { (owner: BookmarkListDeleteAlertViewController, _) in
                owner.dismiss()
                owner.didTapDelete()
            }
            .store(in: &cancellables)
    }
    
    private func dismiss() {
        DimManager.shared.hideDim()
        dismiss(animated: true)
    }
}
