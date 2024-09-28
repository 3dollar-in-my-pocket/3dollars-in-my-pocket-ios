import Foundation

import Model

enum MedalApi {
    case fetchMedals
}

extension MedalApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchMedals:
            return nil
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchMedals:
            return .get
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .fetchMedals:
            return .json
        }
    }
    
    var path: String {
        switch self {
        case .fetchMedals:
            return "/api/v1/medals"
        }
    }
}
