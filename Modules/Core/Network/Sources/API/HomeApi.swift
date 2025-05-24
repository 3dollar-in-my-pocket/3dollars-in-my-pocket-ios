import Foundation

import Model

enum HomeApi {
    case fetchHomeCards(input: FetchHomeCardInput)
}

extension HomeApi: RequestType {
    var param: (any Encodable)? {
        switch self {
        case .fetchHomeCards(let input):
            return input
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchHomeCards:
            return .get
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .fetchHomeCards:
            return .location
        }
    }
    
    var path: String {
        switch self {
        case .fetchHomeCards:
            return "/api/v1/screen/home-cards"
        }
    }
}
