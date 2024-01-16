import UIKit

public struct DeepLinkContents {
    public enum TransitionType {
        case present
        case push
    }
    
    public let targetViewController: UIViewController?
    public let transitionType: TransitionType?
    public let selectedTab: TabBarTag?
    
    public init(
        targetViewController: UIViewController? = nil,
        transitionType: TransitionType? = nil,
        selectedTab: TabBarTag? = nil
    ) {
        self.targetViewController = targetViewController
        self.transitionType = transitionType
        self.selectedTab = selectedTab
    }
}
