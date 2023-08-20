import Foundation

public struct DeviceRequestInput: Encodable {
    let pushPlatformType: String
    let pushToken: String
}
