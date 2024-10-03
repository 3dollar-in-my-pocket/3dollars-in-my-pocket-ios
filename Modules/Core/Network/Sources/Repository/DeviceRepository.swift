import Foundation

import Model

public protocol DeviceRepository {
    func registerDevice(input: DeviceRequestInput) async -> Result<String, Error>
    
    func refreshDevice(input: DeviceRequestInput) async -> Result<String, Error>
}

public struct DeviceRepositoryImpl: DeviceRepository {
    public init() { }
    
    public func registerDevice(input: DeviceRequestInput) async -> Result<String, Error> {
        let request = DeviceApi.registerDevice(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func refreshDevice(input: DeviceRequestInput) async -> Result<String, Error> {
        let request = DeviceApi.refreshDevice(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
