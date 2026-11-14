import XCTest

@testable import dollar_in_my_pocket

final class WebViewRequestBuilderTests: XCTestCase {
    private let token = "test-token"
    private let userAgent = "4.52.0 (com.macgongmon.-dollar-in-my-pocket-debug; build:1; iOS 27.0.0)"
    private let debugGameURL = "https://boong-village-dev.3dollarinmypocket.workers.dev/"
    private let releaseGameURL = "https://boong-village.3dollarinmypocket.workers.dev/"
    private let webDevURL = "https://3dollars-web-dev.netlify.app/events/my-siblings-romance-2"

    private func makeBuilder(token: String? = nil, isDebugBuild: Bool = true) -> WebViewRequestBuilder {
        return WebViewRequestBuilder(authToken: token ?? self.token, userAgent: userAgent, isDebugBuild: isDebugBuild)
    }

    private func makeRequest(_ urlString: String, token: String? = nil, isDebugBuild: Bool = true) throws -> URLRequest {
        let url = try XCTUnwrap(URL(string: urlString))
        return makeBuilder(token: token, isDebugBuild: isDebugBuild).build(request: URLRequest(url: url))
    }

    private func customUserAgent(_ urlString: String, isDebugBuild: Bool = true) -> String? {
        return makeBuilder(isDebugBuild: isDebugBuild).customUserAgent(for: URL(string: urlString))
    }

    // MARK: TH-1580 TC1 — 허용 도메인은 첫 요청에 Authorization·User-Agent 가 실린다

    func test_TH1580_TC1_Debug빌드는_dev게임도메인에만_토큰과_앱UA가_실린다() throws {
        // Given / When
        let devRequest = try makeRequest(debugGameURL, isDebugBuild: true)
        let prodRequest = try makeRequest(releaseGameURL, isDebugBuild: true)

        // Then
        XCTAssertEqual(devRequest.value(forHTTPHeaderField: "Authorization"), token)
        XCTAssertEqual(customUserAgent(debugGameURL, isDebugBuild: true), userAgent)
        XCTAssertNil(prodRequest.value(forHTTPHeaderField: "Authorization"))
        XCTAssertNil(customUserAgent(releaseGameURL, isDebugBuild: true))
    }

    func test_TH1580_TC1_Release빌드는_prod게임도메인에만_토큰과_앱UA가_실린다() throws {
        // Given / When
        let prodRequest = try makeRequest(releaseGameURL, isDebugBuild: false)
        let devRequest = try makeRequest(debugGameURL, isDebugBuild: false)

        // Then
        XCTAssertEqual(prodRequest.value(forHTTPHeaderField: "Authorization"), token)
        XCTAssertEqual(customUserAgent(releaseGameURL, isDebugBuild: false), userAgent)
        XCTAssertNil(devRequest.value(forHTTPHeaderField: "Authorization"))
        XCTAssertNil(customUserAgent(debugGameURL, isDebugBuild: false))
    }

