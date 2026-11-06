import Foundation

import Common

struct WebViewRequestBuilder {
    static let trustedDomains: Set<String> = [
        "threedollars.co.kr"
    ]

    static let trustedHosts: Set<String> = [
        "boong-village-dev.3dollarinmypocket.workers.dev",
        "boong-village.3dollarinmypocket.workers.dev"
    ]

    private let authToken: String
    private let userAgent: String

    init(
        authToken: String = Preference.shared.authToken,
        userAgent: String = HTTPUtils.userAgent
    ) {
        self.authToken = authToken
        self.userAgent = userAgent
    }

    func build(request: URLRequest) -> URLRequest {
        var request = request

        guard let url = request.url, Self.isTrusted(url: url), authToken.isNotEmpty else { return request }

        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        return request
    }

    func customUserAgent(for url: URL?) -> String? {
        guard let url, Self.isTrusted(url: url) else { return nil }
        return userAgent
    }

    static func isTrusted(url: URL) -> Bool {
        guard url.scheme?.lowercased() == "https",
              let host = url.host?.lowercased() else { return false }

        if trustedHosts.contains(host) { return true }
        return trustedDomains.contains { domain in
            host == domain || host.hasSuffix(".\(domain)")
        }
    }
}
