import XCTest

import Common

final class AppEnvironmentTests: XCTestCase {
    private let prodURL = "https://threedollars.co.kr"
    private let devURL = "https://dev.threedollars.co.kr"

    // MARK: TC1 — 프로덕션에서는 절대 노출되지 않는다

    func test_TC1_Release빌드_운영API면_디버그기능이꺼진다() {
        XCTAssertFalse(AppEnvironment.isDebugToolAvailable(isDebugBuild: false, apiURL: prodURL))
    }

    func test_TC1_Release빌드_API_URL이비어도_디버그기능이꺼진다() {
        XCTAssertFalse(AppEnvironment.isDebugToolAvailable(isDebugBuild: false, apiURL: ""))
    }

    func test_TC1_Release빌드_알수없는호스트면_디버그기능이꺼진다() {
        XCTAssertFalse(AppEnvironment.isDebugToolAvailable(isDebugBuild: false, apiURL: "https://example.com"))
    }

    // MARK: TC2 — 개발 환경에서는 노출된다

    func test_TC2_Debug빌드면_디버그기능이켜진다() {
        XCTAssertTrue(AppEnvironment.isDebugToolAvailable(isDebugBuild: true, apiURL: prodURL))
        XCTAssertTrue(AppEnvironment.isDebugToolAvailable(isDebugBuild: true, apiURL: devURL))
    }

    func test_TC2_Release빌드라도_dev서버면_디버그기능이켜진다() {
        XCTAssertTrue(AppEnvironment.isDebugToolAvailable(isDebugBuild: false, apiURL: devURL))
    }

    // MARK: TC3 — dev 서버 판별

    func test_TC3_dev호스트만_dev서버로판정된다() {
        XCTAssertTrue(AppEnvironment.isDevServer(apiURL: devURL))
        XCTAssertFalse(AppEnvironment.isDevServer(apiURL: prodURL))
        XCTAssertFalse(AppEnvironment.isDevServer(apiURL: ""))
    }
}
