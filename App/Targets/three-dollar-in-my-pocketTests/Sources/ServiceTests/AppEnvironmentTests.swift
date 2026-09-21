import XCTest

import Common

/// 디버깅 전용 기능 노출 조건.
///
/// 핵심 안전 속성은 "프로덕션 앱(Release 빌드 + 운영 API)에서는 어떤 경우에도 노출되지 않는다" 이다.
/// 빌드 구성에 의존하지 않고 진리표를 검증하려고 판정부를 순수 함수로 분리해 두었다.
final class AppEnvironmentTests: XCTestCase {
    private let prodURL = "https://threedollars.co.kr"
    private let devURL = "https://dev.threedollars.co.kr"

    // MARK: TC11 — 프로덕션에서는 절대 노출되지 않는다

    func test_TC11_Release빌드_운영API면_디버그기능이꺼진다() {
        XCTAssertFalse(AppEnvironment.isDebugToolAvailable(isDebugBuild: false, apiURL: prodURL))
    }

    /// Info.plist 에서 API_URL 키가 사라지는 등 값이 비어도 기본값은 "숨김" 이어야 한다.
    func test_TC11_Release빌드_API_URL이비어도_디버그기능이꺼진다() {
        XCTAssertFalse(AppEnvironment.isDebugToolAvailable(isDebugBuild: false, apiURL: ""))
    }

    func test_TC11_Release빌드_알수없는호스트면_디버그기능이꺼진다() {
        XCTAssertFalse(AppEnvironment.isDebugToolAvailable(isDebugBuild: false, apiURL: "https://example.com"))
    }

    // MARK: TC12 — 개발 환경에서는 노출된다

    func test_TC12_Debug빌드면_디버그기능이켜진다() {
        XCTAssertTrue(AppEnvironment.isDebugToolAvailable(isDebugBuild: true, apiURL: prodURL))
        XCTAssertTrue(AppEnvironment.isDebugToolAvailable(isDebugBuild: true, apiURL: devURL))
    }

    /// Dev 앱이 Release 로 아카이빙돼도 dev 서버를 보면 QA 가 쓸 수 있어야 한다.
    func test_TC12_Release빌드라도_dev서버면_디버그기능이켜진다() {
        XCTAssertTrue(AppEnvironment.isDebugToolAvailable(isDebugBuild: false, apiURL: devURL))
    }

    // MARK: TC13 — dev 서버 판별

    func test_TC13_dev호스트만_dev서버로판정된다() {
        XCTAssertTrue(AppEnvironment.isDevServer(apiURL: devURL))
        XCTAssertFalse(AppEnvironment.isDevServer(apiURL: prodURL))
        XCTAssertFalse(AppEnvironment.isDevServer(apiURL: ""))
    }
}
