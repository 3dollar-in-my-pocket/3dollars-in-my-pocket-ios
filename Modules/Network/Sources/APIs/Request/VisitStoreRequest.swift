import Foundation

import Model

struct VisitStoreRequest: RequestType {
    let input: VisitStoreRequestInput
    
    var param: Encodable? {
        return input
    }
    
    var method: RequestMethod {
        return .post
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v2/store/visit"
    }
}
