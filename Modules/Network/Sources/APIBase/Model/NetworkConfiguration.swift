import Foundation

public struct NetworkConfiguration {
    public let endPoint: String
    public let timeoutForRequest: Double
    public let timeoutForResource: Double
    public let appStoreVersion: String?
    public let userAgent: String
    public var authToken: String?

    public init(
        endPoint: String,
        timeoutForRequest: Double = 15,
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
