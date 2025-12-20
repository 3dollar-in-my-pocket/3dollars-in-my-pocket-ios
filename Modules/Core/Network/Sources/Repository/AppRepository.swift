import Foundation

import Model

public protocol AppRepository {
    func fetchAppStatus() async -> Result<AppStatusResponse, Error>
}

public struct AppRepositoryImpl: AppRepository {
    public init() { }
    
    public func fetchAppStatus() async -> Result<AppStatusResponse, Error> {
        let request = AppApi.fetchAppStatus
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
