import UIKit

import Model

import FirebaseCrashlytics
import SwiftyBeaver

enum AdMobErrorReporter {
    private static let errorDomain = "AdMobLoadError"

    /// 광고 로드 실패를 Crashlytics non-fatal로 남긴다.
    /// 화면·유닛 ID·에러 내용을 한 메시지에 담아, 계정/앱 ID 설정 오류(code 1)와 단순 광고 부족(code 3)을 콘솔에서 바로 구분할 수 있게 한다.
    static func report(
        adType: AdType,
        unitId: String,
        from viewController: UIViewController?,
        error: Error
    ) {
        let screenName = viewController.map { String(describing: type(of: $0)) } ?? "unknown"
        let nsError = error as NSError
        let message = "screen=\(screenName) unitId=\(unitId) "
            + "error=\(nsError.domain)(\(nsError.code)) \(nsError.localizedDescription)"

        Log.error("AdMob load failed [\(adType)] \(message)")

        // Crashlytics는 domain+code로 이슈를 묶으므로 AdMob 에러 코드를 그대로 code에 실어 실패 유형별로 분리한다
        let reportedError = NSError(
            domain: errorDomain,
            code: nsError.code,
            userInfo: [
                NSLocalizedDescriptionKey: message,
                "screen": screenName,
                "ad_type": String(describing: adType),
                "ad_unit_id": unitId,
                NSUnderlyingErrorKey: nsError
            ]
        )
        Crashlytics.crashlytics().record(error: reportedError)
    }
}
