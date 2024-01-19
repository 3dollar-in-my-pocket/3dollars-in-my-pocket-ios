import Foundation

import Model

struct FetchMyStoreVisitsRequest: RequestType {
    let requestInput: CursorRequestInput
    
    var param: Encodable? {
        return requestInput
    }

    var method: RequestMethod {
        return .get
    }

    var header: HTTPHeaderType {
        return .auth
    }

    var path: String {
        return "/api/v4/my/store-visits"
    }
}
