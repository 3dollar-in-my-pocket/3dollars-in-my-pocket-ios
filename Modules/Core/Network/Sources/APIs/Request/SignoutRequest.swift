import Foundation

import Model

struct SignoutRequest: RequestType {
    var param: Encodable? {
        return nil
    }
    
    var method: RequestMethod {
        return .delete
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v2/signout"
    }
}
