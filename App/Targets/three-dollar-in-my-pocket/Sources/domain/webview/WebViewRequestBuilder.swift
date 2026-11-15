import Foundation

import Common

struct WebViewRequestBuilder {
    static let trustedDomains: Set<String> = [
        "threedollars.co.kr"
    ]

    static let trustedDebugHosts: Set<String> = [
        "boong-village-dev.3dollarinmypocket.workers.dev",
        "3dollars-web-dev.netlify.app"
    ]

    static let trustedReleaseHosts: Set<String> = [
        "boong-village.3dollarinmypocket.workers.dev"
    ]

    static var isDebugBuild: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    private let authToken: String
    private let userAgent: String
    private let isDebugBuild: Bool

    init(
        authToken: String = Preference.shared.authToken,
        userAgent: String = HTTPUtils.userAgent,
        isDebugBuild: Bool = Self.isDebugBuild
    ) {
        self.authToken = authToken
        self.userAgent = userAgent
        self.isDebugBuild = isDebugBuild
    }

    func build(request: URLRequest) -> URLRequest {
        var request = request
        request.setValue(nil, forHTTPHeaderField: "Authorization")

        guard let url = request.url, isTrusted(url: url), authToken.isNotEmpty else { return request }

        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        return request
    }

    func customUserAgent(for url: URL?) -> String? {
        guard let url, isTrusted(url: url) else { return nil }
        return userAgent
    }

    func needsReload(request: URLRequest, currentUserAgent: String?) -> Bool {
        let hasAuthorization = request.value(forHTTPHeaderField: "Authorization") != nil
        if hasAuthorization, let url = request.url, !isTrusted(url: url) { return true }

        let currentUserAgent = currentUserAgent?.isEmpty == false ? currentUserAgent : nil
        return currentUserAgent != customUserAgent(for: request.url)
    }

    func isTrusted(url: URL) -> Bool {
        Self.isTrusted(url: url, isDebugBuild: isDebugBuild)
    }

    static func isTrusted(url: URL, isDebugBuild: Bool) -> Bool {
        guard url.scheme?.lowercased() == "https",
              let host = url.host?.lowercased() else { return false }

        let trustedHosts = isDebugBuild ? trustedDebugHosts : trustedReleaseHosts
        if trustedHosts.contains(host) { return true }
        return trustedDomains.contains { domain in
            host == domain || host.hasSuffix(".\(domain)")
        }
    }
}
