import Foundation

import Model

struct FetchBookmarkStoreRequest: RequestType {
    let input: FetchBookmarkStoreRequestInput
    
    var param: Encodable? {
        return input
    }
    
    var method: RequestMethod {
        return .get
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v2/my/favorite-stores"
    }
}
