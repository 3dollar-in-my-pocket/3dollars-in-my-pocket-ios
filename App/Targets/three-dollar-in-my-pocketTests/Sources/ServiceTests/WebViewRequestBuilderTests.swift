import XCTest

@testable import dollar_in_my_pocket

final class WebViewRequestBuilderTests: XCTestCase {
    private let token = "test-token"
    private let userAgent = "4.52.0 (com.macgongmon.-dollar-in-my-pocket-debug; build:1; iOS 27.0.0)"

    private func makeBuilder(token: String? = nil) -> WebViewRequestBuilder {
        return WebViewRequestBuilder(authToken: token ?? self.token, userAgent: userAgent)
    }

    private func makeRequest(_ urlString: String, token: String? = nil) throws -> URLRequest {
        let url = try XCTUnwrap(URL(string: urlString))
        return makeBuilder(token: token).build(request: URLRequest(url: url))
    }

    private func customUserAgent(_ urlString: String) -> String? {
        return makeBuilder().customUserAgent(for: URL(string: urlString))
    }

    // MARK: TH-1580 TC1 — 허용 도메인은 첫 요청에 Authorization·User-Agent 가 실린다

    func test_TH1580_TC1_게임도메인이면_토큰과_앱UA가_실린다() throws {
        let hosts = [
            "https://boong-village-dev.3dollarinmypocket.workers.dev/",
            "https://boong-village.3dollarinmypocket.workers.dev/"
        ]

        for host in hosts {
            // Given / When
            let request = try makeRequest(host)

            // Then
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), token, host)
            XCTAssertEqual(customUserAgent(host), userAgent, host)
        }
    }

    func test_TH1580_TC1_가슴속3천원_도메인과_서브도메인이면_토큰이_실린다() throws {
        let urls = [
            "https://threedollars.co.kr/event",
            "https://dev.threedollars.co.kr/event",
            "https://app.threedollars.co.kr/store?storeId=1"
        ]

        for url in urls {
            // Given / When
            let request = try makeRequest(url)

            // Then
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), token, url)
            XCTAssertEqual(customUserAgent(url), userAgent, url)
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
            "http://threedollars.co.kr/event"
        ]

        for url in urls {
            // Given / When
            let request = try makeRequest(url)

            // Then
            XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"), url)
            XCTAssertNil(customUserAgent(url), url)
        }
    }

    // MARK: TH-1580 TC3 — 비로그인이면 Authorization 없이 로드한다

    func test_TH1580_TC3_토큰이_비어있으면_Authorization없이_UA만_실린다() throws {
        // Given / When
        let url = "https://boong-village.3dollarinmypocket.workers.dev/"
        let request = try makeRequest(url, token: "")

        // Then
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
        XCTAssertEqual(customUserAgent(url), userAgent)
    }
}
