import Foundation

import Model

struct fetchMyFavoriteStoresRequest: RequestType {
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
        return "/api/v2/my/favorite-stores"
    }
}
