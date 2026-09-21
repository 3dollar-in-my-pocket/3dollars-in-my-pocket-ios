import Foundation

/// 앱이 어떤 서버 환경으로 빌드됐는지 판별한다.
///
/// 디버깅 전용 기능은 프로덕션에 절대 노출되면 안 되므로, "프로덕션이 아님"을 추측하지 않고
/// "개발 환경임"을 적극적으로 확인했을 때만 허용한다(Info.plist 키가 없거나 값이 바뀌어도 기본값은 숨김).
public enum AppEnvironment {
    private static let devAPIHost = "dev.threedollars.co.kr"

    /// Tuist 빌드 설정에서 Info.plist 로 주입되는 API_URL.
    private static var apiURL: String {
        Bundle.main.infoDictionary?["API_URL"] as? String ?? ""
    }

    /// 개발(dev) 서버를 바라보고 있는지.
    public static var isDevServer: Bool {
        isDevServer(apiURL: apiURL)
    }

    /// 디버깅 전용 기능(설정의 디버그 메뉴, 가게 ID 플로팅 뷰 등)을 노출해도 되는 환경인지.
    ///
    /// Debug 빌드는 항상 허용한다. Release 빌드는 dev 서버를 볼 때만 허용하므로
    /// 프로덕션 앱(Release + 운영 API)에서는 어떤 경우에도 false 다.
    public static var isDebugToolAvailable: Bool {
        #if DEBUG
        let isDebugBuild = true
        #else
        let isDebugBuild = false
        #endif

        return isDebugToolAvailable(isDebugBuild: isDebugBuild, apiURL: apiURL)
    }

    /// 판정 규칙의 순수 함수 버전. 빌드 구성에 상관없이 진리표를 검증할 수 있도록 분리했다.
    public static func isDebugToolAvailable(isDebugBuild: Bool, apiURL: String) -> Bool {
        isDebugBuild || isDevServer(apiURL: apiURL)
    }

    public static func isDevServer(apiURL: String) -> Bool {
        apiURL.contains(devAPIHost)
    }
}
