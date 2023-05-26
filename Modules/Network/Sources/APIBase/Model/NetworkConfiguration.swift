import Foundation

public struct NetworkConfiguration {
    public var endPoint: String
    public var timeoutForRequest: Double
    public var timeoutForResource: Double
    public var appStoreVersion: String?
    public var userAgent: String
    public var authToken: String?

    public init(
        endPoint: String,
        timeoutForRequest: Double = 3,
        timeoutForResource: Double = 30,
        appStoreVersion: String? = nil,
        userAgent: String,
        authToken: String?
    ) {
        self.endPoint = endPoint
        self.timeoutForRequest = timeoutForRequest
        self.timeoutForResource = timeoutForRequest
        self.appStoreVersion = appStoreVersion
        self.userAgent = userAgent
        self.authToken = authToken
    }
}

extension NetworkConfiguration {
    public static let defaultConfig = NetworkConfiguration(
        endPoint: "",
        userAgent: "",
        authToken: nil
    )
}
