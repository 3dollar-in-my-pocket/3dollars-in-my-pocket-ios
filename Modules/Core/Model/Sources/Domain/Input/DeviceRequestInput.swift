import Foundation

public struct DeviceRequestInput: Encodable {
    public let pushPlatformType: String
    public let pushToken: String
    
    public init(pushPlatformType: String, pushToken: String) {
        self.pushPlatformType = pushPlatformType
        self.pushToken = pushToken
    }
}
