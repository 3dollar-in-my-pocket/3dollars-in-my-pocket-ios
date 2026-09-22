import Foundation

public enum AppEnvironment {
    private static let devAPIHost = "dev.threedollars.co.kr"

    private static var apiURL: String {
        Bundle.main.infoDictionary?["API_URL"] as? String ?? ""
    }

    public static var isDevServer: Bool {
        isDevServer(apiURL: apiURL)
    }

    public static var isDebugToolAvailable: Bool {
        #if DEBUG
        let isDebugBuild = true
        #else
        let isDebugBuild = false
        #endif

        return isDebugToolAvailable(isDebugBuild: isDebugBuild, apiURL: apiURL)
    }

    public static func isDebugToolAvailable(isDebugBuild: Bool, apiURL: String) -> Bool {
        isDebugBuild || isDevServer(apiURL: apiURL)
    }

    public static func isDevServer(apiURL: String) -> Bool {
        apiURL.contains(devAPIHost)
    }
}
