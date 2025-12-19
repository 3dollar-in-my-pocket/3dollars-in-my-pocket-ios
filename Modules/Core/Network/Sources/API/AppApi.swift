import Foundation

import Model

enum AppApi {
    case fetchAppStatus
}

extension AppApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchAppStatus:
            return nil
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchAppStatus:
            return .get
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .fetchAppStatus:
            return .json
        }
    }
    
    var path: String {
        switch self {
        case .fetchAppStatus:
            return "/api/v1/app/status"
        }
    }
}
