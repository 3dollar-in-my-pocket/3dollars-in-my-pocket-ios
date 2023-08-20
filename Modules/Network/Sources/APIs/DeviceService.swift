import Foundation

public protocol DeviceProtocol {
    func registerDevice(pushPlatformType: String, pushToken: String) async -> Result<String, Error>
    
    func refreshDevice(pushPlatformType: String, pushToken: String) async -> Result<String, Error>
}

public struct DeviceService: DeviceProtocol {
    public init() { }
    
    public func registerDevice(pushPlatformType: String, pushToken: String) async -> Result<String, Error> {
        let input = DeviceRequestInput(pushPlatformType: pushPlatformType, pushToken: pushToken)
        let request = RegisterDeviceRequest(requestInput: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func refreshDevice(pushPlatformType: String, pushToken: String) async -> Result<String, Error> {
        let input = DeviceRequestInput(pushPlatformType: pushPlatformType, pushToken: pushToken)
        let request = RefreshDeviceRequest(requestInput: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
