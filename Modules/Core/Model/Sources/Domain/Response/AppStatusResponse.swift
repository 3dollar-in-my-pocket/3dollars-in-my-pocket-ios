import Foundation

public struct AppStatusResponse: Decodable {
    public let osPlatform: String
    public let currentVersion: String
    public let forceUpdate: AppForceUpdateResponse
}
