import UIKit

import Common

import netfox

final class DebugOverlayWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        return hitView == rootViewController?.view ? nil : hitView
    }
}

enum DebugOverlay {
    private static var window: DebugOverlayWindow?

    static func attachIfNeeded(to windowScene: UIWindowScene) {
        guard AppEnvironment.isDebugToolAvailable, window == nil else { return }

        let overlayWindow = DebugOverlayWindow(windowScene: windowScene)
        overlayWindow.backgroundColor = .clear
        overlayWindow.windowLevel = .alert + 1
        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = .clear
        overlayWindow.rootViewController = rootViewController
        overlayWindow.isHidden = false

        let button = DebugFloatingButton()
        button.onTap = {
            presentMenu()
        }
        rootViewController.view.addSubview(button)
        DispatchQueue.main.async {
            button.applyInitialPosition(in: rootViewController.view)
        }

        window = overlayWindow
    }

    private static func presentMenu() {
        guard let presenter = topViewController() else { return }

        let menuViewController = DebugMenuViewController()
        menuViewController.onSelectNetworkLog = {
            NFX.sharedInstance().show()
        }

        if let sheet = menuViewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        presenter.present(menuViewController, animated: true)
    }

    private static func topViewController() -> UIViewController? {
        let candidates = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .filter { ($0 is DebugOverlayWindow).isNot && $0.isHidden.isNot && $0.rootViewController != nil }
        let hostWindow = candidates.first(where: \.isKeyWindow) ?? candidates.first

        var viewController = hostWindow?.rootViewController
        while let presented = viewController?.presentedViewController {
            viewController = presented
        }
        return viewController
    }
}
