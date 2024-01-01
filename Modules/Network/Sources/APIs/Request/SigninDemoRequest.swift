import Foundation

import Model

struct SigninDemoRequest: RequestType {
    let code: String
    
    var param: Encodable? {
        return ["code": code]
    }
    
    var method: RequestMethod {
        return .post
    }
    
    var header: HTTPHeaderType {
        return .json
    }
    
    var path: String {
        return "/api/login/demo"
    }
    
    var usingQuery: Bool {
        return true
    }
}
