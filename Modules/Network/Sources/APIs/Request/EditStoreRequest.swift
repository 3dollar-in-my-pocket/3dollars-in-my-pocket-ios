import Foundation

import Model

struct EditStoreRequest: RequestType {
    let storeId: Int
    let requestInput: EditStoreRequestInput
    
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
        return "/api/v2/store/\(storeId)"
    }
}
