import Foundation

import Model

struct fetchMyStoresRequest: RequestType {
    let requestInput: CursorRequestInput
    let latitude: Double
    let longitude: Double
    
    var param: Encodable? {
        return requestInput
    }

    var method: RequestMethod {
        return .get
    }

    var header: HTTPHeaderType {
        return .custom([
            "X-Device-Latitude": String(latitude),
            "X-Device-Longitude": String(longitude)
        ])
    }

    var path: String {
        return "/api/v4/my/stores"
    }
}
