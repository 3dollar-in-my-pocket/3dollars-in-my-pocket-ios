import Foundation

import Model

struct SigninRequest: RequestType {
    let requestInput: SigninRequestInput
    
    var param: Encodable? {
        return requestInput
    }
    
    var method: RequestMethod {
        return .post
    }
    
    var header: HTTPHeaderType {
        return .json
    }
    
    var path: String {
        return "/api/v2/login"
    }
}
