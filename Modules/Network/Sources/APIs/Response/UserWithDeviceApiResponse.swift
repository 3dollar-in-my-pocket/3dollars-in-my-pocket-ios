import Foundation

public struct UserWithDeviceApiResponse: Decodable {
    let userId: Int
    let name: String
    let socialType: String
    let marketingConsent: String
    let medal: MedalResponse
    let device: DeviceInfoResponse
}
