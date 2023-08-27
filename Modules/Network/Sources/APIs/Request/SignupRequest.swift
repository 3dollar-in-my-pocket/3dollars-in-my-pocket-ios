import Foundation

import Model

struct SignupRequest: RequestType {
    let requestInput: SignupInput

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
        return "/api/v2/signup"
    }
}
