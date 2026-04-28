import Foundation

import Model

enum ScreenApi {
    case fetchHomeFilterScreen
}

extension ScreenApi: RequestType {
    var param: (any Encodable)? {
        switch self {
        case .fetchHomeFilterScreen:
            return nil
        }
    }

    var method: RequestMethod {
        switch self {
        case .fetchHomeFilterScreen:
            return .get
        }
    }

    var header: HTTPHeaderType {
        switch self {
        case .fetchHomeFilterScreen:
            return .json
        }
    }

    var path: String {
        switch self {
        case .fetchHomeFilterScreen:
            return "/api/v1/screen/home"
        }
    }
}
