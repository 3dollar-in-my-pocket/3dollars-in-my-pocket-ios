import UIKit

struct DeepLinkContents {
    enum TransitionType {
        case present
        case push
    }
    
    let targetViewController: UIViewController
    let transitionType: TransitionType
}
