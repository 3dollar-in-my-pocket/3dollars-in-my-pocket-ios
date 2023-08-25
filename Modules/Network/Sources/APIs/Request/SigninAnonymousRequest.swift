import Foundation

struct SigninAnonymousRequest: RequestType {
    var method: RequestMethod {
        return .post
    }
    
    var header: HTTPHeaderType {
        return .json
    }
    
    var path: String {
        return "/api/v1/signup/anonymous"
    }
}
