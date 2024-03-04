import Foundation

import Model

struct FetchMedalsRequest: RequestType {
    var method: RequestMethod {
        return .get
    }

    var path: String {
        return "/api/v1/medals"
    }
}
