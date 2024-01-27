import Foundation

import Model

struct RemoveBookmarkStoreRequest: RequestType {
    let storeId: Int
    
    var param: Encodable? {
        return nil
    }
    
    var method: RequestMethod {
        return .delete
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v2/store/\(storeId)/favorite"
    }
}
