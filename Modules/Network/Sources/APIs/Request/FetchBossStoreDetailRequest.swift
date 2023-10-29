import Foundation

import Model

struct FetchBossStoreDetailRequest: RequestType {
    let input: FetchBossStoreDetailInput

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
        return "/api/v4/boss-store/\(input.storeId)"
    }
}
