import Foundation

public struct UserLogOutRequestInput: Encodable {
    public let logoutDevice: UserLogOutDeviceRequestInput?
    
    public init(logoutDevice: UserLogOutDeviceRequestInput?) {
        self.logoutDevice = logoutDevice
    }
}

public struct UserLogOutDeviceRequestInput: Encodable {
    public let pushPlatform: String
    public let pushToken: String
    
    public init?(pushPlatform: String, pushToken: String?) {
        if let pushToken {
            self.pushPlatform = pushPlatform
            self.pushToken = pushToken
        } else {
            return nil
        }
    }
}
