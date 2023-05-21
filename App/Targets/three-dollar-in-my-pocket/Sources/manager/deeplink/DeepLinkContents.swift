import UIKit

struct DeepLinkContents {
    enum TransitionType {
        case present
        case push
    }
    
    let targetViewController: UIViewController?
    let transitionType: TransitionType?
    let selectedTab: TabBarTag?
    
    init(
        targetViewController: UIViewController? = nil,
        transitionType: TransitionType? = nil,
        selectedTab: TabBarTag? = nil
    ) {
        self.targetViewController = targetViewController
        self.transitionType = transitionType
        self.selectedTab = selectedTab
    }
}
