import Foundation

import Model

struct StoreCreateRequest: RequestType {
    let requestInput: StoreCreateRequestInput

    var param: Encodable? {
        return requestInput
    }
    
    var method: RequestMethod {
        return .post
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v2/store"
    }
}
