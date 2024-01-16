import Foundation

import Model

struct FetchStorePhotoRequest: RequestType {
    let storeId: Int
    let size: Int
    let cursor: String?

    var param: Encodable? {
        var params = ["storeId": "\(storeId)"]
        
        if let cursor {
            params["cursor"] = cursor
        }
        
        return params
    }
    
    var method: RequestMethod {
        return .get
    }
    
    var header: HTTPHeaderType {
        return .json
    }
    
    var path: String {
        return "/api/v4/store/\(storeId)/images"
    }
}
