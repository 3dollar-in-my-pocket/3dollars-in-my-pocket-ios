import Foundation

import Model

enum VisitApi {
    case visitStore(input: VisitStoreRequestInput)
}

extension VisitApi: RequestType {
    var param: Encodable? {
        switch self {
        case .visitStore(let input):
            return input
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .visitStore:
            return .post
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .visitStore:
            return .auth
        }
    }
    
    var path: String {
        switch self {
        case .visitStore:
            return "/api/v2/store/visit"
        }
    }
}
