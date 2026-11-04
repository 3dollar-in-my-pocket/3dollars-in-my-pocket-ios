import Foundation

import Model

enum ServiceCreatorApi {
    case listCreators
}

extension ServiceCreatorApi: RequestType {
    var param: Encodable? {
        switch self {
        case .listCreators:
            return nil
        }
    }

    var method: RequestMethod {
        switch self {
        case .listCreators:
            return .get
        }
    }

    var header: HTTPHeaderType {
        switch self {
        case .listCreators:
            return .json
        }
    }

    var path: String {
        switch self {
        case .listCreators:
            return "/api/v1/service-creators"
        }
    }
}
