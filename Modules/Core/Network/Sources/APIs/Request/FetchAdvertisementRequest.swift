import Foundation

import Model

struct FetchAdvertisementRequest: RequestType {
    let input: FetchAdvertisementInput
    
    var param: Encodable? {
        return input
    }
    
    var method: RequestMethod {
        return .get
    }
    
    var header: HTTPHeaderType {
        return .json
    }
    
    var path: String {
        return "/api/v1/advertisements"
    }
}
