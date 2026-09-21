#if DEBUG
import UIKit

import Common

/// 디버그 메뉴의 항목 하나. 항목은 자신의 동작만 알고, 메뉴가 어떻게 구성·표시되는지는 모른다.
protocol DebugMenuItem {
    var title: String { get }
    func perform(from viewController: UIViewController)
}

/// 항목 목록을 액션시트로 띄우는 역할만 담당한다. 항목 추가 시 이 타입은 수정하지 않는다.
struct DebugMenuPresenter {
    private let items: [DebugMenuItem]

    init(items: [DebugMenuItem]) {
        self.items = items
    }

    func present(in window: UIWindow) {
        guard let rootViewController = window.rootViewController else { return }
        let topViewController = UIUtils.getTopViewController(rootViewController)
        let alert = UIAlertController(title: "Debug Menu", message: nil, preferredStyle: .actionSheet)

        for item in items {
            alert.addAction(UIAlertAction(title: item.title, style: .default) { _ in
                item.perform(from: topViewController)
            })
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))

        topViewController.present(alert, animated: true)
    }
}
#endif
