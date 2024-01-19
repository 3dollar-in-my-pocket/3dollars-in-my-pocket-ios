import Foundation

import Model

struct FetchMyUserRequest: RequestType {
    var param: Encodable? {
        return ["includeActivities": true]
    }

    var method: RequestMethod {
        return .get
    }

    var header: HTTPHeaderType {
        return .auth
    }

    var path: String {
        return "/api/v4/my/user"
    }
}
