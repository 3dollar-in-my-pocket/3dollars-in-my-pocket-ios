import Foundation

import Model

public protocol EventServiceProtocol {
    func sendClickEvent(targetId: Int, type: String) async -> Result<String?, Error>
}

public struct EventService: EventServiceProtocol {
    public init() { }
    
    public func sendClickEvent(targetId: Int, type: String) async -> Result<String?, Error> {
        let request = SendClickEventRequest(targetId: targetId, type: type)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}

