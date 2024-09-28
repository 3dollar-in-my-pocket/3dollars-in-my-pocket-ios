import Foundation

import Model

public protocol EventRepository {
    func sendClickEvent(targetId: Int, type: String) async -> Result<String?, Error>
}

public struct EventRepositoryImpl: EventRepository {
    public init() { }
    
    public func sendClickEvent(targetId: Int, type: String) async -> Result<String?, Error> {
        let request = EventApi.sendClickEvent(targetId: targetId, type: type)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}

