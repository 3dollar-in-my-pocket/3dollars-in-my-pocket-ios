import UIKit

import Common

public final class StoreDetailViewController: BaseViewController {
    private let storeDetailView = StoreDetailView()
    
    public static func instance() -> StoreDetailViewController {
        return StoreDetailViewController(nibName: nil, bundle: nil)
    }
    
    public override func loadView() {
        view = storeDetailView
    }
}
