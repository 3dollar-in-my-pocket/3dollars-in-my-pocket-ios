public protocol NetworkConfigurable {
    var endPoint: String { get }
    var timeoutForRequest: Double { get }
    var timeoutForResource: Double { get }
    var appStoreVersion: String? { get }
    var userAgent: String { get }
    var authToken: String? { get }
}
