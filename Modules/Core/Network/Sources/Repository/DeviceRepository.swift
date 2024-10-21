import Foundation

import Model

public protocol DeviceRepository {
    func updateDevice(input: UserDeviceUpsertRequest) async -> Result<String, Error>
}

public struct DeviceRepositoryImpl: DeviceRepository {
    public init() { }
    
    public func updateDevice(input: UserDeviceUpsertRequest) async -> Result<String, Error> {
        let request = DeviceApi.updateDevice(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
