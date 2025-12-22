import Foundation

public struct AppForceUpdateResponse: Decodable {
    public let enabled: Bool
    public let title: String?
    public let message: String?
    public let linkUrl: String?
}
