import Foundation

import Model

enum AdvertisementApi {
    case fetchAdvertisements(input: FetchAdvertisementInput)
}

extension AdvertisementApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchAdvertisements(let input):
            return input
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchAdvertisements:
            return .get
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .fetchAdvertisements:
            return .location
        }
    }
    
    var path: String {
        switch self {
        case .fetchAdvertisements:
            return "/api/v1/advertisements"
        }
    }
}
