import XCTest

@testable import dollar_in_my_pocket

final class DeepLinkReservationTests: XCTestCase {
    private var appLink: String { "\(Bundle.deeplinkScheme)://medal" }

    // MARK: TH-1047 TC2

    func test_TH1047_TC2_로그인전에저장한링크는_카카오로그인콜백URL이들어와도_바뀌지않는다() {
        // Given
        let handler = DeepLinkHandler(canHandleDeepLinkOverride: { false })
        handler.handleExternal(appLink)

        // When
        handler.handleExternal("kakao0123456789abcdef://oauth?code=test")

        // Then
        XCTAssertEqual(handler.reservedDeepLinkURLString, appLink)
    }

    // MARK: TH-1047 TC3

    func test_TH1047_TC3_로그인전에저장한링크는_앱이처리할수없는URL이들어와도_바뀌지않는다() {
        // Given
        let handler = DeepLinkHandler(canHandleDeepLinkOverride: { false })
        handler.handleExternal(appLink)

        // When
        handler.handleExternal("naverlogin://thirdPartyLoginResult?code=0")

        // Then
        XCTAssertEqual(handler.reservedDeepLinkURLString, appLink)
    }

    func test_TH1047_TC3_로그인전에앱링크가다시들어오면_가장최근링크로저장한다() {
        // Given
        let handler = DeepLinkHandler(canHandleDeepLinkOverride: { false })
        handler.handleExternal(appLink)
        let latestLink = "\(Bundle.deeplinkScheme)://bookmark"

        // When
        handler.handleExternal(latestLink)

        // Then
        XCTAssertEqual(handler.reservedDeepLinkURLString, latestLink)
    }
}
