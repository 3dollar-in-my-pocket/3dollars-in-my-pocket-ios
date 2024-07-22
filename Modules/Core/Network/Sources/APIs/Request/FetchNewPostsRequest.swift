import Foundation

import Model

struct FetchStoreNewPostsRequest: RequestType {
    let storeId: String
    let input: CursorRequestInput
    
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
        return "/api/v1/store/\(storeId)/news-posts"
    }
}
