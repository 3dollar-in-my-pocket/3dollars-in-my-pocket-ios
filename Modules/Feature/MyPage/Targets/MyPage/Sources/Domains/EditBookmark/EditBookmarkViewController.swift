import Foundation

import Common

final class EditBookmarkViewController: BaseViewController {
    private let editBookmarkView = EditBookmarkView()
    
    override func loadView() {
        self.view = editBookmarkView
    }
    
    override func bindEvent() {
        editBookmarkView.backButton.controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { (owner: EditBookmarkViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
}
