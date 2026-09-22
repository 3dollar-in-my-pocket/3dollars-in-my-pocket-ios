import UIKit

import GoogleMobileAds

/// 광고 유닛별 요청/응답·실패 원인을 기기에서 바로 확인한다. 테스트 기기에서만 동작하며 시뮬레이터는 자동 등록된다.
struct AdInspectorDebugMenuItem: DebugMenuItem {
    let title = "AdMob Ad Inspector"

    func perform(from viewController: UIViewController) {
        MobileAds.shared.presentAdInspector(from: viewController) { error in
            guard let error else { return }
            let alert = UIAlertController(
                title: "Ad Inspector 실행 실패",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            viewController.present(alert, animated: true)
        }
    }
}
