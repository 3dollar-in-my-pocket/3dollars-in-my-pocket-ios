import Foundation

import Model

struct FetchPopularStoresRequest: RequestType {
    let requestInput: FetchPopularStoresInput

    var param: Encodable? {
        return requestInput
    }

    var method: RequestMethod {
        return .get
    }

    var path: String {
        return "/api/v1/neighborhood/popular-stores"
    }
}
