import UIKit

struct GALogViewerDebugMenuItem: DebugMenuItem {
    let title = "GA 로그 뷰어"

    func perform(from viewController: UIViewController) {
        GALogViewerDebugMenuItem.present(from: viewController, focusGroupId: nil)
    }

    static func present(from viewController: UIViewController, focusGroupId: UUID?) {
        let navigationController = UINavigationController(rootViewController: GALogViewerViewController(focusGroupId: focusGroupId))
        navigationController.modalPresentationStyle = .fullScreen
        viewController.present(navigationController, animated: true)
    }
}