    func test_TH1580_TC1_가슴속3천원_도메인과_서브도메인이면_빌드와_무관하게_토큰이_실린다() throws {
        let urls = [
            "https://threedollars.co.kr/event",
            "https://dev.threedollars.co.kr/event",
            "https://app.threedollars.co.kr/store?storeId=1"
        ]

        for isDebugBuild in [true, false] {
            for url in urls {
                // Given / When
                let request = try makeRequest(url, isDebugBuild: isDebugBuild)

                // Then
                XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), token, url)
                XCTAssertEqual(customUserAgent(url, isDebugBuild: isDebugBuild), userAgent, url)
            }
        }
    }

    // MARK: TH-1580 TC2 — 허용하지 않은 도메인에는 Authorization 이 실리지 않는다

    func test_TH1580_TC2_외부도메인이면_헤더를_붙이지_않는다() throws {
        let urls = [
            "https://massive-iguana-121.notion.site/policy",
            "https://www.google.com",
            "https://evil-threedollars.co.kr",
            "https://threedollars.co.kr.evil.com",
            "https://other.3dollarinmypocket.workers.dev",
            "http://threedollars.co.kr/event",
            "http://boong-village-dev.3dollarinmypocket.workers.dev/"
        ]

        for url in urls {
            // Given / When
            let request = try makeRequest(url)

            // Then
            XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"), url)
            XCTAssertNil(customUserAgent(url), url)
        }
    }

    func test_TH1580_TC2_외부도메인_요청에_실려온_Authorization은_제거한다() throws {
        // Given
        var request = URLRequest(url: try XCTUnwrap(URL(string: "https://www.google.com")))
        request.setValue(token, forHTTPHeaderField: "Authorization")

        // When
        let built = makeBuilder().build(request: request)

        // Then
        XCTAssertNil(built.value(forHTTPHeaderField: "Authorization"))
    }

    func test_TH1580_TC2_허용페이지에서_외부도메인으로_이동하면_다시_로드해_앱UA를_뗀다() throws {
        // Given
        let builder = makeBuilder()
        let request = URLRequest(url: try XCTUnwrap(URL(string: "https://www.google.com/ad")))

        // When
        let needsReload = builder.needsReload(request: request, currentUserAgent: userAgent)

        // Then
        XCTAssertTrue(needsReload)
        XCTAssertNil(builder.customUserAgent(for: request.url))
    }

    func test_TH1580_TC2_외부도메인으로_리다이렉트되며_Authorization이_실려오면_다시_로드한다() throws {
        // Given
        let builder = makeBuilder()
        var request = URLRequest(url: try XCTUnwrap(URL(string: "https://www.google.com")))
        request.setValue(token, forHTTPHeaderField: "Authorization")

        // When
        let needsReload = builder.needsReload(request: request, currentUserAgent: nil)

        // Then
        XCTAssertTrue(needsReload)
    }

    func test_TH1580_TC2_외부페이지에서_허용도메인으로_이동하면_다시_로드해_앱UA를_붙인다() throws {
        // Given
        let builder = makeBuilder()
        let request = URLRequest(url: try XCTUnwrap(URL(string: "https://threedollars.co.kr/event")))

        // When
        let needsReload = builder.needsReload(request: request, currentUserAgent: nil)

        // Then
        XCTAssertTrue(needsReload)
        XCTAssertEqual(builder.build(request: request).value(forHTTPHeaderField: "Authorization"), token)
    }

    func test_TH1580_TC2_같은_허용범위_안의_이동은_다시_로드하지_않는다() throws {
        // Given
        let builder = makeBuilder()
        let trustedRequest = URLRequest(url: try XCTUnwrap(URL(string: "https://threedollars.co.kr/event")))
        let externalRequest = URLRequest(url: try XCTUnwrap(URL(string: "https://www.google.com")))

        // When / Then
        XCTAssertFalse(builder.needsReload(request: trustedRequest, currentUserAgent: userAgent))
        XCTAssertFalse(builder.needsReload(request: externalRequest, currentUserAgent: nil))
        XCTAssertFalse(builder.needsReload(request: externalRequest, currentUserAgent: ""))
    }

    // MARK: TH-1580 TC3 — 비로그인이면 Authorization 없이 로드한다

    func test_TH1580_TC3_토큰이_비어있으면_Authorization없이_UA만_실린다() throws {
        // Given / When
        let request = try makeRequest(debugGameURL, token: "")

        // Then
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
        XCTAssertEqual(customUserAgent(debugGameURL), userAgent)
    }

    // MARK: TH-1599 — 디버그 빌드는 웹 개발 환경에도 토큰·앱 UA 를 싣는다

    func test_TH1599_TC1_Debug빌드는_웹개발환경에_토큰과_앱UA가_실린다() throws {
        // Given / When
        let request = try makeRequest(webDevURL, isDebugBuild: true)

        // Then
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), token)
        XCTAssertEqual(customUserAgent(webDevURL, isDebugBuild: true), userAgent)
    }

    func test_TH1599_TC2_Release빌드는_웹개발환경에_토큰과_앱UA가_실리지_않는다() throws {
        // Given / When
        let request = try makeRequest(webDevURL, isDebugBuild: false)

        // Then
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
        XCTAssertNil(customUserAgent(webDevURL, isDebugBuild: false))
    }

    func test_TH1599_TC3_Debug빌드라도_다른_netlify주소에는_토큰이_실리지_않는다() throws {
        let urls = [
            "https://evil.netlify.app/events/my-siblings-romance-2",
            "https://3dollars-web.netlify.app/events/my-siblings-romance-2",
            "https://3dollars-web-dev.netlify.app.evil.com/events/my-siblings-romance-2"
        ]

        for url in urls {
            // Given / When
            let request = try makeRequest(url, isDebugBuild: true)

            // Then
            XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"), url)
            XCTAssertNil(customUserAgent(url, isDebugBuild: true), url)
        }
    }

    func test_TH1599_TC4_Debug빌드라도_웹개발환경을_http로_열면_토큰이_실리지_않는다() throws {
        // Given
        let url = "http://3dollars-web-dev.netlify.app/events/my-siblings-romance-2"

        // When
        let request = try makeRequest(url, isDebugBuild: true)

        // Then
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
        XCTAssertNil(customUserAgent(url, isDebugBuild: true))
    }
}
