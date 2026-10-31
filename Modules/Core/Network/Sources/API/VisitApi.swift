import Foundation

import Model

enum VisitApi {
    case visitStore(input: VisitStoreRequestInput)
    case deleteStoreVisit(visitId: String)
}

extension VisitApi: RequestType {
    var param: Encodable? {
        switch self {
        case .visitStore(let input):
            return input
        case .deleteStoreVisit:
            return nil
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .visitStore:
            return .post
        case .deleteStoreVisit:
            return .delete
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .visitStore:
            return .json
        case .deleteStoreVisit:
            return .json
        }
    }
    
    var path: String {
        switch self {
        case .visitStore:
            return "/api/v2/store/visit"
        case .deleteStoreVisit(let visitId):
            return "/api/v2/store/visit/\(visitId)"
        }
    }
}
