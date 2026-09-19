#if DEBUG
import UIKit
import AdSupport
import AppTrackingTransparency

/// AdMob 콘솔의 테스트 기기 목록(IDFA 기준)과 이 기기를 대조하기 위한 용도
struct AdvertisingIdentifierDebugMenuItem: DebugMenuItem {
    let title = "광고 ID(IDFA) 보기"

    func perform(from viewController: UIViewController) {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let alert = UIAlertController(
            title: "광고 ID (IDFA)",
            message: "추적 권한: \(trackingStatusDescription)\n\(idfa)\n\n"
                + "권한이 허용이 아니면 0으로만 표시되며, 그 경우 AdMob 테스트 기기와 매칭되지 않습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "복사", style: .default) { _ in
            UIPasteboard.general.string = idfa
        })
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel))
        viewController.present(alert, animated: true)
    }

    private var trackingStatusDescription: String {
        switch ATTrackingManager.trackingAuthorizationStatus {
        case .authorized: return "허용"
        case .denied: return "거부"
        case .restricted: return "제한"
        case .notDetermined: return "미결정"
        @unknown default: return "알 수 없음"
        }
    }
}
#endif
