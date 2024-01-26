import UIKit

import Common
import DesignSystem

final class BookmarkListViewController: BaseViewController {
    private let bookmarkView = BookmarkListView()
    
    override func loadView() {
        view = bookmarkView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bindEvent() {
        bookmarkView.backButton.controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { (owner: BookmarkListViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
}
