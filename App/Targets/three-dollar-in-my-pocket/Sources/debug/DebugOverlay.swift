import UIKit

import Common

import netfox

/// 디버깅 플로팅 버튼을 담는 전용 윈도우.
///
/// 메인 윈도우 위에 별도 윈도우로 띄워야 rootViewController 교체(스플래시 → 로그인 → 메인)나
/// 전체화면 모달에 가려지지 않는다. 버튼 밖의 터치는 그대로 아래 윈도우로 흘려보낸다.
final class DebugOverlayWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        // rootViewController 의 빈 배경에 맞은 터치는 통과시킨다.
        return hitView == rootViewController?.view ? nil : hitView
    }
}

/// 개발 환경에서만 디버깅 오버레이를 띄우고 메뉴를 연결하는 진입점.
enum DebugOverlay {
    private static var window: DebugOverlayWindow?

    /// 프로덕션 빌드에서는 아무것도 하지 않는다.
    static func attachIfNeeded(to windowScene: UIWindowScene) {
        guard AppEnvironment.isDebugToolAvailable, window == nil else { return }

        let overlayWindow = DebugOverlayWindow(windowScene: windowScene)
        overlayWindow.backgroundColor = .clear
        // 알럿 위에서도 잡을 수 있도록 가장 위로 올린다.
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
        // 세이프 에어리어가 확정된 다음에 위치를 잡아야 화면 밖으로 나가지 않는다.
        DispatchQueue.main.async {
            button.applyInitialPosition(in: rootViewController.view)
        }

        window = overlayWindow
    }

    /// 오버레이 윈도우는 터치를 흘려보내는 용도라 모달을 띄우면 시트가 입력을 못 받는다.
    /// 그래서 시트는 앱 메인 윈도우의 최상단 화면에서 띄운다.
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
        // 오버레이 윈도우가 key 가 되는 경우가 있어 isKeyWindow 만 믿지 않고 폴백을 둔다.
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
