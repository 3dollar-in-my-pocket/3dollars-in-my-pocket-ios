import Foundation

import Model

struct LogoutRequest: RequestType {
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
        return "/api/v2/logout"
    }
}
