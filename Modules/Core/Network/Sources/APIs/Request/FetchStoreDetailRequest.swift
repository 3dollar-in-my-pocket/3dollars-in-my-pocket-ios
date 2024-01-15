import Foundation

import Model

struct FetchStoreDetailRequest: RequestType {
    let input: FetchStoreDetailInput
    
    var param: Encodable? {
        return input
    }
    
    var method: RequestMethod {
        return .get
    }
    
    var header: HTTPHeaderType {
        return .custom([
            "X-Device-Latitude": String(input.latitude),
            "X-Device-Longitude": String(input.longitude)
        ])
    }
    
    var path: String {
        return "/api/v4/store/\(input.storeId)"
    }
}
