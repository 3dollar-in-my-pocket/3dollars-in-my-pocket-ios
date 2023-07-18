import Foundation

public struct UserWithDeviceApiResponse: Decodable {
    public let userId: Int
    public let name: String
    public let socialType: String
    public let marketingConsent: MarketingConsent
    public let medal: MedalResponse
    public let device: DeviceInfoResponse
}
