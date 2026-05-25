import UIKit

import Model

struct StoreDetailModalContext<ViewModel> {
    let viewModel: ViewModel
    let trigger: StoreDisplayTrigger?
    let onDisplayed: () -> Void
}

protocol DismissibleStoreDetailModal: UIView {}
