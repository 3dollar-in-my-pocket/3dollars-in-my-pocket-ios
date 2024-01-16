import Foundation

import Model

struct FetchStoreReviewRequest: RequestType {
    let storeId: Int
    let input: FetchStoreReviewRequestInput
    
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
        return "/api/v4/store/\(storeId)/reviews"
    }
}


