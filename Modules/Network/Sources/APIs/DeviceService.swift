import Foundation

public protocol DeviceServiceProtocol {
    func registerDevice(pushToken: String) async -> Result<String, Error>
    
    func refreshDevice(pushToken: String) async -> Result<String, Error>
}

public struct DeviceService: DeviceServiceProtocol {
    public init() { }
    
    public func registerDevice(pushToken: String) async -> Result<String, Error> {
        let input = DeviceRequestInput(pushPlatformType: "FCM", pushToken: pushToken)
        let request = RegisterDeviceRequest(requestInput: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func refreshDevice(pushToken: String) async -> Result<String, Error> {
        let input = DeviceRequestInput(pushPlatformType: "FCM", pushToken: pushToken)
        let request = RefreshDeviceRequest(requestInput: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
