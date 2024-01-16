import Foundation

import Model

struct FetchUserRequest: RequestType {
    var param: Encodable?
    
    var method: RequestMethod {
        return .get
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v2/user/me"
    }
}
