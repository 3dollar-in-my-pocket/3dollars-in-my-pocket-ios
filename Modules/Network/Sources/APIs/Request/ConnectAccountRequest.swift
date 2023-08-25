import Foundation

struct ConnectAccountRequest: RequestType {
    let requestInput: SigninRequestInput
    
    var param: Encodable? {
        return requestInput
    }
    
    var method: RequestMethod {
        return .put
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v1/connect/account"
    }
}
