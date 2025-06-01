import Foundation

import Model

enum StoreDetailApi {
    case fetchStoreDetail(storeId: String)
}

extension StoreDetailApi: RequestType {
    var param: (any Encodable)? {
        switch self {
        case .fetchStoreDetail(let storeId):
            return ["storeId": storeId]
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchStoreDetail:
            return .get
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .fetchStoreDetail:
            return .location
        }
    }
    
    var path: String {
        switch self {
        case .fetchStoreDetail:
            return "/api/v1/screen/store"
        }
    }
}
