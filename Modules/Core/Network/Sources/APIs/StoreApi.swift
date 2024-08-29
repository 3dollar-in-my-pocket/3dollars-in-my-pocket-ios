import Foundation

import Model

enum StoreApi {
    case fetchBossStoreDetail(FetchBossStoreDetailInput)
}

extension StoreApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchBossStoreDetail:
            return nil
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchBossStoreDetail:
            return .get
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .fetchBossStoreDetail(let input):
            return .custom([
                "X-Device-Latitude": String(input.latitude),
                "X-Device-Longitude": String(input.longitude)
            ])
        }
    }
    
    var path: String {
        switch self {
        case .fetchBossStoreDetail(let input):
            return "/api/v4/boss-store/\(input.storeId)"
        }
    }
}
