import Foundation

import Model

struct SendClickEventRequest: RequestType {
    let targetId: Int
    let type: String

    var param: Encodable? {
        return nil
    }
    
    var method: RequestMethod {
        return .post
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v1/event/click/\(type)/\(targetId)"
    }
}
