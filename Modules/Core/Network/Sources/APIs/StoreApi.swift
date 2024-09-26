import Foundation

import Model

enum StoreApi {
    case fetchBossStoreDetail(FetchBossStoreDetailInput)
    case fetchStoreNewPosts(storeId: String, cursorInput: CursorRequestInput)
    case togglePostSticker(storeId: String, postId: String, input: StoreNewsPostStickersReplaceRequest)
    case fetchAroundStores(input: FetchAroundStoreInput)
    case fetchStoreDetail(input: FetchStoreDetailInput)
    case createStore(input: StoreCreateRequestInput)
    case editStore(storeId: Int, input: EditStoreRequestInput)
}

extension StoreApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchBossStoreDetail:
            return nil
        case .fetchStoreNewPosts(_, let cursorInput):
            return cursorInput
        case .togglePostSticker(_, _, let input):
            return input
        case .fetchAroundStores(let input):
            return input
        case .fetchStoreDetail(let input):
            return input
        case .createStore(let input):
            return input
        case .editStore(_, let input):
            return input
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchBossStoreDetail:
            return .get
        case .fetchStoreNewPosts:
            return .get
        case .togglePostSticker:
            return .put
        case .fetchAroundStores:
            return .get
        case .fetchStoreDetail:
            return .get
        case .createStore:
            return .post
        case .editStore:
            return .put
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .fetchBossStoreDetail(let input):
            return .custom([
                "X-Device-Latitude": String(input.latitude),
                "X-Device-Longitude": String(input.longitude)
            ])
        case .fetchStoreNewPosts:
            return .auth
        case .togglePostSticker:
            return .auth
        case .fetchAroundStores:
            return .location
        case .fetchStoreDetail:
            return .location
        case .createStore:
            return .auth
        case .editStore:
            return .auth
        }
    }
    
    var path: String {
        switch self {
        case .fetchBossStoreDetail(let input):
            return "/api/v4/boss-store/\(input.storeId)"
        case .fetchStoreNewPosts(let storeId, _):
            return "/api/v1/store/\(storeId)/news-posts"
        case .togglePostSticker(let storeId, let postId, _):
            return "/api/v1/store/\(storeId)/news-post/\(postId)/stickers"
        case .fetchAroundStores:
            return "/api/v4/stores/around"
        case .fetchStoreDetail(let input):
            return "/api/v4/store/\(input.storeId)"
        case .createStore:
            return "/api/v2/store"
        case .editStore(let storeId, _):
            return "/api/v2/store/\(storeId)"
        }
    }
}
