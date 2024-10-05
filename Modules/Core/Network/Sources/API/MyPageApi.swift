import Foundation

import Model

enum MyPageApi {
    case fetchMyStoreVisits(input: CursorRequestInput)
    case fetchMyFavoriteStores(input: CursorRequestInput)
    case fetchMyStores(input: CursorRequestInput)
}

extension MyPageApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchMyStoreVisits(let input):
            return input
        case .fetchMyFavoriteStores(let input):
            return input
        case .fetchMyStores(let input):
            return input
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchMyStoreVisits:
            return .get
        case .fetchMyFavoriteStores:
            return .get
        case .fetchMyStores:
            return .get
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .fetchMyStoreVisits:
            return .json
        case .fetchMyFavoriteStores:
            return .json
        case .fetchMyStores:
            return .location
        }
    }
    
    var path: String {
        switch self {
        case .fetchMyStoreVisits:
            return "/api/v4/my/store-visits"
        case .fetchMyFavoriteStores:
            return "/api/v2/my/favorite-stores"
        case .fetchMyStores:
            return "/api/v4/my/stores"
        }
    }
}
