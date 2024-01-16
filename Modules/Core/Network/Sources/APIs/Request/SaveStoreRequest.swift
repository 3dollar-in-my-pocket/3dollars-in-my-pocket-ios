import Foundation

import Model

struct SaveStoreRequest: RequestType {
    let storeType: StoreType
    let storeId: String
    let isDelete: Bool

    var param: Encodable? {
        return nil
    }
    
    var method: RequestMethod {
        return isDelete ? .delete : .put
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v1/favorite/subscription/store/target/\(storeType.rawValue)/\(storeId)"
    }
}
