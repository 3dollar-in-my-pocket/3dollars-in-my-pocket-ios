import Foundation

import Model

enum EventApi {
    case sendClickEvent(targetId: Int, type: String)
}

extension EventApi: RequestType {
    var param: Encodable? {
        switch self {
        case .sendClickEvent:
            return nil
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .sendClickEvent:
            return .post
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .sendClickEvent:
            return .auth
        }
    }
    
    var path: String {
        switch self {
        case .sendClickEvent(let targetId, let type):
            return "/api/v1/event/click/\(type)/\(targetId)"
        }
    }
}
